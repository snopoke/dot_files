#!/bin/bash
# Install dropbox via normal method then:
# $ mkdir /media/skelly/data/simon_dropbox
# $ ln -s ~/.Xauthority /media/skelly/data/simon_dropbox/
# $ HOME="/media/skelly/data/simon_dropbox"
# $ /home/skelly/.dropbox-dist/dropboxd

DRIVE="/dev/sdb2"
UUID="D6162E3A162E1C4D"

# Ensure drive mounted
mount | grep $DRIVE > /dev/null
if [ $? -eq 1 ]; then
	echo "Mounting drive"
	udisksctl mount --block-device /dev/disk/by-uuid/$UUID
fi

function start_dropbox {
	HOME="$1"
	cd $HOME
	dropbox running
	if [ $? -eq 0 ]; then
	    echo "Starting Dimagi Dropbox in $HOME"
	    /home/skelly/.dropbox-dist/dropboxd &
	fi
}	

start_dropbox "/home/skelly"
start_dropbox "/media/skelly/data/simon_dropbox"
