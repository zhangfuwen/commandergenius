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
	SHARED="-Wl,--gc-sections -Wl,-z,nocopyreloc -pie -fpie"
fi
if [ -n "$NO_SHARED_LIBS" ]; then
	APP_SHARED_LIBS=
fi
if [ -n "$ALLOW_UNRESOLVED_SYMBOLS" ]; then
	UNRESOLVED=
fi

APP_SHARED_LIBS="`echo $APP_SHARED_LIBS | sed \"s@\([-a-zA-Z0-9_.]\+\)@$LOCAL_PATH/../../obj/local/$ARCH/lib\1.so@g\"`"
APP_MODULES_INCLUDE="`echo $APP_MODULES | sed \"s@\([-a-zA-Z0-9_.]\+\)@-isystem$LOCAL_PATH/../\1/include@g\"`"

CFLAGS="
--target=aarch64-none-linux-android21
--gcc-toolchain=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
--sysroot=$NDK/sysroot
-isystem
$NDK/sources/cxx-stl/llvm-libc++/include
-isystem
$NDK/sources/cxx-stl/llvm-libc++abi/include
-isystem
$NDK/sysroot/usr/include/aarch64-linux-android
-g
-DANDROID
-ffunction-sections
-funwind-tables
-fstack-protector-strong
-no-canonical-prefixes
-Wa,--noexecstack
-Wformat
-Werror=format-security
-O2
-DNDEBUG
-fPIC
$APP_MODULES_INCLUDE
$CFLAGS"

CFLAGS="`echo $CFLAGS | tr '\n' ' '`"

LDFLAGS="
--target=aarch64-none-linux-android21
--gcc-toolchain=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
--sysroot=$NDK/sysroot
-fPIC
-isystem
$NDK/sysroot/usr/include/aarch64-linux-android
-g
-DANDROID
-ffunction-sections
-funwind-tables
-fstack-protector-strong
-no-canonical-prefixes
-Wa,--noexecstack
-Wformat
-Werror=format-security
-O2
-DNDEBUG
-Wl,--exclude-libs,libgcc.a
-Wl,--exclude-libs,libatomic.a
-nostdlib++
--sysroot
$NDK/platforms/android-21/arch-arm64
-Wl,--build-id
-Wl,--warn-shared-textrel
-Wl,--fatal-warnings
-L$NDK/sources/cxx-stl/llvm-libc++/libs/arm64-v8a
-Wl,--no-undefined
-Wl,-z,noexecstack
-Qunused-arguments
-Wl,-z,relro
-Wl,-z,now
$SHARED $UNRESOLVED
$APP_SHARED_LIBS
-landroid
-llog
-latomic
-lm
$NDK/sources/cxx-stl/llvm-libc++/libs/arm64-v8a/libc++_static.a
$NDK/sources/cxx-stl/llvm-libc++/libs/arm64-v8a/libc++abi.a
$LDFLAGS"

LDFLAGS="`echo $LDFLAGS | tr '\n' ' '`"

CC="$NDK/toolchains/llvm/prebuilt/$MYARCH/bin/clang"
CXX="$NDK/toolchains/llvm/prebuilt/$MYARCH/bin/clang++"
CPP="$CC -E $CFLAGS"

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
