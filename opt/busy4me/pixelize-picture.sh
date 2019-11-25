#!/bin/bash

scrot /tmp/screen.png

xwobf -s 11 /tmp/screen.png

i3lock --textcolor=ffffff00 --insidecolor=ffffff1c --ringcolor=ffffff3e --linecolor=ffffff00 --keyhlcolor=00000080 --ringvercolor=00000000 --separatorcolor=22222260 --insidevercolor=0000001c --ringwrongcolor=00000055 --insidewrongcolor=0000001c -i /tmp/screen.png

rm /tmp/screen.png

# source https://gist.github.com/rawsh/f391bf6aa040fcffb265237b406c5749#file-readme-md
# https://github.com/glindste/xwobf
