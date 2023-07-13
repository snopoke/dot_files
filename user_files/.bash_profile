############################################
# exports and vars
############################################
export GRADLE_HOME=~/dev/gradle-2.5
export PATH=$PATH:~/bin:~/.local/bin
export EDITOR=vi
test -f ~/.pythonrc && export PYTHONSTARTUP=~/.pythonrc
export TERM="xterm-color"
export REUSE_DB=1
export PYTHONDONTWRITEBYTECODE=1
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_NOCOWS=1
export WORKON_HOME=~/.virtualenvs
export COMMCARE_CLOUD_ENVIRONMENTS=/home/skelly/src/commcare-cloud/environments
export COMMCARE_CLOUD_USE_AWS_SSM=1
export CCHQ_STRICT_WARNINGS=1

# git-prompt
export GIT_PS1_SHOWDIRTYSTATE=1  # shown as '*' for unsaged and '+' for staged
export GIT_PS1_SHOWSTASHSTATE=1  # shown as '$'
export GIT_PS1_SHOWUNTRACKEDFILES=1  # shown as '%'
export GIT_PS1_SHOWCOLORHINTS=1

# commcare-cloud
source ~/.commcare-cloud/load_config.sh

# fly.io
export FLYCTL_INSTALL="/home/skelly/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

india='.india.commcarehq.org'

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
source ~/.git-prompt.sh
source ~/.git-completion.bash

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


############################################
# aliases
############################################
alias bp="codium ~/.bash_profile"
alias rl="source ~/.bash_profile"
alias ll="ls -al"
alias g="git"; __git_complete g __git_main
alias l="git status -s"
alias d="git diff"
alias dc="git diff --cached"
alias m="git commit -m "
alias am="git commit -am "
alias a="git add "
alias o-="git checkout --"
alias o="git checkout"
alias om="git checkout master"
alias rh="git reset HEAD"
alias gl="git ls"
alias gl5="git ls -5"
alias gl10="git ls -10"
alias gs="git stash"
alias gsl="git stash list"
alias blame="git log -p -M --follow --stat -- "
alias br='for k in `git branch | perl -pe s/^..//`; do echo -e `git show --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k -- | head -n 1`\\t$k; done | sort -r'
alias um="update-code-sk"
alias umm="update-code-sk main"
alias umf="update-code-sk formplayer"
alias umd="update-code-sk develop"
alias dm="delete-merged"
alias branch="git current-branch"
alias gpo='git push origin $(branch)'
alias gpof='git push origin $(branch) --force'
alias gap='git add -p'
alias gu='git pull origin $(branch)'
alias lock='bash -c "sleep 1 && xtrlock"'
alias start_docker='cd ~/src/cchq && ./scripts/docker up -d && ./scripts/docker citus up -d'
alias dimagi-gpg="gpg --keyring dimagi.gpg --no-default-keyring"
alias ccp="cchq production"
alias ccpssh="cchq production ssh"
alias elastichq="docker run -p 5000:5000 elastichq/elasticsearch-hq"
alias peek="flatpak run com.uploadedlobster.peek"
alias hq-up="./scripts/docker up -d postgres couch redis elasticsearch2 zookeeper kafka minio formplayer"
alias hq-up-min="./scripts/docker up -d postgres couch redis elasticsearch2 zookeeper kafka minio"
alias docker-compose="docker compose"
alias workon="pyenv activate"

############################################
# PROMPT
# http://engineerwithoutacause.com/show-current-virtualenv-on-bash-prompt.html
############################################
RED='\[\033[31m\]'
GREEN='\[\033[32m\]'
YELLOW='\[\033[33m\]'
BLUE='\[\033[34m\]'
PURPLE='\[\033[35m\]'
CYAN='\[\033[36m\]'
WHITE='\[\033[37m\]'
NIL='\[\033[00m\]'

# Hostname styles
FULL='\H'
SHORT='\h'

# System => color/hostname map:
# UC: username color
# LC: location/cwd color
# HD: hostname display (\h vs \H)
# Defaults:
UC=$GREEN
LC=$BLUE
HD=$FULL


# Prompt function because PROMPT_COMMAND is awesome
function set_prompt() {
    # show the host only and be done with it.
    host="${UC}${HD}${NIL}"

    # Special vim-tab-like shortpath (~/folder/directory/foo => ~/f/d/foo)
    _pwd=`pwd | sed "s#$HOME#~#"`
    if [[ $_pwd == "~" ]]; then
       _dirname=$_pwd
    else
       _dirname=`dirname "$_pwd" `
        if [[ $_dirname == "/" ]]; then
              _dirname=""
        fi
       _dirname="$_dirname/`basename "$_pwd"`"
    fi
    path="${LC}${_dirname}${NIL}"
    myuser="${UC}\u@${NIL}"

    # Dollar/pound sign
    end="${LC}\$${NIL} "

    # Virtual Env
    if [[ $VIRTUAL_ENV != "" ]]
       then
           venv=" ${RED}(${VIRTUAL_ENV##*/})"
    else
       venv=''
    fi
    
    GIT='$(__git_ps1 " (%s)")'
    export PS1="\[\e]0;\u@\h: \w\a\]${myuser}${path}${venv}${NIL}${GIT}${end}"
    # simple ps1 for demos
    # export PS1="\[\e]0;\u@\h: \w\a\] ${end}"
}

