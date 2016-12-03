#!/bin/sh

#ARCH_LIST="arm64-v8a x86 mips armeabi-v7a armeabi"

ARCH_LIST="armeabi"

mkdir -p build

build() {
	ARCH=$1
	case $ARCH in
		armeabi-v7a)
			CONFIGURE_ARCH=android-armv7;;
		armeabi)
			CONFIGURE_ARCH=android;;
		arm64-v8a)
			CONFIGURE_ARCH=android;;
		*)
			CONFIGURE_ARCH=android-$ARCH;;
	esac

#	rm -rf build/$ARCH
#	mkdir -p build/$ARCH
#	cd build/$ARCH

#	echo ac_cv_file__dev_ptmx=no > ./config.site
#	echo ac_cv_file__dev_ptc=no >> ./config.site
#	export CONFIG_SITE=config.site

#	tar -x -v -J -f ../../Python-3.5.2.tar.xz --strip=1
	#sed -i.old 's/-Wl,-soname=[$][$]SHLIB[$][$]SHLIB_SOVER[$][$]SHLIB_SUFFIX//g' Makefile.shared
#	../../setCrossEnvironment-$ARCH.sh ./configure --prefix=`pwd`/dist  --host=arm-linux-androideabi --build=x64-unknown-linux --disable-ipv6  CFLAGS="-DANDROID -DPY_FORMAT_LONG_LONG"  || exit 1

# --host=$CONFIGURE_ARCH 

      #CONFIG_SITE=config.site ./configure --build=x86-unknown-linux-gnu --host=$CROSS_COMPILE --disable-ipv6 LDFLAGS="-Wl,--allow-shlib-undefined -L$SYSROOT/usr/lib" CFLAGS="-mandroid -fomit-frame-pointer --sysroot $SYSROOT"

#	../../setCrossEnvironment-$ARCH.sh make CALC_VERSIONS='SHLIB_COMPAT=; SHLIB_SOVER=.sdl.1.so'

#	cd ../..

#	rm -rf lib-$ARCH
#	mkdir -p lib-$ARCH
#	cp build/$ARCH/libcrypto.so.sdl.1.so lib-${ARCH}/libcrypto.so.sdl.1.so || exit 1
	./setCrossEnvironment-$ARCH.sh make
}

PIDS=""
for ARCH in $ARCH_LIST; do
	build $ARCH &
	PIDS="$PIDS $!"
done

for PID in $PIDS; do
	wait $PID || exit 1
done

# Provide includes for the to be built apps
rm -rf include
cp -r -L build/armeabi-v7a/include ./ || exit 1
