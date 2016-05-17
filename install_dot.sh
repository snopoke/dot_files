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

install_remote_files() {
	confirm "Install git completion?" && sudo sh -c "curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > /etc/bash_completion.d/git-completion"
}

confirm "Install local files?" && stow -t ~ files
confirm "Install install remote?" && install_remote_files
