C++/Qt cross compilation environment
====================================

Tools and libs for c++ compilation and packaging on linux and windows.

Features
--------

Based on ubuntu:18.04.

Libs: boost qt5 sqlite proj eigen
Documentation: doxygen sphinx
Packaging: zip dpkg-deb appimage 
Cross compilation: xme 
Running tests: wine


Install docker if needed
------------------------

    sudo apt install docker.io
    sudo usermod -aG docker $USER

Then close and re-open session.


Setup proxy
-----------

If ou are behind a proxy:

    mkdir -p ~/.docker
    echo '{"proxies":{"default":{"httpProxy": "http://YOURPROXY:PORT","httpsProxy": "http://YOURPROXY:PORT", "noProxy": "localhost,127.0.0.1"}}}' > ~/.docker/config.json

And set YOURPROXY:PORT in ~/.docker/config.json

It may be necessary to add a systemd configuration as root:

    sudo mkdir /etc/systemd/system/docker.service.d
    echo '[Service]
    Environment="HTTP_PROXY=http://YOURPROXY:PORT/"
    Environment="HTTPS_PROXY=http://YOURPROXY:PORT/"
    Environment="NO_PROXY=localhost,127.0.0.1"' > tmp.conf
    sudo mv tmp.conf /etc/systemd/system/docker.service.d/http-proxy.conf
    sudo systemctl daemon-reload
    sudo systemctl restart docker.service


Build docker image
------------------

    docker build --network=host -t crossqt1804 .

It needs 2 GB of disk space.


Run image
---------
Create a compile_all.sh that will run every compilation and packaging step (see compile_all_example.sh).
Make sure to have a "install" target in your makefile in order to use AppImage.

On host system, from the project source folder, run:

    docker run --rm --device /dev/fuse --privileged -v $(pwd)/.:/src crossqt1804 /src/compile_all.sh

For interactive compilation:

    docker run -ti --rm --device /dev/fuse --privileged -v $(pwd)/.:/src crossqt1804 bash


Remove docker image
-------------------

    docker rmi crossqt1804
