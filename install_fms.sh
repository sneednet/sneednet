#!/bin/bash

mkdir FMS-install
tar -xzvf fms-linux-x86-bin-0.3.85.tar.gz -C FMS-install
mkdir fms_dependencies
# Download FMS dependencies
cd fms_dependencies
wget -nc http://archive.ubuntu.com/ubuntu/pool/universe/f/freeimage/libfreeimage3_3.17.0+ds1-5build2_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/universe/j/jxrlib/libjxr0_1.1-6build1_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_1.5.2-0ubuntu5_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/universe/o/openjpeg2/libopenjp2-7_2.3.0-1_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/libp/libpng1.6/libpng16-16_1.6.34-1_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/libr/libraw/libraw16_0.18.8-1_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/t/tiff/libtiff5_4.0.9-5_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/libw/libwebp/libwebpmux3_0.6.1-2_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/libw/libwebp/libwebp6_0.6.1-2_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/o/openexr/libopenexr22_2.2.0-11.1ubuntu1_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/i/ilmbase/libilmbase12_2.2.0-11ubuntu2_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-8/libgomp1_8-20180414-1ubuntu2_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/ubuntu/pool/main/l/lcms2/liblcms2-2_2.9-1_i386.deb
wget -nc http://archive.ubuntu.com/ubuntu/pool/main/j/jbigkit/libjbig0_2.0-2ubuntu4.1_i386.deb
for file in ./*; do ar -x "$file"; done;
for folder in ./*; do tar -xxvf "$folder"/data.tar.xz; done;
cd ..
mkdir FMS-install/deps
cp fms_dependencies/usr/lib/i386-linux-gnu/libfreeimage-3.17.0.so FMS-install/deps/libfreeimage.so.3
cp fms_dependencies/usr/lib/i386-linux-gnu/libjxrglue.so.1.1 FMS-install/deps/libjxrglue.so.0
cp fms_dependencies/usr/lib/i386-linux-gnu/libjpeg.so.8.1.2 FMS-install/deps/libjpeg.so.8
cp fms_dependencies/usr/lib/i386-linux-gnu/libopenjp2.so.2.3.0 FMS-install/deps/libopenjp2.so.7
cp fms_dependencies/usr/lib/i386-linux-gnu/libpng16.so.16.34.0 FMS-install/deps/libpng16.so.16
cp fms_dependencies/usr/lib/i386-linux-gnu/libraw.so.16.0.0 FMS-install/deps/libraw.so.16
cp fms_dependencies/usr/lib/i386-linux-gnu/libtiff.so.5.3.0 FMS-install/deps/libtiff.so.5
cp fms_dependencies/usr/lib/i386-linux-gnu/libwebpmux.so.3.0.1 FMS-install/deps/libwebpmux.so.3
cp fms_dependencies/usr/lib/i386-linux-gnu/libwebp.so.6.0.2 FMS-install/deps/libwebp.so.6
cp fms_dependencies/usr/lib/i386-linux-gnu/libIlmImf-2_2.so.22.0.0 FMS-install/deps/libIlmImf-2_2.so.22
cp fms_dependencies/usr/lib/i386-linux-gnu/libHalf.so.12.0.0 FMS-install/deps/libHalf.so.12
cp fms_dependencies/usr/lib/i386-linux-gnu/libIex-2_2.so.12.0.0 FMS-install/deps/libIex-2_2.so.12
cp fms_dependencies/usr/lib/i386-linux-gnu/libjpegxr.so.1.1 FMS-install/deps/libjpegxr.so.0
cp fms_dependencies/usr/lib/i386-linux-gnu/libjpeg.so.8.1.2 FMS-install/deps/libjpeg.so.62
cp fms_dependencies/usr/lib/i386-linux-gnu/liblcms2.so.2.0.8 FMS-install/deps/liblcms2.so.2
cp fms_dependencies/usr/lib/i386-linux-gnu/libgomp.so.1.0.0 FMS-install/deps/libgomp.so.1
cp fms_dependencies/usr/lib/i386-linux-gnu/libIlmThread-2_2.so.12.0.0 FMS-install/deps/libIlmThread-2_2.so.12
cp fms_dependencies/usr/lib/i386-linux-gnu/libjbig.so.0 FMS-install/deps/libjbig.so.0

sleep 2
echo "Configuring FMS."
sleep 2

read -p "Press the Enter key to continue."

echo "LD_PRELOAD=./deps/libfreeimage.so.3:./deps/libjxrglue.so.0:./deps/libjpeg.so.8:./deps/libopenjp2.so.7:./deps/libpng16.so.16:./deps/libraw.so.16:./deps/libtiff.so.5:./deps/libwebpmux.so.3:./deps/libwebp.so.6:./deps/libIlmImf-2_2.so.22:./deps/libHalf.so.12:./deps/libIex-2_2.so.12:./deps/libjpegxr.so.0:./deps/libjpeg.so.62:./deps/liblcms2.so.2:./deps/libgomp.so.1:./deps/libIlmThread-2_2.so.12:./deps/libjbig.so.0 ./fms" > FMS-install/run-fms.sh
chmod +x FMS-install/run-fms.sh

cd FMS-install 

ls
./run-fms.sh &
cd ..

sleep 5

echo "Waiting 15s for FMS to finish startup."

sleep 15

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

wget -O wizard_form.html http://127.0.0.1:8080/options.htm && sleep 2 && form_password=$(grep -oP 'name=\"formpassword\" value=\"\K[^"]+' wizard_form.html) && wget -O - --post-data="formaction=save&formpassword=$form_password&option%5B23%5D=MinLocalMessageTrust&oldvalue%5B23%5D=50&value%5B23%5D=0&option%5B24%5D=MinPeerMessageTrust&oldvalue%5B24%5D=30&value%5B24%5D=0&option%5B25%5D=MinLocalTrustListTrust&oldvalue%5B25%5D=50&value%5B25%5D=0&option%5B26%5D=MinPeerTrustListTrust&oldvalue%5B26%5D=30&value%5B26%5D=0&option%5B27%5D=LocalTrustOverridesPeerTrust&oldvalue%5B27%5D=false&value%5B27%5D=true&option%5B28%5D=MessageDownloadMaxDaysBackward&oldvalue%5B28%5D=5&value%5B28%5D=1000000&option%5B29%5D=MessageListDaysBackward&oldvalue%5B29%5D=10&value%5B29%5D=1000000&option%5B33%5D=ChangeMessageTrustOnReply&oldvalue%5B33%5D=0&value%5B33%5D=1&option%5B35%5D=DeleteMessagesOlderThan&oldvalue%5B35%5D=180&value%5B35%5D=-1" 'http://127.0.0.1:8080/options.htm' > /dev/null

sleep 2
echo "Installing PublicID for FMS."
sleep 3

wget -O wizard_form.html http://127.0.0.1:8080/options.htm && sleep 2 && form_password=$(grep -oP 'name=\"formpassword\" value=\"\K[^"]+' wizard_form.html) && echo "form_password: $form_password" && curl -X POST http://127.0.0.1:8080/localidentities.htm -H 'Content-Type: multipart/form-data' -F "formpassword=$form_password" -F "formaction=import" -F 'file=@public_id.xml'

echo "All done. FMS should be ready to use.".
