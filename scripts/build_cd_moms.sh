#!/bin/sh

INPUT_DIR="common/sources/Entities"

for model in $(find ${INPUT_DIR} -type d -name  "*.xcdatamodeld")
do
    $(xcode-select -p)/usr/bin/momc --sdkroot $(xcode-select -p)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk --iphoneos-deployment-target 14.0 --module NamuTrackerApp ${model} ".theos/_/Library/Application Support/NamuTracker" 
done

exit 0
