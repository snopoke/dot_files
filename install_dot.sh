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
    confirm "Install dropbox command line?" && wget -O ~/bin/dropbox "https://www.dropbox.com/download?dl=packages/dropbox.py" && chmod +x ~/bin/dropbox
    confirm "Install git diff highlight?" && wget -O ~/bin/diff-highlight "https://raw.githubusercontent.com/git/git/master/contrib/diff-highlight/diff-highlight" && chmod +x ~/bin/diff-highlight
}

confirm "Install local files?" && stow -t ~ files
confirm "Install install remote?" && install_remote_files
