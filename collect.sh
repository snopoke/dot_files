#!/bin/bash

FILES=".bash_profile
proxy.pac
.gitconfig
bin/dropbox_starter.sh
"
for f in $FILES; do
	cp "$HOME/$f" "./files/$f"
done