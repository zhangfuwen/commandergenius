#!/bin/sh

CURDIR=`pwd`

PACKAGE_NAME=`grep AppFullName AndroidAppSettings.cfg | sed 's/.*=//'`

if [ -e pulseaudio/android-build.sh ]; then
	[ -e pulseaudio/$1/install/bin/pulseaudio ] || {
		cd pulseaudio
		./android-build.sh || exit 1
		cd ..
	} || exit 1
fi

../setEnvironment-$1.sh sh -c '\
$CC $CFLAGS -Werror=format -c main.c -o main-'"$1.o" || exit 1
../setEnvironment-$1.sh sh -c '\
$CC $CFLAGS -Werror=format -c gfx.c -o gfx-'"$1.o" || exit 1

[ -e ../../../lib ] || ln -s libs ../../../lib

[ -e xserver/android ] || {
	CURDIR=`pwd`
	cd ../../../..
	git submodule update --init project/jni/application/xserver/xserver || exit 1
	cd $CURDIR
} || exit 1
cd xserver
[ -e configure ] || autoreconf --force -v --install || exit 1
[ -e android/android-shmem/LICENSE ] || git submodule update --init android/android-shmem || exit 1
cd android
[ -e android-shmem/libancillary/ancillary.h ] || {
	cd android-shmem
	git submodule update --init libancillary || exit 1
	cd ..
} || exit 1
cd $1

# Megahack: set /proc/self/cwd as the X.org data dir, and chdir() to the correct directory when runngin X.org
env TARGET_DIR=/proc/self/cwd \
./build.sh || exit 1

env CURDIR=$CURDIR \
../../../../setEnvironment-$1.sh sh -c 'set -x ; \
$CC $CFLAGS $LDFLAGS -o $CURDIR/libapplication-'"$1.so"' -L. \
$CURDIR/main-'"$1.o"' \
$CURDIR/gfx-'"$1.o"' \
hw/kdrive/sdl/sdl*.o \
dix/.libs/libdix.a \
hw/kdrive/src/.libs/libkdrive.a \
fb/.libs/libfb.a \
mi/.libs/libmi.a \
xfixes/.libs/libxfixes.a \
Xext/.libs/libXext.a \
dbe/.libs/libdbe.a \
record/.libs/librecord.a \
randr/.libs/librandr.a \
render/.libs/librender.a \
damageext/.libs/libdamageext.a \
dri3/.libs/libdri3.a \
present/.libs/libpresent.a \
miext/sync/.libs/libsync.a \
miext/damage/.libs/libdamage.a \
miext/shadow/.libs/libshadow.a \
Xi/.libs/libXi.a \
xkb/.libs/libxkb.a \
xkb/.libs/libxkbstubs.a \
composite/.libs/libcomposite.a \
os/.libs/libos.a \
-L$CURDIR/../../../libs/'"$1"' \
-lpixman-1 -lXfont2 -lXau -lxshmfence -lXdmcp -lfontenc -lfreetype -lsdl_savepng -lpng \
-llog -lsdl-1.2 -lsdl_native_helpers -lGLESv1_CM -landroid-shmem -l:libcrypto.so.sdl.1.so -lz -lm -ldl' \
|| exit 1

rm -rf $CURDIR/tmp-$1
mkdir -p $CURDIR/tmp-$1
cd $CURDIR/tmp-$1
cp -f $CURDIR/xserver/data/busybox-$1 ./busybox
for f in xhost xkbcomp xloadimage xsel; do cp -f $CURDIR/xserver/android/$1/$f ./$f ; done
# Statically-linked prebuilt executables, generated using Debian chroot.

cp -f $CURDIR/pulseaudio/$1/install/bin/pulseaudio ./
cp -f $CURDIR/pulseaudio/$1/install/lib/*.so ./
cp -f $CURDIR/pulseaudio/$1/install/lib/pulseaudio/*.so ./
cp -f $CURDIR/pulseaudio/$1/install/lib/pulse-*/modules/*.so ./
cp -f $CURDIR/pulseaudio/$1/*/install/lib/*.so ./

rm -f ../AndroidData/binaries-$1.zip
rm -rf ../AndroidData/lib
mkdir -p ../AndroidData/lib/$1
cp -a . ../AndroidData/lib/$1

exit 0
