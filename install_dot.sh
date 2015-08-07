#!/bin/bash

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

copy_local_files() {
	FILEROOT="./files"

	cd $FILEROOT
	for f in * .[^.]*; do
		cp -irv "$f" "$HOME/"
	done
}

install_remote_files() {
	confirm "Install git completion?" && sudo sh -c "curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > /etc/bash_completion.d/git-completion"
}

confirm "Install local files?" && copy_local_files
confirm "Install install remote?" && install_remote_files
