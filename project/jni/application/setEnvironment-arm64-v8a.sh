#!/bin/sh

IFS='
'

MYARCH=linux-x86_64
if uname -s | grep -i "linux" > /dev/null ; then
	MYARCH=linux-x86_64
fi
if uname -s | grep -i "darwin" > /dev/null ; then
	MYARCH=darwin-x86_64
fi
if uname -s | grep -i "windows" > /dev/null ; then
	MYARCH=windows-x86_64
fi

NDK=`which ndk-build`
NDK=`dirname $NDK`
NDK=`readlink -f $NDK`

#echo NDK $NDK
GCCPREFIX=aarch64-linux-android
[ -z "$NDK_TOOLCHAIN_VERSION" ] && NDK_TOOLCHAIN_VERSION=4.9
[ -z "$PLATFORMVER" ] && PLATFORMVER=android-21
LOCAL_PATH=`dirname $0`
if which realpath > /dev/null ; then
	LOCAL_PATH=`realpath $LOCAL_PATH`
else
	LOCAL_PATH=`cd $LOCAL_PATH && pwd`
fi
ARCH=arm64-v8a

APP_MODULES=`grep 'APP_MODULES [:][=]' $LOCAL_PATH/../Settings.mk | sed 's@.*[=]\(.*\)@\1@'`

APP_AVAILABLE_STATIC_LIBS="`echo '
include $(LOCAL_PATH)/../Settings.mk
all:
	@echo $(APP_AVAILABLE_STATIC_LIBS)
.PHONY: all' | make LOCAL_PATH=$LOCAL_PATH -s -f -`"

APP_SHARED_LIBS=$(
echo $APP_MODULES | xargs -n 1 echo | while read LIB ; do
	STATIC=`echo $APP_AVAILABLE_STATIC_LIBS application sdl_main stlport stdout-test | grep "\\\\b$LIB\\\\b"`
	if [ -n "$STATIC" ] ; then true
	else
		case $LIB in
			crypto) echo crypto.so.sdl.1;;
			ssl) echo ssl.so.sdl.1;;
			curl) echo curl-sdl;;
			expat) echo expat-sdl;;
			*) echo $LIB;;
		esac
	fi
done
)

if [ -z "$SHARED_LIBRARY_NAME" ]; then
	SHARED_LIBRARY_NAME=libapplication.so
fi
UNRESOLVED="-Wl,--no-undefined"
SHARED="-shared -Wl,-soname,$SHARED_LIBRARY_NAME"
if [ -n "$BUILD_EXECUTABLE" ]; then
	SHARED="-Wl,--gc-sections -Wl,-z,nocopyreloc -pie"
fi
if [ -n "$NO_SHARED_LIBS" ]; then
	APP_SHARED_LIBS=
fi
if [ -n "$ALLOW_UNRESOLVED_SYMBOLS" ]; then
	UNRESOLVED=
fi

APP_SHARED_LIBS="`echo $APP_SHARED_LIBS | sed \"s@\([-a-zA-Z0-9_.]\+\)@$LOCAL_PATH/../../obj/local/$ARCH/lib\1.so@g\"`"
APP_MODULES_INCLUDE="`echo $APP_MODULES | sed \"s@\([-a-zA-Z0-9_.]\+\)@-isystem$LOCAL_PATH/../\1/include@g\"`"

if [ -z "$CLANG" ]; then

CFLAGS="\
-fpic -ffunction-sections -funwind-tables -fstack-protector-strong \
-no-canonical-prefixes \
-O2 -g -DNDEBUG \
-fomit-frame-pointer -fno-strict-aliasing -finline-limit=300 \
-DANDROID -Wall -Wno-unused -Wa,--noexecstack -Wformat -Werror=format-security \
-isystem$NDK/sysroot/usr/include \
-isystem$NDK/sysroot/usr/include/aarch64-linux-android \
-D__ANDROID_API__=`echo $PLATFORMVER | grep -o '[0-9]*'` \
-isystem$NDK/sources/cxx-stl/gnu-libstdc++/$NDK_TOOLCHAIN_VERSION/include \
-isystem$NDK/sources/cxx-stl/gnu-libstdc++/$NDK_TOOLCHAIN_VERSION/libs/$ARCH/include \
-isystem$NDK/sources/cxx-stl/gnu-libstdc++/$NDK_TOOLCHAIN_VERSION/include/backward \
-isystem$LOCAL_PATH/../sdl-1.2/include \
$APP_MODULES_INCLUDE \
$CFLAGS"

