#!/bin/sh

ARCHES="arm64-v8a armeabi-v7a x86 x86_64"

if [ "$1" = "pack-binaries" ]; then
[ -e jni/application/src/AndroidData/lib ] || exit 0
[ -e jni/application/src/AndroidData/binaries*.zip ] && {
	echo "Error: binaries.zip no longer supported in Android 10"
	echo "Copy your executable binaries to AndroidData/lib/arm64-v8a"
	echo "Then execute them using \$LIBDIR or getenv(\"LIBDIR\")"
	exit 0
}
APK="`pwd`/$2"
echo "Copying binaries to .apk file"
cd jni/application/src/AndroidData/ || exit 1
zip -r "$APK" lib || exit 1
cd ../../../../
exit 0
fi

echo "Copying app data files from project/jni/application/src/AndroidData to project/assets"
mkdir -p project/assets
rm -f -r project/assets/*
if [ -d "project/jni/application/src/AndroidData" ] ; then
	cp -L -r project/jni/application/src/AndroidData/* project/assets/
	rm -rf project/assets/lib
fi

exit 0
