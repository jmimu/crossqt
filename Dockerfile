FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --fix-missing \
    wget unzip build-essential pkg-config libboost-all-dev qttools5-dev-tools qt5-default git \
    doxygen sqlite libsqlite3-dev fuse

#set locale
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

#get proj
RUN cd / && \
    wget https://download.osgeo.org/proj/proj-6.1.1.tar.gz  && \
    tar -xf proj-6.1.1.tar.gz  && \
    cd proj-6.1.1  && \
    ./configure --prefix=/usr/local/proj61/ --enable-static --disable-shared  && \
    make clean  && \
    make -j5  && \
    make install

#get proj data
RUN cd / && \
    wget https://download.osgeo.org/proj/proj-datumgrid-1.8.zip && \
    unzip proj-datumgrid-1.8.zip -d proj-data && \
    mkdir -p /usr/local/proj61/share/proj/ && \
    cp proj-data/* /usr/local/proj61/share/proj/

#add mxe
RUN apt-get -y --fix-missing  install software-properties-common curl && \
    curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x86B72ED9' | apt-key add - && \
    add-apt-repository 'deb [arch=amd64] http://mirror.mxe.cc/repos/apt bionic main' && \
    apt-get update

RUN apt-get install -y --fix-missing mxe-x86-64-w64-mingw32.static-qt5 \
    mxe-x86-64-w64-mingw32.static-boost

#proj for mxe
RUN cd /proj-6.1.1 && \
    export PATH=/usr/lib/mxe/usr/bin/:$PATH && \
    ./configure --host=x86_64-w64-mingw32.static --enable-static --disable-shared --prefix=/usr/lib/mxe/usr/i686-w64-mingw32.static/ && \
    make clean  && \
    make -j5  && \
    make install

#get eigen
RUN cd / && \
    wget https://gitlab.com/libeigen/eigen/-/archive/3.3.8/eigen-3.3.8.tar.gz  && \
    tar -xf eigen-3.3.8.tar.gz  && \
    mkdir -p /usr/local/include/eigen3  && \
    cp -R eigen-3.3.8/Eigen/ /usr/local/include/eigen3/Eigen/  && \
    mkdir -p /usr/lib/mxe/usr/i686-w64-mingw32.static/include/eigen3  && \
    cp -R eigen-3.3.8/Eigen/ /usr/lib/mxe/usr/i686-w64-mingw32.static/include/eigen3/Eigen/

#get appimage
RUN cd / && \
    wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage && \
    wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage && \
    chmod a+x *.AppImage

#get wine
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install --no-install-recommends --assume-yes wine-stable

#get pip3
RUN apt-get install -y --fix-missing python3-pip

#get sphinx
RUN pip3 install sphinx sphinx-intl sphinx-mathjax-offline
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --fix-missing  install python3-stemmer qttranslations5-l10n libjs-mathjax

#set rights for created files
RUN echo "umask 0000" >> /root/.bashrc

#access local X11 server
ENV DISPLAY :0
