# Installation instructions

1. Install dependencies. We need wget to download files, curl for POST requests and the ar command from the binutils package to unpack .deb files. And we need to install libc and a few other libraries for the x86 architecture.

   For this, in Ubuntu 22.04, run:

   sudo dpkg --add-architecture i386
   
   sudo apt-get update
   
   sudo apt-get install libc6:i386 libstdc++6:i386 zlib1g:i386 lzma:i386 wget curl binutils

3. Download the github code as a .zip and extract it.

4. Run the script install.sh and wait.

5. Access Freenet through:
  
   http://127.0.0.1:8888

   and FMS through:

   http://127.0.0.1:8080
