#!/bin/sh

ARCHES="arm64-v8a armeabi-v7a x86 x86_64"

if [ "$1" = "pack-binaries" ]; then
echo "Copying binaries.zip to .apk file"
COPIED=1
for ARCH in $ARCHES; do
	[ -e lib/$ARCH/binaries.zip ] && zip "$2" lib/$ARCH/binaries.zip && COPIED=0
done
exit $COPIED
fi

echo "Copying app data files from project/jni/application/src/AndroidData to project/assets"
mkdir -p project/assets
rm -f -r project/assets/*
if [ -d "project/jni/application/src/AndroidData" ] ; then
	cp -L -r project/jni/application/src/AndroidData/* project/assets/
fi

for ARCH in $ARCHES; do
	mv project/assets/binaries-$ARCH.zip project/libs/$ARCH/binaries.zip 2>/dev/null
done

exit 0
