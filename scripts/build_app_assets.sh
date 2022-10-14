#!/bin/sh

INPUT_DIR="modules/NamuTrackerApp/Assets.xcassets"
OUTPUT_DIR=".theos/_/Applications/NamuTrackerApp.app"
PARTIAL_INFO_PLIST="Info_partial.plist"
FINAL_INFO_PLIST="modules/NamuTrackerApp/Resources/Info.plist"

xcrun actool --compile ${OUTPUT_DIR} ${INPUT_DIR} --platform iphoneos --minimum-deployment-target 14.0 --app-icon AppIcon --output-partial-info-plist ${PARTIAL_INFO_PLIST}
/usr/libexec/PlistBuddy -x -c "Merge ${PARTIAL_INFO_PLIST}" ${FINAL_INFO_PLIST}
rm ${PARTIAL_INFO_PLIST}
exit 0