LDFLAGS="\
$SHARED \
--sysroot=$NDK/platforms/$PLATFORMVER/arch-arm64 \
-L$LOCAL_PATH/../../obj/local/$ARCH \
$APP_SHARED_LIBS \
-L$NDK/platforms/$PLATFORMVER/arch-arm64/usr/lib \
-lc -lm -lGLESv1_CM -ldl -llog -lz \
-L$NDK/sources/cxx-stl/gnu-libstdc++/$NDK_TOOLCHAIN_VERSION/libs/$ARCH \
-lgnustl_static \
-no-canonical-prefixes $UNRESOLVED -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now \
-Wl,--build-id -Wl,--warn-shared-textrel -Wl,--fatal-warnings \
-lsupc++ \
$LDFLAGS"

CC="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-gcc"
CXX="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-g++"
CPP="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-cpp $CFLAGS"

else # CLANG

CFLAGS="
-ffunction-sections
-funwind-tables
-fstack-protector-strong
-Wno-invalid-command-line-argument
-Wno-unused-command-line-argument
-no-canonical-prefixes
-I$NDK/sources/cxx-stl/llvm-libc++/include
-I$NDK/sources/cxx-stl/llvm-libc++abi/include
-I$NDK/sources/android/support/include
-DANDROID
-Wa,--noexecstack
-Wformat
-Werror=format-security
-DNDEBUG
-O2
-g
-gcc-toolchain
$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/$MYARCH
-target
aarch64-none-linux-android
-fpic
--sysroot $NDK/platforms/android-21/arch-arm64
-isystem $NDK/sysroot/usr/include
-isystem $NDK/sysroot/usr/include/aarch64-linux-android
-D__ANDROID_API__=21
$APP_MODULES_INCLUDE
$CFLAGS"

CFLAGS="`echo $CFLAGS | tr '\n' ' '`"

LDFLAGS="
--sysroot $NDK/platforms/android-21/arch-arm64
$SHARED $UNRESOLVED
-L$LOCAL_PATH/../../obj/local/$ARCH
$APP_SHARED_LIBS
-L$NDK/sources/cxx-stl/llvm-libc++/libs/$ARCH
-L$NDK/sources/cxx-stl/llvm-libc++abi/../llvm-libc++/libs/$ARCH
-L$NDK/sources/android/support/../../cxx-stl/llvm-libc++/libs/$ARCH
$NDK/sources/cxx-stl/llvm-libc++/libs/$ARCH/libc++_static.a
$NDK/sources/cxx-stl/llvm-libc++abi/../llvm-libc++/libs/$ARCH/libc++abi.a
$NDK/sources/android/support/../../cxx-stl/llvm-libc++/libs/$ARCH/libandroid_support.a
-latomic -Wl,--exclude-libs,libatomic.a
-gcc-toolchain
$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/$MYARCH
-target aarch64-none-linux-android -no-canonical-prefixes
-Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel -Wl,--fatal-warnings
-lc -lm -lstdc++ -ldl -llog -lz
$LDFLAGS"

LDFLAGS="`echo $LDFLAGS | tr '\n' ' '`"

CC="$NDK/toolchains/llvm/prebuilt/$MYARCH/bin/clang"
CXX="$NDK/toolchains/llvm/prebuilt/$MYARCH/bin/clang++"
CPP="$CC -E $CFLAGS"

fi # CLANG

env PATH=$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin:$LOCAL_PATH:$PATH \
CFLAGS="$CFLAGS" \
CXXFLAGS="$CXXFLAGS $CFLAGS -frtti -fexceptions" \
LDFLAGS="$LDFLAGS" \
CC="$CC" \
CXX="$CXX" \
RANLIB="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-ranlib" \
LD="$CXX" \
AR="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-ar" \
CPP="$CPP" \
NM="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-nm" \
AS="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-as" \
STRIP="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-strip" \
"$@"
