#!/bin/sh

#ARCH_LIST="arm64-v8a x86 mips armeabi-v7a armeabi"

#ARCH_LIST="arm x86 mips arm64"
ARCH_LIST="arm"

mkdir -p build

build() {		
	pushd python3-android
	if [ -f env ]; then 
           rm env 
        fi

	if [ -f mk/env.mk ]; then 
           rm mk/env.mk 
        fi
	 
	echo ANDROID_PLATFORM=$1 > env
	cat env.noarch >> env

	make all ANDROID_PLATFORM=$1
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


# Set some symbolic links for android ndk toolkit access
rm -rf include 
rm -rf lib

mkdir -p include
mkdir -p lib

pushd include
ln -s ../python3-android/build/13b-23-arm-linux-androideabi-4.9/include arm	
ln -s ../python3-android/build/13b-23-x86-4.9/include x86	
popd

pushd lib 
ln -s ../python3-android/build/13b-23-arm-linux-androideabi-4.9/lib arm
ln -s ../python3-android/build/13b-23-x86-4.9/lib x86
popd

