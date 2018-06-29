#!/bin/sh

OUT=`pwd`/../../../../SuperTux-with-data.apk
rm -f $OUT $OUT-aligned
cp ../../../../project/app/build/outputs/apk/app-release.apk $OUT || exit 1
cd supertux/data || exit 1
zip -r -9 $OUT * || exit 1
zipalign 4 $OUT $OUT-aligned || exit 1
apksigner sign --ks ~/.android/debug.keystore --ks-key-alias androiddebugkey --ks-pass pass:android $OUT-aligned || exit 1
mv $OUT-aligned $OUT
