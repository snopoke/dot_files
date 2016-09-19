#!/bin/bash
# Install dropbox via normal method then:
# $ mkdir /media/skelly/data/simon_dropbox
# $ ln -s ~/.Xauthority /media/skelly/data/simon_dropbox/
# $ HOME="/media/skelly/data/simon_dropbox"
# $ /home/skelly/.dropbox-dist/dropboxd

function start_dropbox {
	HOME="$1"
	cd $HOME
	dropbox running
	if [ $? -eq 0 ]; then
	    echo "Starting Dimagi Dropbox in $HOME"
	    /home/skelly/.dropbox-dist/dropboxd &
	fi
}	

start_dropbox "/home/skelly/dropbox_dimagi"
start_dropbox "/home/skelly/dropbox_simon"
