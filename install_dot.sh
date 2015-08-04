#!/bin/bash

FILEROOT="./files"

cd $FILEROOT
for f in * .[^.]*; do
	cp -irv "$f" "$HOME/"
done