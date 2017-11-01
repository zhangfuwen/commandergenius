#!/bin/sh
# Set path to your Android keystore and your keystore alias here, or put them in your environment
[ -z "$ANDROID_UPLOAD_KEYSTORE_FILE" ] && ANDROID_UPLOAD_KEYSTORE_FILE=~/.android/upload.jks
[ -z "$ANDROID_UPLOAD_KEYSTORE_ALIAS" ] && ANDROID_UPLOAD_KEYSTORE_ALIAS=androiddebugkey

APPNAME=`grep AppName AndroidAppSettings.cfg | sed 's/.*=//' | tr -d '"' | tr " '/" '---'`
APPVER=`grep AppVersionName AndroidAppSettings.cfg | sed 's/.*=//' | tr -d '"' | tr " '/" '---'`

if false; then

cd project/app/build/outputs/apk/

# Remove old certificate
rm -f Signed.apk
cp -f app-release.apk Signed.apk
zip -d Signed.apk "META-INF/*"
# Sign with the new certificate
echo Using keystore $ANDROID_KEYSTORE_FILE and alias $ANDROID_KEYSTORE_ALIAS
stty -echo
read PW
jarsigner -verbose -tsa http://timestamp.digicert.com -keystore $ANDROID_KEYSTORE_FILE -sigalg MD5withRSA -digestalg SHA1 Signed.apk $ANDROID_KEYSTORE_ALIAS -storepass "$PW" -keypass "$PW" || exit 1
stty echo
echo
rm -f app-release.apk
zipalign 4 Signed.apk app-release.apk
rm -f Signed.apk
cp -f app-release.apk ../../../../../$APPNAME-$APPVER.apk

if false; then
#DEBUGINFODIR=`aapt dump badging App.apk | grep "package:" | sed "s/.*name=[']\([^']*\)['].*versionCode=[']\([^']*\)['].*/\1-\2/" | tr " '/" '---'`
DEBUGINFODIR=$APPNAME-$APPVER
echo Copying debug info to project/debuginfo/$DEBUGINFODIR
mkdir -p ../debuginfo/$DEBUGINFODIR/x86 ../debuginfo/$DEBUGINFODIR/armeabi-v7a
cp -f ../obj/local/x86/*.so ../debuginfo/$DEBUGINFODIR/x86
cp -f ../obj/local/armeabi-v7a/*.so ../debuginfo/$DEBUGINFODIR/armeabi-v7a
cp -f app-release.apk ../debuginfo/$DEBUGINFODIR/$APPNAME-$APPVER.apk
fi

cd ../../../../../

fi

if [ -n "$ANDROID_UPLOAD_KEYSTORE_FILE" ]; then
cp -f $APPNAME-$APPVER.apk $APPNAME-$APPVER-upload1.apk
# Sign with the upload certificate
echo Using keystore $ANDROID_UPLOAD_KEYSTORE_FILE and alias $ANDROID_UPLOAD_KEYSTORE_ALIAS
stty -echo
jarsigner -verbose -tsa http://timestamp.digicert.com -keystore $ANDROID_UPLOAD_KEYSTORE_FILE -sigalg MD5withRSA -digestalg SHA1 $APPNAME-$APPVER-upload1.apk $ANDROID_UPLOAD_KEYSTORE_ALIAS || exit 1
stty echo
echo
rm -f $APPNAME-$APPVER-upload.apk
zipalign 4 $APPNAME-$APPVER-upload1.apk $APPNAME-$APPVER-upload.apk
rm -f $APPNAME-$APPVER-upload1.apk
fi
