#!/bin/bash

# change hostname and minion_id from fb-login

SCRIPT=stream_to_twich.sh
LOGFILE=/var/log/busy4me.log
LOGFILE_CRON=/var/log/busy4me_cron.log
source /opt/busy4me/twitch

logline() {
	while IFS= read -r line; do
	echo "$(date +%F' '%T) $USER $SCRIPT - $line" | tee -a $LOGFILE
	done
}

pkill --signal TERM -f ffmpeg >/dev/null

# streaming to facebook doesn't work without audio
# url must be in quotation marks

# username_emailprofider_cox
#ffmpeg -f x11grab -i :0 -i /opt/busy/sounds/psyho002.mp3 -acodec libmp3lame -ar 44100 -b:a 128k -pix_fmt yuv420p -profile:v baseline -s 640x480 -bufsize 6000k -vb 400k -maxrate 1500k -deinterlace -vcodec libx264 -preset veryfast -g 30 -r 30 -f flv "rtmp://live-api-s.facebook.com:80/rtmp/1090678404439088?s_ps=1&s_sw=0&s_vt=api-s&a=Abya9SHT4dW-E4Aa"

ffmpeg -f x11grab -s 720x480 -i :0 -i /opt/busy/sounds/cafe_noise.mp3 -acodec libfdk_aac -ar 44100 -b:a 128k -pix_fmt yuv420p -profile:v baseline -s 720x480 -bufsize 6000k -vb 400k -maxrate 1500k -deinterlace -vcodec libx264 -preset veryfast -g 15 -r 15 -qscale 1 -f flv "rtmp://live-api-s.facebook.com:80/rtmp/1090678404439088?s_ps=1&s_sw=0&s_vt=api-s&a=Abya9SHT4dW-E4Aa"