#!/bin/bash
# Install dropbox via normal method then:
# $ mkdir /media/skelly/data/simon_dropbox
# $ ln -s ~/.Xauthority /media/skelly/data/simon_dropbox/
# $ HOME="/media/skelly/data/simon_dropbox"
# $ /home/skelly/.dropbox-dist/dropboxd

function start_dropbox {
	HOME="$1"
	cd $HOME
	PID=`pgrep -u skelly -o dropbox`
	if [ -n "$PID" ]; then
		echo "Killing existing process"
		kill $PID
	fi
	dropbox running
	if [ $? -eq 0 ]; then
	    echo "Starting Dropbox in $HOME"
	    /home/skelly/.dropbox-dist/dropboxd &
	fi
}	

ACCOUNT=$1
echo "Starting '$ACCOUNT' Dropbox"

start_dropbox "/home/skelly/dropbox_${ACCOUNT}"
