#!/bin/bash

nc -z 8.8.8.8 53  >/dev/null 2>&1
online=$?
if [ $online -eq 0 ]; then
    echo "DNS server 8.8.8.8 response OK :)"
else
    echo "DNS server 8.8.8.8 not response, offline? :(";
fi

wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
    echo "google.com Online :)"
else
    echo "google.com Offline :("
fi

wget -q --tries=10 --timeout=20 --spider http:/facebook.com
if [[ $? -eq 0 ]]; then
    echo "facebook.com Online :)"
else
    echo "facebook.com Offline :("
fi
