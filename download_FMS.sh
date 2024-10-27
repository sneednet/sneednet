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

function get_data_length {
  local line
  while read -r line
  do
   if [[ "$line" =~ ^DataLength=.* ]]; then
     echo "${line##DataLength=}"
     break
   fi
  done
}

echo "Opening 127.0.0.1:9481 socket."
exec 3<>/dev/tcp/127.0.0.1/9481

echo "Sending ClientHello message."
cat >&3 <<HERE
ClientHello
Name=My Client Name
ExpectedVersion=2.0
EndMessage
HERE

echo "Waiting for response."
wait_for "NodeHello" <&3
wait_for "EndMessage" <&3

echo "Sending ClientGet."
cat >&3 <<HERE
ClientGet
URI=CHK@NvT50rE2pz9bne9O-OE~GFY8z-JKul8NoxUDHWv7Evc,yQNgly4kq6WX4pT8A821R4fuOnZUroxi~8vtM1JAehg,AAMC--8/fms-linux-x86-bin-0.3.85.tar.gz
Identifier=1234
Verbosity=0
ReturnType=direct
EndMessage
HERE

echo "Sending AllData request."
wait_for "AllData" <&3
echo "Getting data length."
len=$(get_data_length <&3)
echo "len: $len"
echo "Waiting for Data message indicating start of data."
wait_for "Data" <&3
echo "Running dd, beginning to copy data."
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
{ while true; do pkill -x -USR1 dd; sleep 1; done; } &
dd bs=1 count=$len of="fms-linux-x86-bin-0.3.85.tar.gz" <&3
echo "Download finished."

# Close file descriptor 3.
exec 3<&-
exec 3>&-

