#!/bin/sh

ARCH_LIST="arm64-v8a x86_64 x86 armeabi-v7a"
ARCH_LIST="armeabi-v7a"

PARALLEL=true

mkdir -p build

build() {
	ARCH=$1

	case $ARCH in
		armeabi-v7a)
			export CONFIGURE_ARCH=android;;
		x86)
			export CONFIGURE_ARCH=android;;
		arm64-v8a)
			export CONFIGURE_ARCH=android64;;
		x86_64)
			export CONFIGURE_ARCH=android64;;
		*)
			echo "Arch $ARCH not defined"
			exit 1;;
	esac

	rm -rf build/$ARCH
	mkdir -p build/$ARCH
	cd build/$ARCH

	tar -x -v -z -f ../../openssl-1.1.0h.tar.gz --strip=1

	NDK=`which ndk-build`
	NDK=`dirname $NDK`
	NDK=`readlink -f $NDK`
	export CROSS_SYSROOT=$NDK/sysroot/usr

	../../setCrossEnvironment-$ARCH.sh sh -c './Configure shared zlib --prefix=`pwd`/dist --openssldir=. $CONFIGURE_ARCH -fPIC' || exit 1

	sed -i.old 's/^CFLAGS=/CFLAGS:=$(CFLAGS) /' Makefile
	sed -i.old 's/-mandroid//g' Makefile
	sed -i.old 's/--sysroot=$(CROSS_SYSROOT)//g' Makefile

	# OpenSSL build system disables parallel compilation, -j4 won't do anything
	../../setCrossEnvironment-$ARCH.sh make SHLIB_MAJOR=sdl SHLIB_MINOR=1.so

	cd ../..

	rm -rf lib-$ARCH
	mkdir -p lib-$ARCH
	cp build/$ARCH/libcrypto.so.sdl.1.so lib-${ARCH}/libcrypto.so.sdl.1.so || exit 1
	cp build/$ARCH/libssl.so.sdl.1.so lib-${ARCH}/libssl.so.sdl.1.so || exit 1
}


if $PARALLEL; then
	PIDS=""
	for ARCH in $ARCH_LIST; do
		build $ARCH &
		PIDS="$PIDS $!"
	done

	for PID in $PIDS; do
		wait $PID || exit 1
	done
else
	for ARCH in $ARCH_LIST; do
		build $ARCH || exit 1
	done
fi

rm -rf include
mkdir -p include
cp -r -L build/armeabi-v7a/include/openssl include/openssl || exit 1
patch -p0 < opensslconf.h.patch || exit 1
sed -i.tmp 's@".*/dist/.*"@"."@g' include/openssl/opensslconf.h
rm -f include/openssl/opensslconf.h.tmp
