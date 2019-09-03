#!/bin/sh
# Set path to your Android keystore and your keystore alias here, or put them in your environment
[ -z "$ANDROID_KEYSTORE_FILE" ] && ANDROID_KEYSTORE_FILE=~/.android/debug.keystore
[ -z "$ANDROID_KEYSTORE_ALIAS" ] && ANDROID_KEYSTORE_ALIAS=androiddebugkey

APPNAME=`grep AppName AndroidAppSettings.cfg | sed 's/.*=//' | tr -d '"' | tr " '/" '---'`
APPVER=`grep AppVersionName AndroidAppSettings.cfg | sed 's/.*=//' | tr -d '"' | tr " '/" '---'`

cd project

./gradlew bundleRelease || exit 1

cd app/build/outputs/bundle/release || exit 1

# Remove old certificate
cp -f app.aab ../../../../../../$APPNAME-$APPVER.aab || exit 1
# Sign with the new certificate
echo Using keystore $ANDROID_UPLOAD_KEYSTORE_FILE and alias $ANDROID_UPLOAD_KEYSTORE_ALIAS
stty -echo
apksigner sign --ks $ANDROID_UPLOAD_KEYSTORE_FILE --ks-key-alias $ANDROID_UPLOAD_KEYSTORE_ALIAS ../../../../../../$APPNAME-$APPVER.apk || exit 1
stty echo
echo
