#!/usr/bin/env bash
# xpra
# run as root
# https://xpra.org
# multi-platform screen and application forwarding system "screen for X11"

# start xpra server with xterm app
xpra start --bind-tcp=0.0.0.0:9876 --start-child=xterm
