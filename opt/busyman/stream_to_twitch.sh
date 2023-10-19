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

#export DISPLAY=:0 && \
ffmpeg -f x11grab -framerate 30 -video_size 800x600 \
-i :0 \
-c:v libx264 \
-preset veryfast \
-maxrate 1984k \
-bufsize 3968k \
-vf "format=yuv420p" \
-g 60 \
-c:a aac \
-b:a 128k \
-ar 44100 \
-f flv rtmp://live.twitch.tv/app/live_279064185_qRAgheqdBj79z4el2XDsdY2iN5EzS3

# no audio
export DISPLAY=:0 && ffmpeg \
-f x11grab \
-framerate 30 \
-video_size 800x600 \
-i :0 \
-c:v libx264 \
-preset veryfast \
-maxrate 1984k \
-bufsize 3968k \
-vf "format=yuv420p" \
-f flv rtmp://live.twitch.tv/app/live_279064185_qRAgheqdBj79z4el2XDsdY2iN5EzS3 &
