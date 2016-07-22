############################################
# exports and vars
############################################
export SCALA_HOME=~/dev/scala-2.11.6
export GRADLE_HOME=~/dev/gradle-2.5
export M2_HOME=/home/skelly/dev/apache-maven-3.3.9
export PATH=$PATH:~/bin:$SCALA_HOME/bin:$GRADLE_HOME/bin:$M2_HOME/bin
export EDITOR=vi
test -f ~/.pythonrc && export PYTHONSTARTUP=~/.pythonrc
export TERM="xterm-color"
export MAVEN_OPTS="-Xmx512m"
export CATALINA_OPTS="-Xms1024m -Xmx2048m -XX:MaxPermSize=1024m"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt
rs='.internal.commcarehq.org'
va='.internal-va.commcarehq.org'
india='.india.commcarehq.org'

############################################
# aliases
############################################
alias bp="sublime-text ~/.bash_profile"
alias rl="source ~/.bash_profile"
alias ll="ls -al"
alias g="git"; __git_complete g _git
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
alias br='for k in `git branch | perl -pe s/^..//`; do echo -e `git show --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k -- | head -n 1`\\t$k; done | sort -r'
alias uc="update-code"
alias um="update-code; delete-merged"
alias umobile="update-mobile-code"
alias celery="./manage.py celeryd --verbosity=2 -c 2 --beat --statedb=celery.db --events"
alias branch="git branch | grep '^\*' | sed 's/* //'"
alias gpo='git push origin $(branch)'
alias gpof='git push origin $(branch) --force'
alias gap='git add -p'
alias cloudant='ssh -D 5000 -C -q -N hqdb0.internal.commcarehq.org'
alias cloudant-india='ssh -D 5001 -C -q -N db0.india.commcarehq.org'
alias lock='bash -c "sleep 1 && xtrlock"'
alias start_docker='cd ~/src/cchq && ./scripts/docker up -d'
alias go='start_docker& start_agent'


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

    # Dirtiness from:
    # http://henrik.nyh.se/2008/12/git-dirty-prompt#comment-8325834
    if git update-index -q --refresh 2>/dev/null; git diff-index --quiet --cached HEAD --ignore-submodules -- 2>/dev/null && git diff-files --quiet --ignore-submodules 2>/dev/null
        then dirty=""
    else
       dirty="${RED}*${NIL}"
    fi
    _branch=$(git symbolic-ref HEAD 2>/dev/null)
    _branch=${_branch#refs/heads/} # apparently faster than sed
    branch="" # need this to clear it when we leave a repo
    if [[ -n $_branch ]]; then
       branch=" ${NIL}[${PURPLE}${_branch}${dirty}${NIL}]"
    fi

    # Dollar/pound sign
    end="${LC}\$${NIL} "

    # Virtual Env
    if [[ $VIRTUAL_ENV != "" ]]
       then
           venv=" ${RED}(${VIRTUAL_ENV##*/})"
    else
       venv=''
    fi

    # VPN
    local vpns=`ps ax -o args | grep -v grep | grep vpnc | cut -d " " -f2 | paste -sd "," -`
    if [ ! -z "$vpns" ] ; then
        vpn="${NIL}(${vpns}) "
    else
        vpn=''
    fi

    export PS1="${vpn}${myuser}${path}${venv}${branch} ${end}"
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

function fix_pycharm {
    # https://youtrack.jetbrains.com/issue/IDEA-78860
    ibus-daemon -rd
}

function hammer() {                                                                                  
    git checkout master                                                                              
    git pull origin master                                                                           
    git submodule update --init --recursive                                                          
    pip install -r requirements/requirements.txt                                                        
    find . -name '*.pyc' -delete                                                                  
    ./manage.py migrate                                                  
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

function vpnva() {
    sudo vpnc va
}

function vpndone() {
    sudo vpnc-disconnect 
    sudo poff
}

function delete-pyc() {
    find . -name '*.pyc' -delete
}

function pull-latest-master() {
    git checkout master; git pull origin master &
    git submodule foreach --recursive 'git checkout master; git pull origin master &'
    until [ -z "$(ps aux | grep '[g]it pull')" ]; do sleep 1; done
}

function update-code() {
    pull-latest-master
    echo "Deleteing all compiled python"
    delete-pyc
}
 
function delete-merged() {
    if [ $(branch) = 'master' ]
        then git branch --merged master | grep -v '\*' | xargs -I {} bash -c 'if [ -n "{}" ]; then git branch -d "{}"; fi'
        else echo "You are not on branch master"
    fi
                                            
    git submodule foreach --recursive "git branch --merged master | grep -v '\*' | xargs -I {} bash -c 'if [ -n \"{}\" ]; then git branch -d \"{}\"; fi'"
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

function clean_time_pull() {
    dos2unix -q $1
    head -n 2 $1 | tail -n 1 
    grep -v "Time Report\|^Date,\|^Total\|^\s*$" $1 | grep "Simon Kelly" 
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