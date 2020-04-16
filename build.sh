#!/bin/sh
#set -eu # Bashism, does not work with default shell on Ubuntu 12.04

install_apk=false
run_apk=false
sign_apk=false
build_release=true
quick_rebuild=false
QUICK_REBUILD_ARGS=

if [ "$#" -gt 0 -a "$1" = "-s" ]; then
	shift
	sign_apk=true
fi

if [ "$#" -gt 0 -a "$1" = "-i" ]; then
	shift
	install_apk=true
fi

if [ "$#" -gt 0 -a "$1" = "-r" ]; then
	shift
	install_apk=true
	run_apk=true
fi

if [ "$#" -gt 0 -a "$1" = "-q" ]; then
	shift
	quick_rebuild=true
	QUICK_REBUILD_ARGS=APP_ABI=armeabi-v7a
fi

if [ "$#" -gt 0 -a "$1" = "release" ]; then
	shift
	build_release=true
fi

if [ "$#" -gt 0 -a "$1" = "debug" ]; then
	shift
	build_release=false
	export NDK_DEBUG=1
fi

if [ "$#" -gt 0 -a "$1" '!=' "-h" ]; then
	echo "Switching build target to $1"
	if [ -e project/jni/application/$1 ]; then
		rm -f project/jni/application/src
		ln -s "$1" project/jni/application/src
	else
		echo "Error: no app $1 under project/jni/application"
		echo "Available applications:"
		cd project/jni/application
		for f in *; do
			if [ -e "$f/AndroidAppSettings.cfg" ]; then
				echo "$f"
			fi
		done
		exit 1
	fi
	shift
fi

if [ "$#" -gt 0 -a "$1" = "-h" ]; then
	echo "Usage: $0 [-s] [-i] [-r] [-q] [debug|release] [app-name]"
	echo "    -s:       sign APK file after building"
	echo "    -i:       install APK file to device after building"
	echo "    -r:       run APK file on device after building"
	echo "    -q:       quick-rebuild C code, without rebuilding Java files"
	echo "    debug:    build debug package"
	echo "    release:  build release package (default)"
	echo "    app-name: directory under project/jni/application to be compiled"
	exit 0
fi

NDK_TOOLCHAIN_VERSION=$GCCVER
[ -z "$NDK_TOOLCHAIN_VERSION" ] && NDK_TOOLCHAIN_VERSION=4.9

# Set here your own NDK path if needed
# export PATH=$PATH:~/src/endless_space/android-ndk-r7
NDKBUILDPATH=$PATH
export `grep "AppFullName=" AndroidAppSettings.cfg`
if [ -e project/local.properties ] && \
	( grep "package $AppFullName;" project/src/Globals.java > /dev/null 2>&1 && \
	[ "`readlink AndroidAppSettings.cfg`" -ot "project/src/Globals.java" ] && \
	[ -z "`find project/java/* project/AndroidManifestTemplate.xml -cnewer project/src/Globals.java`" ] ) ; then true ; else
	./changeAppSettings.sh -a || exit 1
	sleep 1
	touch project/src/Globals.java
fi

MYARCH=linux-x86_64
if [ -z "$NCPU" ]; then
	NCPU=4
	if uname -s | grep -i "linux" > /dev/null ; then
		MYARCH=linux-x86_64
		NCPU=`cat /proc/cpuinfo | grep -c -i processor`
	fi
	if uname -s | grep -i "darwin" > /dev/null ; then
		MYARCH=darwin-x86_64
	fi
	if uname -s | grep -i "windows" > /dev/null ; then
		MYARCH=windows-x86_64
	fi
fi

