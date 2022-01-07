[[ $(tty) = /dev/tty2 ]] && \
(ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | sed 's/127.0.0.1//' | tr '\n' ' ')

[[ $(tty) = *"pts"* ]] && /opt/busy4me/busy
