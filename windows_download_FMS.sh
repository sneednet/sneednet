#! /bin/bash

log ()
{
#    echo "$1"
:
}

curr_dir=$(cygpath -w `pwd`)
echo "current folder: $curr_dir"

function wait_for {
  local line
  local str=$1
  while read -r line
  do
    if [ "$line" == "$str" ]; then
      break
    fi
  done
}

function process_dda_reply {
  local readfile=""
  local writefile=""
  local content=""
  
  while read -r line
  do
   if [[ "$line" =~ ^ReadFilename=.* ]]; then
     readfile="${line##ReadFilename=}"
   fi
   if [[ "$line" =~ ^WriteFilename=.* ]]; then
     writefile="${line##WriteFilename=}"
   fi
   if [[ "$line" =~ ^ContentToWrite=.* ]]; then
     content="${line##ContentToWrite=}"
   fi
   if [[ "$line" == "EndMessage" ]]; then
     echo -n "$content" >"$writefile"
     cat "$readfile"
     break
   fi
  done
}

function process_dda_complete {
  while read -r line
  do
   if [[ "$line" =~ ^ReadDirectoryAllowed=.* ]]; then
     if [[ "false" == "${line##ReadDirectoryAllowed=}" ]]; then
       echo "Did not get read permission"
       exit
     fi 
   fi
   if [[ "$line" =~ ^WriteDirectoryAllowed=.* ]]; then
     if [[ "false" == "${line##WriteDirectoryAllowed=}" ]]; then
       echo "Did not get write permission"
       exit
     fi 
   fi
   if [[ "$line" == "EndMessage" ]]; then
     break
   fi
  done
}

function handle_progress {
  local total=0
  local succeeded=0
  local required=0
  local final=""
  
  while read -r line
  do
   if [[ "$line" =~ ^Total=.* ]]; then
     total="${line##Total=}"
   fi
   if [[ "$line" =~ ^Required=.* ]]; then
     required="${line##Required=}"
   fi
   if [[ "$line" == "FinalizedTotal=true" ]]; then
     final="final"
   fi
   if [[ "$line" =~ ^Succeeded=.* ]]; then
     succeeded="${line##Succeeded=}"
   fi
   if [[ "$line" == "EndMessage" ]]; then
     echo "Progress: retrieved $succeeded out of $required required and $total total ($final)"
     break
   fi
  done
}

function wait_with_progress {
  log "wait_with_progress, entering while loop"
  while read -r line
  do
    log "iteration"
    log "line: $line"
    if [ "$line" == "SimpleProgress" ]; then
      log "if"
      handle_progress
    fi
    if [ "$line" == "$1" ]; then
      log "fi"
      break
    fi
  done
}

log "connecting to socket"
exec 3<>/dev/tcp/127.0.0.1/9481

log "sendinc ClientHello"
cat >&3 <<HERE
ClientHello
Name=My Client Name
ExpectedVersion=2.0
EndMessage
HERE

wait_for "NodeHello" <&3
wait_for "EndMessage" <&3

log "sending TestDDARequest"
cat >&3 <<HERE
TestDDARequest
Directory=$curr_dir
WantWriteDirectory=true
WantReadDirectory=true
EndMessage
HERE

log "waiting for TestDDAReply"
wait_for "TestDDAReply" <&3
log "processing TestDDAReply"
content=$(process_dda_reply <&3)

log "sending TestDDAResponse"
cat >&3 <<HERE
TestDDAResponse
Directory=$curr_dir
ReadContent=$content
EndMessage
HERE

log "sending TestDDAComplete"
wait_for "TestDDAComplete" <&3
process_dda_complete <&3

rm -f fms-win64bin-0.3.85.zip

log "running ClientGet"

cat >&3 <<HERE
ClientGet
URI=http://127.0.0.1:8888/CHK@T3k8sGucHme3MA7a2oo1KlUMHvPmpE~FTwO-KFLFaks,Le1M6QRwrHF00mR4W2eWLyj5Cx0g~AQG73wx5w1cLfs,AAMC--8/fms-win64bin-0.3.85.zip
Identifier=1234
Verbosity=1
ReturnType=disk
Filename=$curr_dir\fms-win64bin-0.3.85.zip
EndMessage
HERE

log "waiting for progress"

wait_with_progress "DataFound" <&3

log "waiting for EndMessage"

wait_for "EndMessage" <&3

exec 3<&-
exec 3>&-

