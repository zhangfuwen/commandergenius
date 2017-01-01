#!/bin/sh

#ARCH_LIST="arm64-v8a x86 mips armeabi-v7a armeabi"

ARCH_LIST="arm x86 mips"

mkdir -p build

build() {
	export 	ANDROID_PLATFORM=$1

	pushd python3-android
	make
	popd
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
#rm -rf include
#cp -r -L build/armeabi-v7a/include ./ || exit 1
