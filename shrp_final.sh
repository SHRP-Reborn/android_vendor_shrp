#!/bin/bash
##########################################################################
#Copyright 2019 - 2020 SKYHAWK RECOVERY PROJECT
#Copyright 2020 - 2023 SKYHAWK RECOVERY PROJECT REBORN
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
##########################################################################
#initializing helper function
. build/shrp/shrpEnv.sh


#Clearing all old zips if available
rm -rf "$SHRP_OUT"/*.zip

#Local Variables for final processes
ZIP_NAME=SHRP-Reborn_v${SHRP_VERSION}_${SHRP_STATUS}-${XSTATUS}_$SHRP_DEVICE-$(date -u +%d.%m.%y)
ADDON_ZIP_NAME=SHRP-Reborn_AddonRescue_v${SHRP_VERSION}_$SHRP_DEVICE-$(date -u +%d.%m.%y)

#Reseting folders [Specifically For Dirty build]
resetFolder $SHRP_WORK_DIR
resetFolder $SHRP_META_DATA_DIR
resetFolder "$SHRP_WORK_DIR/META-INF/com/google/android"
resetFolder "$SHRP_WORK_DIR/Files/SHRP/data"
resetFolder "$SHRP_WORK_DIR/Files/SHRP/addons"
resetFolder "$SHRP_OUT/addonRescue/"
resetFolder "$SHRP_OUT/addonRescue/META-INF/com/google/android/"


#Copying JSON directly into the zip location
cat > $SHRP_WORK_DIR/Files/SHRP/data/shrp_info.json <<EOF
[
	{
  "codeName": "$SHRP_DEVICE",
  "buildNo": "$SHRP_BUILD_DATE",
  "isOfficial": $IS_OFFICIAL,
  "has_express": $SHRP_EXPRESS,
  "shrpVer": "$SHRP_VERSION"
	}
]
EOF

DEFAULT_ADDON_LOC=$SHRP_VENDOR/extras

#handle default Addons
addDefaultAddonPost $(normalizeVar $(get_build_var INC_IN_REC_ADDON_1)) $DEFAULT_ADDON_LOC/s_oms.zip $(normalizeVar $(get_build_var SHRP_SKIP_DEFAULT_ADDON_1)) $(normalizeVar $(get_build_var SHRP_EXCLUDE_DEFAULT_ADDONS))
addDefaultAddonPost $(normalizeVar $(get_build_var INC_IN_REC_ADDON_2)) $DEFAULT_ADDON_LOC/s_non_oms.zip $(normalizeVar $(get_build_var SHRP_SKIP_DEFAULT_ADDON_2)) $(normalizeVar $(get_build_var SHRP_EXCLUDE_DEFAULT_ADDONS))
addDefaultAddonPost $(normalizeVar $(get_build_var INC_IN_REC_ADDON_3)) $DEFAULT_ADDON_LOC/rfp.zip $(normalizeVar $(get_build_var SHRP_SKIP_DEFAULT_ADDON_3)) $(normalizeVar $(get_build_var SHRP_EXCLUDE_DEFAULT_ADDONS))
addDefaultAddonPost $(normalizeVar $(get_build_var INC_IN_REC_ADDON_4)) $DEFAULT_ADDON_LOC/Disable_Dm-Verity_ForceEncrypt.zip $(normalizeVar $(get_build_var SHRP_SKIP_DEFAULT_ADDON_4)) $(normalizeVar $(get_build_var SHRP_EXCLUDE_DEFAULT_ADDONS))

addDefaultAddonPost $(normalizeVar $(get_build_var INC_IN_REC_MAGISK)) $DEFAULT_ADDON_LOC/c_magisk.zip false false
addDefaultAddonPost $(normalizeVar $(get_build_var INC_IN_REC_MAGISK)) $DEFAULT_ADDON_LOC/unmagisk.zip false false
#handle External Addons
addAddonPost $(normalizeVar $(get_build_var SHRP_INC_IN_REC_EXTERNAL_ADDON_1)) $(get_addon_confirm $EAP$(get_build_var SHRP_EXTERNAL_ADDON_1_FILENAME)) $(addon_skip $EAP$(get_build_var SHRP_EXTERNAL_ADDON_1_FILENAME))
addAddonPost $(normalizeVar $(get_build_var SHRP_INC_IN_REC_EXTERNAL_ADDON_2)) $(get_addon_confirm $EAP$(get_build_var SHRP_EXTERNAL_ADDON_2_FILENAME)) $(addon_skip $EAP$(get_build_var SHRP_EXTERNAL_ADDON_2_FILENAME))
addAddonPost $(normalizeVar $(get_build_var SHRP_INC_IN_REC_EXTERNAL_ADDON_3)) $(get_addon_confirm $EAP$(get_build_var SHRP_EXTERNAL_ADDON_3_FILENAME)) $(addon_skip $EAP$(get_build_var SHRP_EXTERNAL_ADDON_3_FILENAME))
addAddonPost $(normalizeVar $(get_build_var SHRP_INC_IN_REC_EXTERNAL_ADDON_4)) $(get_addon_confirm $EAP$(get_build_var SHRP_EXTERNAL_ADDON_4_FILENAME)) $(addon_skip $EAP$(get_build_var SHRP_EXTERNAL_ADDON_4_FILENAME))
addAddonPost $(normalizeVar $(get_build_var SHRP_INC_IN_REC_EXTERNAL_ADDON_5)) $(get_addon_confirm $EAP$(get_build_var SHRP_EXTERNAL_ADDON_5_FILENAME)) $(addon_skip $EAP$(get_build_var SHRP_EXTERNAL_ADDON_5_FILENAME))
addAddonPost $(normalizeVar $(get_build_var SHRP_INC_IN_REC_EXTERNAL_ADDON_6)) $(get_addon_confirm $EAP$(get_build_var SHRP_EXTERNAL_ADDON_6_FILENAME)) $(addon_skip $EAP$(get_build_var SHRP_EXTERNAL_ADDON_6_FILENAME))

#Put MagiskBoot into files
cp -r $SHRP_VENDOR/magiskboot/* $SHRP_WORK_DIR/Files/SHRP/addons/

#ADDON Rescue ZIP Initial processes
cp -R "$SHRP_VENDOR/updater/update-binary" "$SHRP_OUT/addonRescue/META-INF/com/google/android/update-binary"

cat > "$SHRP_OUT/addonRescue/META-INF/com/google/android/updater-script" <<EOF
show_progress(1.000000, 0);
ui_print("             ");
ui_print("|Addon Rescue for $SHRP_DEVICE");
ui_print("|Maintainer - $SHRP_MAINTAINER");
delete_recursive("/sdcard/SHRP");
package_extract_dir("Files", "/sdcard/");
set_progress(1.000000);
ui_print("");
EOF

cp -a "$SHRP_WORK_DIR/Files" "$SHRP_OUT/addonRescue/Files"

echo "SHRP_HAS_RECOVERY_PARTITION=$SHRP_HAS_RECOVERY_PARTITION"

#Final scripting before zipping
if [ "$SHRP_AB" != "true" ] || [ "$SHRP_HAS_RECOVERY_PARTITION" == "true" ];then

  cat > "$SHRP_WORK_DIR/META-INF/com/google/android/updater-script" <<EOF
show_progress(1.000000, 0);
ui_print("             ");
ui_print("Skyhawk Recovery Project Reborn                  ");
ui_print("|SHRP version - $SHRP_VERSION $SHRP_STATUS    ");
ui_print("|Device - $SHRP_DEVICE");
ui_print("|Maintainer - $SHRP_MAINTAINER");
delete_recursive("/sdcard/SHRP");
package_extract_dir("Files", "/sdcard/");
set_progress(0.500000);
package_extract_file("recovery.img", "$SHRP_REC");
set_progress(0.700000);
ui_print("                                                  ");
ui_print("Contact Us,");
ui_print(" + Website- https://shrp-reborn.github.io     ");
ui_print(" + Telegram Group - t.me/shrp_reborn                 ");
ui_print(" + Telegram Channel - t.me/shrp_reborn_updates          ");
set_progress(1.000000);
ui_print("");
EOF
  cp -R "$SHRP_VENDOR/updater/update-binary" "$SHRP_WORK_DIR/META-INF/com/google/android/update-binary"
  cp "$RECOVERY_IMG" "$SHRP_WORK_DIR"

else

  resetFolder $OUT/script

  cat > $OUT/script/x <<EOF
ui_print "----------------------------------------";
ui_print "-                                       ";
ui_print "- SHRP Reborn installer for A/B devices ";
ui_print "- Device: $SHRP_DEVICE                  ";
ui_print "- Version: $SHRP_VERSION $SHRP_STATUS   ";
ui_print "- Maintainer: $SHRP_MAINTAINER          ";
ui_print "-                                       ";
ui_print "----------------------------------------";
ui_print " ";
EOF

  #Joining all the updater binary parts into one
  cat "$SHRP_VENDOR/updater/a" "$OUT/script/x" "$SHRP_VENDOR/updater/b" > "$SHRP_WORK_DIR/META-INF/com/google/android/update-binary"

  cp "$RECOVERY_IMG" "$SHRP_WORK_DIR/recovery.img"
  cp "$RECOVERY_RAM" "$SHRP_WORK_DIR/ramdisk-recovery.cpio"
  cp "$MAGISKBOOT"  "$SHRP_WORK_DIR"

fi;

echo -e ""
cd $SHRP_WORK_DIR
zip -r ${ZIP_NAME}.zip *
cd ../../../../../
mv $SHRP_WORK_DIR/*.zip $SHRP_OUT

cd $SHRP_OUT/addonRescue
zip -r ${ADDON_ZIP_NAME}.zip *
cd ../../../../../
mv $SHRP_OUT/addonRescue/*.zip $SHRP_OUT

#Helper for displaying the Result
ZIPFILE=$SHRP_OUT/$ZIP_NAME.zip
ZIPFILE_SHA1=$(sha1sum -b $ZIPFILE)
ADDONZIPFILE=$SHRP_OUT/$ADDON_ZIP_NAME.zip
ADDONZIPFILE_SHA1=$(sha1sum -b $ADDONZIPFILE)

#Result
echo ""
echo ""
echo "|SKYHAWK Recovery Project Reborn-----------------------------------------"
echo "|Device - $SHRP_DEVICE"
echo "|Maintainer - $SHRP_MAINTAINER"
if [[ $XSTATUS = Unofficial ]]; then
    echo "|Build - ${XSTATUS} Build"
else
    echo "|Build - ${XSTATUS} Build"
fi;
echo "|Version - $SHRP_VERSION $SHRP_STATUS"
echo ""
echo "|File Info--------------------------------------------------------"
echo "|Recovery ZIP - $ZIP_NAME.zip"
echo "|File Size - $(getSize $ZIPFILE)"
echo "|SHA1 - ${ZIPFILE_SHA1:0:40}"
echo ""
echo "|Addon Rescue ZIP - $ADDON_ZIP_NAME.zip"
echo "|File Size - $(getSize $ADDONZIPFILE)"
echo "|SHA1 - ${ADDONZIPFILE_SHA1:0:40}"
echo ""
echo "--------------------------------------BUILD SUCCESSFULLY COMPLETED"
echo ""
echo ""
