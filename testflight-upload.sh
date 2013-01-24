# This file is used directly by xcode. Don't run it directly. Instead, call build.sh or put it within the xcode scheme.

source "${BASEDIR}/build-identities.sh"

echo "Signing identity: ${SIGNING_IDENTITY}"

# PROVISIONING_PROFILE="${HOME}/Library/MobileDevice/Provisioning Profiles/MapBox Ad Hoc.mobileprovision"
PROVISIONING_PROFILE=$( grep -l "${PRODUCT_NAME} AdHoc" "${HOME}/Library/MobileDevice/Provisioning Profiles/*.mobileprovision" )
LOG="/tmp/testflight.log"
# GROWL="${HOME}/bin/growlnotify -a Xcode -w"

USER=$( whoami )
DATE=$( /bin/date +"%Y-%m-%d" )
ARCHIVE=$( /bin/ls -t "${HOME}/Library/Developer/Xcode/Archives/${DATE}" | /usr/bin/grep xcarchive | /usr/bin/sed -n 1p )
DSYM="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/dSYMs/${PRODUCT_NAME}.app.dSYM"
APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Users/${USER}/Applications/${PRODUCT_NAME}.app"

# /usr/bin/open -a /Applications/Utilities/Console.app $LOG

echo -n "Creating .ipa for ${PRODUCT_NAME}... "
# echo "Creating .ipa for ${PRODUCT_NAME}" | ${GROWL}

/bin/rm "/tmp/${PRODUCT_NAME}.ipa"
cmd='/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "/tmp/${PRODUCT_NAME}.ipa" --sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE}"'
echo $cmd
eval $cmd

echo "done." >> $LOG
# echo "Created .ipa for ${PRODUCT_NAME}" | ${GROWL}

echo -n "Zipping .dSYM for ${PRODUCT_NAME}..."
# echo "Zipping .dSYM for ${PRODUCT_NAME}" | ${GROWL}

/bin/rm "/tmp/${PRODUCT_NAME}.dSYM.zip"
/usr/bin/zip -r "/tmp/${PRODUCT_NAME}.dSYM.zip" "${DSYM}"

echo "done." >> $LOG
# echo "Created .dSYM for ${PRODUCT_NAME}" | ${GROWL}

echo -n "Uploading to TestFlight... "
# echo "Uploading to TestFlight" | ${GROWL}

/usr/bin/curl "http://testflightapp.com/api/builds.json" \
  -F file=@"/tmp/${PRODUCT_NAME}.ipa" \
  -F dsym=@"/tmp/${PRODUCT_NAME}.dSYM.zip" \
  -F api_token="${API_TOKEN}" \
  -F team_token="${TEAM_TOKEN}" \
  -F notes="Build uploaded automatically" \
  -F notify="True" \
  -F distribution_lists="all" || exit -1

echo "done."
# echo "Uploaded to TestFlight" | ${GROWL} -s 
#&& /usr/bin/open "https://testflightapp.com/dashboard/builds/"
