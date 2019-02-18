You will need to install some packages to your Debian/Ubuntu first.

Install following packages, assuming fresh Debian 9 installation for x86_64 architecture:

sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install bison libpixman-1-dev libxfont-dev libxkbfile-dev libpciaccess-dev xutils-dev \
xcb-proto python-xcbgen xsltproc x11proto-bigreqs-dev x11proto-composite-dev x11proto-core-dev \
x11proto-damage-dev x11proto-dmx-dev x11proto-dri2-dev x11proto-fixes-dev x11proto-fonts-dev \
x11proto-gl-dev x11proto-input-dev x11proto-kb-dev x11proto-print-dev x11proto-randr-dev \
x11proto-record-dev x11proto-render-dev x11proto-resource-dev x11proto-scrnsaver-dev \
x11proto-video-dev x11proto-xcmisc-dev x11proto-xext-dev x11proto-xf86bigfont-dev \
x11proto-xf86dga-dev x11proto-xf86dri-dev x11proto-xf86vidmode-dev x11proto-xinerama-dev \
libxmuu-dev libxt-dev libsm-dev libice-dev libxrender-dev libxrandr-dev xfonts-utils \
curl autoconf autoconf2.59 automake automake1.11 libtool libtool-bin pkg-config \
libjpeg-dev libpng-dev git mc locales \
openjdk-8-jdk ant make zip libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386

Install Android NDK r11c and Android SDK with Android 6.0 framework, they must be in your $PATH.

Download SDL repo, select xserver project, and build it:

git clone git@github.com:pelya/commandergenius.git sdl-android
cd sdl-android
git submodule update --init --recursive
rm -f project/jni/application/src
ln -s xserver project/jni/application/src
./build.sh

That's all.
