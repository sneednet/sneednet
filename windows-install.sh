#!/bin/bash

cd "$1"

pacman -S --noconfirm unzip

calculate_sha256() {
    shasum -a 256 "$1" | awk '{print $1}'
}

check_and_redownload_file() {
    echo "check_and_redownload_file called"
    local FILE_PATH=$1
    local EXPECTED_SIZE=$2
    local EXPECTED_HASH=$3
    local DOWNLOAD_URL=$4
    
    # Check if file exists
    echo "Checking if file $FILE_PATH exists."
    if [ ! -f "$FILE_PATH" ]; then
        echo "File does not exist at path: $FILE_PATH, downloading."
        wget --output-document="$FILE_PATH" "$DOWNLOAD_URL"
    else
        echo "File exists, checking size and hash."
    fi
    
    # Get actual details of the file
    ACTUAL_SIZE=$(stat -c%s "$FILE_PATH")
    ACTUAL_HASH=$(calculate_sha256 "$FILE_PATH")

    echo "ACTUAL_SIZE: $ACTUAL_SIZE"
    echo "EXPECTED_SIZE: $EXPECTED_SIZE"
    echo "ACTUAL_HASH: $ACTUAL_HASH"
    echo "EXPECTED_HASH: $EXPECTED_HASH"

    # Compare sizes and hashes
    if [[ "$ACTUAL_SIZE" == "$EXPECTED_SIZE" && "$ACTUAL_HASH" == "$EXPECTED_HASH" ]]; then
        echo "File $FILE_PATH has correct size and hash. Continuing."
        return 0
    else
        echo "File $FILE_PATH has incorrect size or hash."
        # If files do not match, rename and redownload
        TIMESTAMP=$(date +%s)
        NEW_FILENAME="${FILE_PATH}_corrupt_${TIMESTAMP}"
        mv "$FILE_PATH" "$NEW_FILENAME"
        
        echo "Downloading from URL: $DOWNLOAD_URL"
        wget --output-document="$FILE_PATH" "$DOWNLOAD_URL"
        
        # Recalculate hash and size after downloading
        ACTUAL_SIZE=$(stat -c%s "$FILE_PATH")
        ACTUAL_HASH=$(calculate_sha256 "$FILE_PATH")
        
        echo "ACTUAL_SIZE: $ACTUAL_SIZE"
        echo "EXPECTED_SIZE: $EXPECTED_SIZE"
        echo "ACTUAL_HASH: $ACTUAL_HASH"
        echo "EXPECTED_HASH: $EXPECTED_HASH"
        
        # Verify newly downloaded file
        if [[ "$ACTUAL_SIZE" == "$EXPECTED_SIZE" && "$ACTUAL_HASH" == "$EXPECTED_HASH" ]]; then
            echo "File $FILE_PATH has correct size and hash. Continuing."
            return 0
        else
            echo "Error: file $FILE_PATH has incorrect size or hash, exiting."
            exit 1
        fi
    fi
}

echo "saving freenet installer in folder "`pwd`
echo ""

wget -O FreenetInstaller-1498.exe "https://www.draketo.de/dateien/freenet/build01498/FreenetInstaller-1498.exe"
./FreenetInstaller-1498.exe &

echo "Advancing Freenet installer"
cscript windows-install-freenet.vbs

echo "Waiting 30s for Freenet to start."
sleep 30

echo "Extract the initialization wizard form password."
wget -O wizard_form.html http://127.0.0.1:8888/wiz/
form_password=$(grep -oP 'name="formPassword"\s*type="hidden"\s*value="\K[^"]+' wizard_form.html | head -1)
rm wizard_form.html


echo "form_password: $form_password"
sleep 5

echo "Setting unlimited bandwidth limit."
wget -O - --post-data="formPassword=$form_password&monthlyLimit=999999999&downLimit=976562&upLimit=976562&storage=5&password=&confirmPassword=" "http://127.0.0.1:8888/wiz/" > /dev/null

echo "Waiting 20s for settings to be applied."
sleep 20

curl 'http://127.0.0.1:8888/CHK@NvT50rE2pz9bne9O-OE~GFY8z-JKul8NoxUDHWv7Evc,yQNgly4kq6WX4pT8A821R4fuOnZUroxi~8vtM1JAehg,AAMC--8/fms-linux-x86-bin-0.3.85.tar.gz' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-User: ?1' > download_form.html && form_password=$(grep -oP 'name="formPassword"\s*type="hidden"\s*value="\K[^"]+' download_form.html | head -1) && echo "form_password: $form_password" && curl --user-agent 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:131.0) Gecko/20100101 Firefox/131.0' -X POST 'http://127.0.0.1:8888/downloads/' -H 'Content-Type: multipart/form-data' -F "formPassword=$form_password" -F "key=CHK@NvT50rE2pz9bne9O-OE~GFY8z-JKul8NoxUDHWv7Evc,yQNgly4kq6WX4pT8A821R4fuOnZUroxi~8vtM1JAehg,AAMC--8/fms-linux-x86-bin-0.3.85.tar.gz" -F "return-type=direct" -F "persistence=forever" -F "download=Fetch" -F "filterData=filterData"

echo "Waiting 20s for FMS download request to be registered." 
sleep 20

curl http://127.0.0.1:8888/downloads/ > download_form.html && form_password=$(grep -oP 'name="formPassword"\s*type="hidden"\s*value="\K[^"]+' download_form.html | head -1) && echo "form_password: $form_password" && curl -X POST http://127.0.0.1:8888/downloads/ -H 'Content-Type: multipart/form-data' -F "formPassword=$form_password" -F 'restart_request=Restart' -F 'disableFilterData=disableFilterData' -F 'identifier-0= FProxy:fms-linux-x86-bin-0.3.85.tar.gz' -F 'key-0=freenet:CHK@NvT50rE2pz9bne9O-OE~GFY8z-JKul8NoxUDHWv7Evc,yQNgly4kq6WX4pT8A821R4fuOnZUroxi~8vtM1JAehg,AAMC--8/fms-linux-x86-bin-0.3.85.tar.gz' -F 'filename-0=fms-linux-x86-bin-0.3.85.tar.gz'

echo ""
echo "Waiting 15s for web interface FMS download to start."
sleep 15

echo "Downloading FMS. This could take a few minutes. Please be patient."
./windows_download_FMS.sh

./windows_install_fms.sh

read -p "Press the Enter key to continue."
