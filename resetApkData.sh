#!/bin/sh

. ./AndroidAppSettings.cfg

adb shell pm clear $AppFullName
