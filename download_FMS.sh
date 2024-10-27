#! /bin/bash
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
  while read -r line
  do
    if [ "$line" == "SimpleProgress" ]; then
      handle_progress
    fi
    if [ "$line" == "$1" ]; then
      break
    fi
  done
}


exec 3<>/dev/tcp/127.0.0.1/9481

cat >&3 <<HERE
ClientHello
Name=My Client Name
ExpectedVersion=2.0
EndMessage
HERE

wait_for "NodeHello" <&3
wait_for "EndMessage" <&3

cat >&3 <<HERE
TestDDARequest
Directory=/tmp/
WantWriteDirectory=true
WantReadDirectory=true
EndMessage
HERE

wait_for "TestDDAReply" <&3
content=$(process_dda_reply <&3)

cat >&3 <<HERE
TestDDAResponse
Directory=/tmp/
ReadContent=$content
EndMessage
HERE

wait_for "TestDDAComplete" <&3
process_dda_complete <&3

rm -f /tmp/fms-linux-x86-bin-0.3.85.tar.gz

cat >&3 <<HERE
ClientGet
URI=CHK@NvT50rE2pz9bne9O-OE~GFY8z-JKul8NoxUDHWv7Evc,yQNgly4kq6WX4pT8A821R4fuOnZUroxi~8vtM1JAehg,AAMC--8/fms-linux-x86-bin-0.3.85.tar.gz
Identifier=1234
Verbosity=1
ReturnType=disk
Filename=/tmp/fms-linux-x86-bin-0.3.85.tar.gz
EndMessage
HERE

wait_with_progress "DataFound" <&3
wait_for "EndMessage" <&3

exec 3<&-
exec 3>&-

