#!/system/bin/sh

#OBB_VERSION=191224
OBB_VERSION=$ANDROID_PACKAGE_VERSION_CODE

echo "Extracting data files"
cd $SECURE_STORAGE_DIR
echo "./busybox tar xvJf $ANDROID_OBB_DIR/main.$OBB_VERSION.$ANDROID_PACKAGE_NAME.obb"
./busybox tar xvJf $ANDROID_OBB_DIR/main.$OBB_VERSION.$ANDROID_PACKAGE_NAME.obb || { echo "Extracting data failed!" ; exit 1 ; }
echo "Extracting overlay data files"
echo "./busybox tar xvJf $DATADIR/overlay.tar.xz"
./busybox tar xvJf $DATADIR/overlay.tar.xz || { echo "Extracting overlay data failed!" ; exit 1 ; }
cd $SECURE_STORAGE_DIR/img

echo "Installation path: $SECURE_STORAGE_DIR/img"

rm -f ./postinstall-img.sh ./proot.sh
ln -s ../usr/bin/postinstall-img.sh .
ln -s ../usr/bin/proot.sh .

# ls -l .

echo "Running postinstall-img.sh:"

./postinstall-img.sh
