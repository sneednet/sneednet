#!/bin/bash

echo "Extracting FMS."
mkdir FMS-install
mv fms-win64bin-0.3.85.zip FMS-install
cd FMS-install
unzip fms-win64bin-0.3.85.zip
./fms.exe &
cd ..

sleep 10

echo "Waiting 20s for FMS to finish startup."

sleep 20

echo "Applying settings to FMS."

#Adjust the following settings:  
#MinLocalMessageTrust 50 0
#MinPeerMessageTrust 30 0 
#MinLocalTrustListTrust 50 0
#MinPeerTrustListTrust 30 0
#LocalTrustOverridesPeerTrust false true
#MessageDownloadMaxDaysBackward 5 1000000
#MessageListDaysBackward 10 1000000
#ChangeMessageTrustOnReply 0 1
#DeleteMessagesOlderThan 180 -1

wget -O wizard_form.html http://127.0.0.1:8080/options.htm && sleep 2 && form_password=$(grep -oP 'name=\"formpassword\" value=\"\K[^"]+' wizard_form.html | head -1) && wget -O - --post-data="formaction=save&formpassword=$form_password&option%5B23%5D=MinLocalMessageTrust&oldvalue%5B23%5D=50&value%5B23%5D=0&option%5B24%5D=MinPeerMessageTrust&oldvalue%5B24%5D=30&value%5B24%5D=0&option%5B25%5D=MinLocalTrustListTrust&oldvalue%5B25%5D=50&value%5B25%5D=0&option%5B26%5D=MinPeerTrustListTrust&oldvalue%5B26%5D=30&value%5B26%5D=0&option%5B27%5D=LocalTrustOverridesPeerTrust&oldvalue%5B27%5D=false&value%5B27%5D=true&option%5B28%5D=MessageDownloadMaxDaysBackward&oldvalue%5B28%5D=5&value%5B28%5D=1000000&option%5B29%5D=MessageListDaysBackward&oldvalue%5B29%5D=10&value%5B29%5D=1000000&option%5B33%5D=ChangeMessageTrustOnReply&oldvalue%5B33%5D=0&value%5B33%5D=1&option%5B35%5D=DeleteMessagesOlderThan&oldvalue%5B35%5D=180&value%5B35%5D=-1" 'http://127.0.0.1:8080/options.htm' > /dev/null

sleep 2
echo "Installing PublicID for FMS."
sleep 3

wget -O wizard_form.html http://127.0.0.1:8080/options.htm && sleep 2 && form_password=$(grep -oP 'name=\"formpassword\" value=\"\K[^"]+' wizard_form.html | head -1) && echo "form_password: $form_password" && curl -X POST http://127.0.0.1:8080/localidentities.htm -H 'Content-Type: multipart/form-data' -F "formpassword=$form_password" -F "formaction=import" -F 'file=@public_id.xml'

echo "All done. FMS should be ready to use.".
