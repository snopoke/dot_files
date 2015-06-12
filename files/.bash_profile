export SCALA_HOME=~/dev/scala-2.11.6
export PATH=$PATH:~/bin:$SCALA_HOME/bin
export EDITOR=vi
export M2_HOME=/home/skelly/dev/apache-maven-3.1.1
export PYTHONSTARTUP=~/.pythonrc


function fix_pycharm {
    # https://youtrack.jetbrains.com/issue/IDEA-78860
    ibus-daemon -rd
}

function we_are_in_git_work_tree {
    git rev-parse --is-inside-work-tree &> /dev/null
}

function parse_git_branch {
    if we_are_in_git_work_tree; then
        local BR=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD 2> /dev/null)
        if [ "$BR" == HEAD ]; then
            local NM=$(git name-rev --name-only HEAD 2> /dev/null)
            if [ "$NM" != undefined ]; then 
                echo -n "@$NM"
            else 
                git rev-parse --short HEAD 2> /dev/null
            fi
        else
            echo -n $BR
        fi
    fi
}

function parse_git_status {
    if we_are_in_git_work_tree; then 
        local ST=$(git status --short 2> /dev/null)
        if [ -n "$ST" ]
        then echo -n " + "
        else echo -n " - "
        fi
    fi
}

function pwd_depth_limit_2 {
    if [ "$PWD" = "$HOME" ]
    then echo -n "~"
    else pwd | sed -e "s|.*/\(.*/.*\)|\1|"
    fi
}

COLTEXT="\[\033[1;34m\]"
COLMARKUP="\[\033[1;32m\]"
COLCLEAR="\[\033[0m\]"
COLVPN="\e[96m"

function vpn_connected {
    local vpn=`ps ax -o args | grep -v grep | grep vpnc | cut -d " " -f2`
    if [ ! -z "$vpn" ] ; then
        echo -n "($vpn)"
    fi
}

# export all these for subshells
export -f parse_git_branch parse_git_status we_are_in_git_work_tree pwd_depth_limit_2 vpn_connected
export PS1="$COLVPN\$(vpn_connected)$COLMARKUP<$COLTEXT \$(pwd_depth_limit_2)$COLMARKUP\$(parse_git_status)$COLTEXT\$(parse_git_branch) $COLMARKUP>$COLCLEAR "
export TERM="xterm-color"


# aliases
############################################
alias bp="sublime-text ~/.bash_profile"
alias rl="source ~/.bash_profile"
alias ll="ls -al"
alias g="git"
alias l="git status -s"
alias d="git diff"
alias dc="git diff --cached"
alias m="git commit -m "
alias am="git commit -am "
alias a="git add "
alias o-="git checkout --"
alias o="git checkout"
alias om="git checkout master"
alias ph="git push"
alias pl="git pull"
alias rh="git reset HEAD"
alias mg="git merge"
alias gl="git ls"
alias gl5="git ls -5"
alias gs="git stash"
alias gsl="git stash list"
alias b="git branch"
alias uc="update-code"
alias um="update-code; delete-merged"
alias celery="./manage.py celeryd --verbosity=2 -c 2 --beat --statedb=celery.db --events"
alias branch="git branch | grep '^\*' | sed 's/* //'"
alias gpo='git push origin $(branch)'
alias gpof='git push origin $(branch) --force'
alias gap='git add -p'
alias cloudant='ssh -D 5000 -C -q -N hqdb0.internal.commcarehq.org'
alias cloudant_india='ssh -D 5001 -C -q -N indiacloud3'
alias nr='sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib net-responsibility'

function hammer() {                                                                                  
    git checkout master                                                                              
    git pull origin master                                                                           
    git submodule update --init --recursive                                                          
    pip install -r requirements/requirements.txt -r requirements/dev-requirements.txt -r requirements/prod-requirements.txt                                                             
    find . -name '*.pyc' -delete                                                                     
    ./manage.py syncdb --migrate                                                  
}  

function gsa() {
	git stash apply "stash@{$1}"
}

function vpn() {
	sudo vpnc rackspace
	#uuid=`nmcli con | grep rackspace | awk '{print $2}'`
	#until nmcli c up uuid $uuid; do
	#  echo Retrying in 5 seconds...
	#  sleep 5
	#done
}

function vpnindia() {
    sudo vpnc india
}

function vpndone() {
    sudo vpnc-disconnect 
}

function delete-pyc() {
    find . -name '*.pyc' -delete
}
function pull-latest-master() {
    git checkout master; git pull &
    git submodule foreach --recursive 'git checkout master; git pull origin master &'
    until [ -z "$(ps aux | grep '[g]it pull')" ]; do sleep 1; done
}
function update-code() {
    pull-latest-master
    echo "Deleteing all compiled python"
    delete-pyc
}
rs='.internal.commcarehq.org'
 
function delete-merged() {
    if [ $(branch) = 'master' ]
        then git branch --merged master | grep -v '\*' | xargs -I {} bash -c 'if [ -n "{}" ]; then git branch -d "{}"; fi'
        else echo "You are not on branch master"
    fi
                                            
    git submodule foreach --recursive "git branch --merged master | grep -v '\*' | xargs -I {} bash -c 'if [ -n \"{}\" ]; then git branch -d \"{}\"; fi'"
    #git submodule foreach --recursive 'git branch --merged master | grep -v "\*" | xargs -n1 git branch -d'
}

function force-edit-url {
    git remote set-url origin $(gpo 2>&1 | grep Use | awk '{print $2}')
}

function delete-merged-remote() {
    git fetch
    git remote prune origin
    git branch --remote --merged master | grep -v 'master$' | sed s:origin/:: | xargs -I% git push origin :%
}
 
function es-list() {
    curl -s 'http://localhost:9200/_status' | jsawk 'return Object.keys(this.indices).join("\n")'
}
 
function es-alias() {
    curl -XPOST 'http://localhost:9200/_aliases' -d \
        '{ "actions": [ {"add": {"index": "'"$1"'_'"$2"'", "alias": "'$1'"}}]}'
}

function clean_time_pull() {
    dos2unix -q $1
    head -n 2 $1 | tail -n 1 
    grep -v "Time Report\|^Date,\|^Total\|^\s*$" $1 | grep "Simon Kelly" 
}

SSH_ENV="$HOME/.ssh/environment"

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi

# /home/skelly/bin/dropbox-dimagi.sh

