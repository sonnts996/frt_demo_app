#!/usr/bin/env bash
# place this script in project/android/app/
cd ..
# fail if any command fails
set -e
# debug log
set -x

cd ..
# choose a different release channel if you want - https://github.com/flutter/flutter/wiki/Flutter-build-release-channels
# stable - recommended for production

git clone -b 2.10.3 https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

flutter channel stable
flutter doctor

if [ "${BUILD_FLAVOR}" == ""]
then
  FLAVOR="${APPCENTER_ANDROID_VARIANT/"Release"/""}"
else
  FLAVOR=BUILD_FLAVOR
fi

flutter build apk --release --flavor $FLAVOR --build-name=$BUILD_VERSION --build-number=$BUILD_NUMBER

# copy the APK where AppCenter will find it

OUTPUT_FOLDER=android/app/build/outputs/apk/
FLUTTER_OUTPUT="build/app/outputs/flutter-apk/app-${BUILD_FLAVOR,,}-release.apk"

mkdir -p $OUTPUT_FOLDER
mv $FLUTTER_OUTPUT $_