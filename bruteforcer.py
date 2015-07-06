#!/usr/bin/python
# -*- coding: utf-8 -*-

import requests
import sys


headers = {'X-G1APP-IDENTIFIER': '456a1231ad56ad1a65d1a65d1a56d1a5',
           'User-Agent': 'GameOne/227 CFNetwork/660 Darwin/14.0.0'}
s = requests.Session()
s.headers.update(headers)
video_api_url = "http://gameone.de/videos/%s.json?type=video_meta&page=1&per_page=0"
audio_api_url = "http://gameone.de/audios/%s.json"
url = ""


def main():
    global url
    if len(sys.argv) < 4:
        print "Error: not enough parameters."
        print "Usage: %s <audio/video> <start> <end>" % __file__
        return 1
    data_type = str(sys.argv[1])
    start_count = int(sys.argv[2])
    end_count = int(sys.argv[3])
    valid_types = ["audio", "video"]

    if data_type not in valid_types:
        print 'Error, type "%s" unsupported' % data_type
        return 1
    elif data_type == "audio":
        url = audio_api_url
    elif data_type == "video":
        url = video_api_url

    if end_count <= start_count:
        print "Error: end count not higher than start count"
        return 1
    count = start_count - 1
    while count < end_count:
        count += 1
        sys.stdout.write('Testing ID %s/%s' % (str(count), str(end_count)))
        sys.stdout.write('\r')
        sys.stdout.flush()
        req = s.get(url % str(count))
        # metadata = {}
        try:
            metadata = req.json()
            if data_type == "audio" and not metadata['audio_meta']['title']:
                raise Exception
            if data_type == "video" and not metadata['video_meta']['riptide_video_id']:
                raise Exception
        except:
            continue
        if data_type == "video":
            # print ""
            print "Video found for ID %s: %s - %s" % (str(count),
                                                      metadata['video_meta']['title'],
                                                      metadata['video_meta']['riptide_video_id'])
        else:
            # print metadata['audio_meta']['title'].encode('ascii', 'ignore')
            # print metadata['audio_meta']['iphone_url']
            print "Audio found for ID %s: %s - %s" % (str(count),
                                                      metadata['audio_meta']['title'].encode('utf-8', 'ignore'),
                                                      metadata['audio_meta']['iphone_url'].encode('utf-8', 'ignore'))

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print "Ending.\n"
        sys.exit(0)

