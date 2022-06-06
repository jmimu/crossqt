#! /bin/bash

set -e
set -x
umask 0000
export PATH=/usr/lib/mxe/usr/bin/:$PATH

NBRP=$(cat /proc/cpuinfo | grep processor | wc -l)
GREEN='\033[0;32m'
STOP='\033[0m'

echo -e "${GREEN}Compile doc${STOP}"
cd /src/doc_uni
./build_doc.sh

echo -e "${GREEN}Remove all${STOP}"
rm -Rf /src/autobuild/ /src/autobuild-mxe/ /src/tests/autobuild/ /src/tests/autobuild-mxe/

echo -e "${GREEN}Linux compilation${STOP}"
cd /src/
lrelease example.pro
mkdir -p autobuild/
cd autobuild/
qmake ../example.pro CONFIG+=release
make clean
make -j$NBRP

echo -e "${GREEN}Copy AppImage tools...${STOP}"
cp /linuxdeploy-x86_64.AppImage /src/
cp /linuxdeploy-plugin-qt-x86_64.AppImage /src/

echo -e "${GREEN}Creating AppImage...${STOP}"
cd /src/
distrib/make_appimage.sh  /src/autobuild/
distrib/make_ziplinux.sh example.AppImage

echo -e "${GREEN}Creating deb package...${STOP}"
cd /src/
distrib/make_appimagedeb.sh example.AppImage


echo -e "${GREEN}Windows cross-compilation${STOP}"
cd /src/
mkdir -p autobuild-mxe/
cd autobuild-mxe/
x86_64-w64-mingw32.static-qmake-qt5 ../example.pro
make clean
make -j$NBRP
cp -R /usr/local/proj61/share/proj/ release/proj

echo -e "${GREEN}Creating windows zip...${STOP}"
cd /src/
distrib/make_zipwin.sh autobuild-mxe/

echo -e "${GREEN}Compile tests on linux...${STOP}"
cd /src/tests/
mkdir -p autobuild/
cd autobuild/
qmake ../tests.pro
make clean
make -j$NBRP
cd ..
echo -e "${GREEN}Run tests on linux...${STOP}"
autobuild/tests
echo -e "${GREEN}Linux tests finished, no errors.${STOP}"

echo -e "${GREEN}Compile tests on wine...${STOP}"
cd /src/tests/
mkdir -p autobuild-mxe/
cd autobuild-mxe/
x86_64-w64-mingw32.static-qmake-qt5 ../tests.pro
make clean
make -j$NBRP
cd ..
echo -e "${GREEN}Run tests on wine...${STOP}"
wine autobuild-mxe/release/tests.exe
echo -e "${GREEN}Wine tests finished, no errors.${STOP}"

#to see all messages on wine tests outside docker, run:
#wine start /wait autobuild-mxe/release/tests.exe