export PROMPT_COMMAND=set_prompt

############################################
# SSH Agent
############################################

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


############################################
# Utility functions
############################################

function tunnel {
  HOST="$1"
  REMOTE_PORT="$2"
  LOCAL_PORT="${3:-5000}"
  ssh -L localhost:$LOCAL_PORT:$HOST:$REMOTE_PORT $HOST -v
}

function fix_pycharm {
    # https://youtrack.jetbrains.com/issue/IDEA-78860
    ibus-daemon -rd
}

function clear_kafka {
  sudo rm -r ~/.local/share/dockerhq/zookeeper ~/.local/share/dockerhq/kafka
  ./scripts/docker restart
  ./manage.py create_kafka_topics
}

function hammer() {
    git checkout master
    git pull origin master
    git submodule update --init --recursive
    update-code-sk
    delete-merged
    pip install -r requirements/requirements.txt
    find . -name '*.pyc' -delete
    ./manage.py migrate
}

function gsa() {
	git stash apply "stash@{$1}"
}

function vpnshow() {
  vpns1=`ps ax -o args | grep -v grep | grep vpnc | cut -d " " -f2 | paste -sd "," -`
  vpns2=`nmcli c show --active | grep vpn | cut -d' ' -f1 | paste -sd "," -`
  printf "$vpns1\n$vpns2" | grep -Ev "^$" | paste -sd ","
}

function vu() {
    vpn=$1
    if [ "$vpn" == "prod" ]; then
      nmcli c up aws_prod
    elif [ "$vpn" == "staging" ]; then
      nmcli c up aws_staging
    elif [ "$vpn" == "india" ]; then
      nmcli c up aws_india
      #MotionPro &
    elif [ "$vpn" == "tcl" ]; then
      sudo openfortivpn -c /etc/openfortivpn/tcl.config
    elif [ "$vpn" == "va" ]; then
      sudo vpnc-connect rackspace-va
    else
      nmcli c up "$vpn"
    fi
}

function vd() {
    vpn="$1"
    if [ "$vpn" == "prod" ]; then
      nmcli c down aws_prod
    elif [ "$vpn" == "staging" ]; then
      nmcli c down aws_staging
    elif [ "$vpn" == "india" ]; then
      nmcli c down aws_india
      #MotionPro &
    elif [ "$vpn" == "va" ]; then
      sudo vpnc-disconnect
    else
      nmcli c down "$vpn"
    fi
}

function delete-pyc() {
    find . -name '*.pyc' -delete
}

function pull-latest-branch() {
    branch=${1:-master}
    git checkout $branch; git pull origin $branch &
    git submodule foreach --recursive "git checkout $branch; git pull origin $branch &"
    until [ -z "$(ps aux | grep '[g]it pull')" ]; do sleep 1; done
}

function update-code-sk() {
    pull-latest-branch $1
    echo "Deleteing all compiled python"
    delete-pyc
    git submodule update --init --recursive
    delete-merged $1
}

function delete-merged() {
    branch=${1:-master}
    if [ $(branch) = $branch ]
        then git branch --merged $branch | grep -v '\*' | xargs -I {} bash -c 'if [ -n "{}" ]; then git branch -d "{}"; fi'
        else echo "You are not on branch $branch"
    fi

    git submodule foreach --recursive "git branch --merged $branch | grep -v '\*' | xargs -I {} bash -c 'if [ -n \"{}\" ]; then git branch -d \"{}\"; fi'"

    git remote prune origin
}

function update-mobile-code() {
    for src in "commcare" "javarosa" "commcare-odk"; do
        (cd $src; git checkout master; git pull)&
    done
    until [ -z "$(ps aux | grep '[g]it pull')" ]; do sleep 1; done
}

function force-edit-url {
    git remote set-url origin $(gpo 2>&1 | grep Use | awk '{print $2}')
}

function delete-origin {
    # delete branches that have been deleted in origin
    git fetch
    git remote prune origin
}

function delete-merged-remote() {
    # delete branches on remote that have been merged
    delete-origin
    git branch --remote --merged master | grep -v 'master$' | sed s:origin/:: | xargs -I% git push origin :%
}

function es-list() {
    curl -s 'http://localhost:9200/_status' | jsawk 'return Object.keys(this.indices).join("\n")'
}

function es-alias() {
    curl -XPOST 'http://localhost:9200/_aliases' -d \
        '{ "actions": [ {"add": {"index": "'"$1"'_'"$2"'", "alias": "'$1'"}}]}'
}

function docker_cleanup() {
    running=$(sudo docker ps -qf name=docker-cleanup)
    if [[ -n $running ]]; then
      sudo docker rm -f docker-cleanup
    fi

    sudo docker run \
      --rm
      -v /var/run/docker.sock:/var/run/docker.sock:rw \
      -v /var/lib/docker:/var/lib/docker:rw \
      -e CLEAN_PERIOD=3600 \
      -e LOOP=false
      -e KEEP_IMAGES=redis:latest,klaemo/couchdb:latest,postgres:9.4,python:2.7,elasticsearch:1.7.4,dimagi/commcarehq_base:latest,hqservice_postgres:latest,hqservice_elasticsearch:latest,commcarehq_web,spotify/kafka \
      --name=docker-cleanup \
      -d \
      meltwater/docker-cleanup:latest
}

eval "$(direnv hook bash)"
