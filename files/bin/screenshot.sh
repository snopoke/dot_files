#!/bin/sh
LOCATION="$(date +/home/skelly/Pictures/shots/%Y/%Y-%m-%d)"
mkdir -p $LOCATION
cd $LOCATION
DISPLAY=:0 scrot '%Y-%m-%d-%H%M.jpg' -q 20