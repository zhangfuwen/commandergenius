#!/bin/sh

LOCAL_PATH=`dirname $0`
LOCAL_PATH=`cd $LOCAL_PATH && pwd`

NDK_PATH=`which ndk-build | sed 's@/ndk-build@@'`

cd src
mkdir -p out-$1
cd out-$1

cmake .. \
-DCMAKE_TOOLCHAIN_FILE=$NDK_PATH/build/cmake/android.toolchain.cmake -DANDROID_ABI=$1 \
-DX11=No -DLIBZIP_BUILTIN=Yes -DDEBUG=No -DHASBFD=No -DDISABLE_JOYSTICK=Yes \
 || exit 1

NCPU=4
uname -s | grep -i "linux" > /dev/null && NCPU=`cat /proc/cpuinfo | grep -c -i processor`

make -j$NCPU || exit 1

cp -f bin/openlierox ../../libapplication-$1.so || exit 1
