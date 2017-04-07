#!/bin/sh

[ -z "$1" ] && { echo "Specify .apk file"; exit 1; }

LOG=/tmp/reinstall-apk-$$.log

adb install -r $1 | tee $LOG

grep '^Failure' $LOG && {
	adb uninstall `aapt dump badging $1 | grep 'package:' | sed "s/.*name='\([^']*\)'.*/\1/"`
	adb install -r $1
}

rm -f $LOG
