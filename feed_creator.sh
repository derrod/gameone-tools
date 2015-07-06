#!/bin/bash

# Linux simple bash RSS Feed creator for JSON input
#
# The intention is to use this script to create a valid RSS Feed without anything but a
# JSON Source with Link, Desc. and Title. Let's go!

# getting the input, pretty easy as this part of the script already existed long before this.
# To Do:
# - Nothing?
# Last Update:
# - Audio Date not longer included in link as unix time, now using the "Last-Modified" HTTP-Header of the files :)

export LC_ALL=en_US.UTF-8
DATE=`date "+%a, %d %b %Y %H:%M:%S %z"`
RSSFILE=audios.xml
APPID=61FF925DEB497389D2FB66F8976C5B36
UA="GameOne/227 CFNetwork/660 Darwin/14.0.0"
UT=1262300400
z=0

if [[ $1 == "" ]]
 then echo "No RSSPATH set, aborting..."
 exit 1
 else export RSSPATH=$(echo $1)
fi

if [[ $2 == "" ]]
 then export x=900 # We are at ID ~~~499~~~ 720, better higher startpoitnt :)
 else export x=$(echo $2)
fi

if [[ $3 == "" ]]
 then export y=0
 else export y=$(echo $3)
fi

export RSSTMP=`echo /tmp/$RSSFILE`

# Replace xml special characters with their representations
xmllize ()
{
sed -e 's/<[^>]*>//g' | sed -e 's/</\&lt;/g' | sed -e 's/&/\&amp;/g' | sed -e 's/>/\&gt;/g' | sed -e 's/"/\&quot;/g' | sed -e "s/'/\&apos;/g" 
}

audio_time_gen ()
{
# Get File Age by using the "Last-Modified" HTTP-Header
curl -s -I -L "$1" | grep Last-Modified | sed -e 's/GMT/\+0100/g' | sed -e 's/.*Modified\: //g' | tr -d '\n' | tr -d '\r'
}

# creating the actual RSS

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $RSSTMP
echo "<rss version=\"2.0\">" >> $RSSTMP
#echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $RSSTMP
#echo "<?xml-stylesheet type=\"text/xsl\" media=\"screen\" href=\"http://feeds.feedburner.com/~d/styles/rss2enclosuresfull.xsl\"?><?xml-stylesheet type=\"text/css\" media=\"screen\" href=\"http://feeds.feedburner.com/~d/styles/itemcontent.css\"?><rss xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\" xmlns:atom=\"http://www.w3.org/2005/Atom\" xmlns:media=\"http://search.yahoo.com/mrss/\" xmlns:feedburner=\"http://rssnamespace.org/feedburner/ext/1.0\" version=\"2.0\">" >> $RSSTMP
echo "" >> $RSSTMP
echo "  <channel>" >> $RSSTMP
echo "    <title>Game One Audio Feed</title>" >> $RSSTMP
echo "    <link>http://www.gameone.de/</link>" >> $RSSTMP
echo "    <description>Private Feed of all Game One Audiofiles ever published, this feed is updated daily.</description>" >> $RSSTMP
echo "    <language>de-de</language>" >> $RSSTMP
echo "    <generator>A bash script by Rodney</generator>" >> $RSSTMP

# Adding the items
# More complex but still, damn easy.
until [ $x -eq $y ]; do
 if [[ $(curl -s -I -H "X-G1APP-IDENTIFIER: $APPID" -A "$UA" "http://gameone.de/audios/$x.json" | grep "Content-Type: application/json") ]]
 then export JSON=$(curl -s -H "X-G1APP-IDENTIFIER: $APPID" -A "$UA" "http://gameone.de/audios/$x.json")
  if ! [[ $(echo $JSON | jq .audio_meta.title 2>/dev/null) == "null" || $(echo $JSON | jq .audio_meta.title 2>/dev/null) == "" ]]
   then export TITLE=$(echo $JSON | jq -r .audio_meta.title 2>/dev/null | xmllize)
   export AUDIOLINK=$(echo $JSON | jq -r .audio_meta.iphone_url 2>/dev/null)
   export DESC=$(echo $JSON | jq -r .audio_meta.description 2>/dev/null | xmllize)
   export DATE=$(audio_time_gen $AUDIOLINK)
   echo "    <item>" >> $RSSTMP
   echo "      <title>$TITLE</title>" >> $RSSTMP
   echo "      <description>$DESC</description>" >> $RSSTMP
   echo "      <link>$AUDIOLINK</link>" >> $RSSTMP
   echo "      <enclosure url=\"$AUDIOLINK\" length=\"\" type=\"audio/mpeg\" />" >> $RSSTMP
   echo "      <pubDate>$DATE</pubDate>" >> $RSSTMP
   echo "    </item>" >> $RSSTMP
   echo "" >> $RSSTMP
   else sleep 0
  fi
 fi
 x=$(( $x - 1 ))
done

# Ending of the RSS feed
echo "  </channel>" >> $RSSTMP
echo "" >> $RSSTMP
echo "</rss>" >> $RSSTMP

rm $RSSPATH/$RSSFILE

sed -e 's/url=\"\/assets/url=\"http\:\/\/asset.gameone.de\/gameone\/assets/g' $RSSTMP | sed -e 's/\<link\>\/assets/\<link\>http\:\/\/asset.gameone.de\/gameone\/assets/g' >> $RSSPATH/$RSSFILE

rm $RSSTMP

exit 0