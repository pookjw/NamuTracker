#!/bin/sh

INPUT_DIR="common/sources/Entities"
OUTPUT_DIR=".theos/_/Applications/NamuTrackerApp.app"

for model in $(find ${INPUT_DIR} -type d -name  "*.xcdatamodeld")
do
    $(xcode-select -p)/usr/bin/momc --sdkroot $(xcode-select -p)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk --iphoneos-deployment-target 14.0 --module NamuTrackerApp ${model} ${OUTPUT_DIR} 
done

exit 0
