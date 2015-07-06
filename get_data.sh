#!/bin/bash
#
# Get Link 2.2
#
#
# Code Idea and Source of "link getting method":
# http://git.jorgenio.com/jdownloader/src/d3d3853c647c/src/jd/plugins/decrypter/GameOneDeA.java
#
# Changelog 3.0
# - Changed to metadata parser using the iPhone API
#
# Changelog 2.2
# - Removed RTMP Functionailty because it's not necessary anymore
# - Changed Video Link gen to use Game One Android API and jq (json :))
# - Updated JSON part to use jq
#
# Changelog 2.1
# - Added possibility for RTMP Download
#
# Changelog 2.0
# - Completely rewritten script to handle Video aswell as Audio IDs
# - removed Link function, it's useless
# - use Variables.
#

UA="GameOne/227 CFNetwork/660 Darwin/14.0.0"
APPID="61FF925DEB497389D2FB66F8976C5B36"

video_link_gen ()
{
#xmllint http://riptide.mtvnn.com/mediagen/$1 | grep "640px\|webxl" | sed -e 's/<src>//' | sed -e 's/<\/src>//'| sed -e 's/^[ \t]*//' | sed -e 's/.*\/r2/http\:\/\/cdn.riptide-mtvn.com\/r2/'
# Android API
#curl -s "http://riptide.mtvnn.com/android/videos/$1.json" | jq .high | sed -e 's/"//g'
# iOS m3u8 playlist parsing
#curl -s "http://riptide.mtvnn.com/$1.m3u8?hq=true" | grep -A 1 "RESOLUTION=1280x720" | grep http
curl -s "http://riptide.mtvnn.com/$1.json" | jq -r '.versions | map(select(.mime == "video/mp4")) | max_by(.bitrate) | .url' 2>/dev/null
}

# Check if everything is OK
if [ "$1" == "" ]
 then echo "usage: $0 '<Video-ID or Audio-ID>'"
 exit 1
 else sleep 0
fi

case ${#1} in
"32")
 if [[ $(curl -s -I -H "X-G1APP-IDENTIFIER: $APPID" -A "$UA" "http://gameone.de/videos/$1.json" | grep "Content-Type: application/json") ]]
  then export MEDIATYPE=video
  else echo -e "\033[31mERROR: No valid Video-ID specified\033[0m"
  exit 0
 fi
;;

"2"|"3"|"4")
 if [[ $(curl -s -I -H "X-G1APP-IDENTIFIER: $APPID" -A "$UA" "http://gameone.de/audios/$1.json" | grep "Content-Type: application/json") ]]
  then export MEDIATYPE=audio
  else echo -e "\033[31mERROR: No valid Audio-ID specified\033[0m"
  exit 0
 fi
;;
 
*)
 echo -e "\033[31mERROR: No valid ID specified, non-riptide IDs are not supported :(\033[0m"
 exit 0
;;

esac

case $MEDIATYPE in

audio)
 echo -e "\033[36mGetting Audio Info...\033[0m"
 JSON=$(curl -s -H "X-G1APP-IDENTIFIER: $APPID" -A "$UA" "http://gameone.de/audios/$1.json")
 DESCRIPTION=$(echo $JSON | jq -r .audio_meta.description | strings)
 TITLE=$(echo $JSON | jq -r .audio_meta.title)
 LINK=$(echo $JSON | jq -r .audio_meta.iphone_url)
 ID=$1
 DURATION=$(echo $JSON | jq -r .audio_meta.duration)
 UPLOADER_ID=$(echo $JSON | jq -r .audio_meta.user.id)
 UPLOADER_NAME=$(echo $JSON | jq -r .audio_meta.user.name)
 UPLOAD_TIME=$(date --date="$(curl -s -I -L $LINK | grep Last-Modified | sed -e 's/.*Modified: //g')" "+%d.%m.%Y-%H:%M:%S")
 echo -e "\033[32mID:\033[0m $ID"
 echo -e "\033[32mTitle:\033[0m $TITLE"
 echo -e "\033[32mDescription:\033[0m \"$DESCRIPTION\""
 echo -e "\033[32mUploaded at:\033[0m $UPLOAD_TIME"
 echo -e "\033[32mDuration:\033[0m $DURATION seconds"
 echo -e "\033[32mUploader (ID/Name):\033[0m $UPLOADER_ID / $UPLOADER_NAME"
 echo -e "\033[32mDownload link:\033[0m $LINK"
 echo ""
;;

video)
 echo -e "\033[36mGetting Video Info...\033[0m"
 JSON=$(curl -s -H "X-G1APP-IDENTIFIER: $APPID" -A "$UA" "http://gameone.de/videos/$1.json")
 DESCRIPTION=$(echo $JSON | jq -r .video_meta.description | strings)
 TITLE=$(echo $JSON | jq -r .video_meta.title)
 HLS_LINK=$(echo $JSON | jq -r .video_meta.iphone_url)
 DURATION=$(echo $JSON | jq -r .video_meta.duration)
 UPLOADER_ID=$(echo $JSON | jq -r .video_meta.user.id)
 UPLOADER_NAME=$(echo $JSON | jq -r .video_meta.user.name)
 DL_LINK=$(video_link_gen $1)
 ID=$(echo $JSON | jq -r .video_meta.id)
 RID=$1
 GAMES=$(echo $JSON | jq -r .video_meta.games_string)
 TAGS=$(echo $JSON | jq -r .video_meta.tags_string)
 UPLOAD_TIME=$(date --date "$(echo $JSON | jq -r .video_meta.created_at)" "+%d.%m.%Y-%H:%M:%S")
 THUMB_URL=$(echo $JSON | jq -r .video_meta.img_url)
 echo -e "\033[32mRiptide ID:\033[0m $RID"
 echo -e "\033[32mRiptide Status Page:\033[0m http://riptide.mtvnn.com/status?riptide_id=$RID"
 echo -e "\033[32mTitle:\033[0m $TITLE"
 echo -e "\033[32mDescription:\033[0m \"$DESCRIPTION\""
 echo -e "\033[32mUploaded at:\033[0m $UPLOAD_TIME"
 echo -e "\033[32mDuration:\033[0m $DURATION seconds"
 echo -e "\033[32mTags:\033[0m $TAGS"
 echo -e "\033[32mGames:\033[0m $GAMES"
 echo -e "\033[32mThumbnail URL:\033[0m $THUMB_URL"
 echo -e "\033[32mVideo ID:\033[0m $ID"
 echo -e "\033[32mUploader (ID/Name):\033[0m $UPLOADER_ID / $UPLOADER_NAME"
 echo -e "\033[32mHLS Stream:\033[0m $HLS_LINK"
 echo -e "\033[32mDownload Link:\033[0m $DL_LINK"
 echo ""
;;
esac

exit 0
