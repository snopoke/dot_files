#!/bin/bash

FILEROOT="./files"

cd $FILEROOT
FILES=*
for f in $FILES; do
	cp -nrv "$f" "$HOME/$f"
done