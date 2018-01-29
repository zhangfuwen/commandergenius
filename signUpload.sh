#!/bin/sh
# Set path to your Android keystore and your keystore alias here, or put them in your environment
[ -z "$ANDROID_UPLOAD_KEYSTORE_FILE" ] && ANDROID_UPLOAD_KEYSTORE_FILE=~/.android/upload.jks
[ -z "$ANDROID_UPLOAD_KEYSTORE_ALIAS" ] && ANDROID_UPLOAD_KEYSTORE_ALIAS=androiddebugkey

APPNAME=`grep AppName AndroidAppSettings.cfg | sed 's/.*=//' | tr -d '"' | tr " '/" '---'`
APPVER=`grep AppVersionName AndroidAppSettings.cfg | sed 's/.*=//' | tr -d '"' | tr " '/" '---'`

if [ -n "$ANDROID_UPLOAD_KEYSTORE_FILE" ]; then
cp -f $APPNAME-$APPVER.apk $APPNAME-$APPVER-upload.apk
# Sign with the upload certificate
echo Using keystore $ANDROID_UPLOAD_KEYSTORE_FILE and alias $ANDROID_UPLOAD_KEYSTORE_ALIAS
stty -echo
apksigner sign --ks $ANDROID_UPLOAD_KEYSTORE_FILE --ks-key-alias $ANDROID_UPLOAD_KEYSTORE_ALIAS $APPNAME-$APPVER-upload.apk || exit 1
stty echo
echo
fi