$quick_rebuild || rm -r -f project/bin/* # New Android SDK introduced some lame-ass optimizations to the build system which we should take care about
[ -x project/jni/application/src/AndroidPreBuild.sh ] && {
	cd project/jni/application/src
	./AndroidPreBuild.sh || { echo "AndroidPreBuild.sh returned with error" ; exit 1 ; }
	cd ../../../..
}

strip_libs() {
	grep "CustomBuildScript=y" ../AndroidAppSettings.cfg > /dev/null && \
		grep "MultiABI=" ../AndroidAppSettings.cfg | grep "y\\|all\\|armeabi-v7a" > /dev/null && \
		echo Stripping libapplication-armeabi-v7a.so by hand && \
		rm obj/local/armeabi-v7a/libapplication.so && \
		cp jni/application/src/libapplication-armeabi-v7a.so obj/local/armeabi-v7a/libapplication.so && \
		cp jni/application/src/libapplication-armeabi-v7a.so libs/armeabi-v7a/libapplication.so && \
		`which ndk-build | sed 's@/ndk-build@@'`/toolchains/arm-linux-androideabi-${NDK_TOOLCHAIN_VERSION}/prebuilt/$MYARCH/bin/arm-linux-androideabi-strip --strip-unneeded libs/armeabi-v7a/libapplication.so
	grep "CustomBuildScript=y" ../AndroidAppSettings.cfg > /dev/null && \
		grep "MultiABI=" ../AndroidAppSettings.cfg | grep "all\\|x86" > /dev/null && \
		echo Stripping libapplication-x86.so by hand && \
		rm obj/local/x86/libapplication.so && \
		cp jni/application/src/libapplication-x86.so obj/local/x86/libapplication.so && \
		cp jni/application/src/libapplication-x86.so libs/x86/libapplication.so && \
		`which ndk-build | sed 's@/ndk-build@@'`/toolchains/x86-${NDK_TOOLCHAIN_VERSION}/prebuilt/$MYARCH/bin/i686-linux-android-strip --strip-unneeded libs/x86/libapplication.so
	grep "CustomBuildScript=y" ../AndroidAppSettings.cfg > /dev/null && \
		grep "MultiABI=" ../AndroidAppSettings.cfg | grep "all\\|x86_64" > /dev/null && \
		echo Stripping libapplication-x86_64.so by hand && \
		rm obj/local/x86_64/libapplication.so && \
		cp jni/application/src/libapplication-x86_64.so obj/local/x86_64/libapplication.so && \
		cp jni/application/src/libapplication-x86_64.so libs/x86_64/libapplication.so && \
		`which ndk-build | sed 's@/ndk-build@@'`/toolchains/x86_64-${NDK_TOOLCHAIN_VERSION}/prebuilt/$MYARCH/bin/x86_64-linux-android-strip --strip-unneeded libs/x86_64/libapplication.so
	grep "CustomBuildScript=y" ../AndroidAppSettings.cfg > /dev/null && \
		grep "MultiABI=" ../AndroidAppSettings.cfg | grep "all\\|arm64-v8a" > /dev/null && \
		echo Stripping libapplication-arm64-v8a.so by hand && \
		rm obj/local/arm64-v8a/libapplication.so && \
		cp jni/application/src/libapplication-arm64-v8a.so obj/local/arm64-v8a/libapplication.so && \
		cp jni/application/src/libapplication-arm64-v8a.so libs/arm64-v8a/libapplication.so && \
		`which ndk-build | sed 's@/ndk-build@@'`/toolchains/aarch64-linux-android-${NDK_TOOLCHAIN_VERSION}/prebuilt/$MYARCH/bin/aarch64-linux-android-strip --strip-unneeded libs/arm64-v8a/libapplication.so
	return 0
}

# Fix Gradle compilation error
[ -z "$ANDROID_NDK_HOME" ] && export ANDROID_NDK_HOME="`which ndk-build | sed 's@/ndk-build@@'`"

cd project && env PATH=$NDKBUILDPATH BUILD_NUM_CPUS=$NCPU ndk-build -j$NCPU V=1 $QUICK_REBUILD_ARGS && \
	strip_libs && \
	cd .. && ./copyAssets.sh && cd project && \
	{	if $build_release ; then \
			$quick_rebuild && { \
				zip -u -r app/build/outputs/apk/release/app-release-unsigned.apk lib assets || exit 1 ; \
			} || ./gradlew assembleRelease || exit 1 ; \
			[ '!' -x jni/application/src/AndroidPostBuild.sh ] || {
				cd jni/application/src ; \
				./AndroidPostBuild.sh `pwd`/../../../app/build/outputs/apk/release/app-release-unsigned.apk || exit 1 ; \
				cd ../../.. ; \
			} || exit 1 ; \
			../copyAssets.sh pack-binaries app/build/outputs/apk/release/app-release-unsigned.apk ; \
			rm -f app/build/outputs/apk/release/app-release.apk ; \
			zipalign 4 app/build/outputs/apk/release/app-release-unsigned.apk app/build/outputs/apk/release/app-release.apk || exit 1 ; \
			apksigner sign --ks ~/.android/debug.keystore --ks-key-alias androiddebugkey --ks-pass pass:android app/build/outputs/apk/release/app-release.apk || exit 1 ; \
		else \
			./gradlew assembleDebug || exit 1 ; \
			[ '!' -x jni/application/src/AndroidPostBuild.sh ] || {
				cd jni/application/src ; \
				./AndroidPostBuild.sh `pwd`/../../../app/build/outputs/apk/debug/app-debug.apk || exit 1 ; \
				cd ../../.. ; \
			} || exit 1 ; \
			mkdir -p app/build/outputs/apk/release ; \
			../copyAssets.sh pack-binaries app/build/outputs/apk/debug/app-debug.apk && \
			rm -f app/build/outputs/apk/release/app-release.apk && \
			zipalign 4 app/build/outputs/apk/debug/app-debug.apk app/build/outputs/apk/release/app-release.apk &&
			apksigner sign --ks ~/.android/debug.keystore --ks-key-alias androiddebugkey --ks-pass pass:android app/build/outputs/apk/release/app-release.apk || exit 1 ; \
		fi ; } && \
	{	if $sign_apk; then cd .. && ./sign.sh && cd project ; else true ; fi ; } && \
	{	$install_apk && [ -n "`adb devices | tail -n +2`" ] && \
		{	if $sign_apk; then \
				APPNAME=`grep AppName ../AndroidAppSettings.cfg | sed 's/.*=//' | tr -d '"' | tr " '/" '---'` ; \
				APPVER=`grep AppVersionName ../AndroidAppSettings.cfg | sed 's/.*=//' | tr -d '"' | tr " '/" '---'` ; \
				adb install -r ../$APPNAME-$APPVER.apk ; \
			else \
				adb install -r app/build/outputs/apk/release/app-release.apk ; \
			fi ; } ; \
		true ; } && \
	{	$run_apk && { \
			ActivityName="`grep AppFullName ../AndroidAppSettings.cfg | sed 's/.*=//'`/.MainActivity" ; \
			RUN_APK="adb shell am start -n $ActivityName" ; \
			echo "Running $ActivityName on the USB-connected device:" ; \
			echo "$RUN_APK" ; \
			eval $RUN_APK ; } ; \
		true ; } || exit 1
