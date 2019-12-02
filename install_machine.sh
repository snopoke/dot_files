sudo apt-get install virtualenvwrapper git python3 network-manager-vpnc vpnc docker

keepassXC
chromium
skype
slack
spotify

mkdir src
cd src
git clone --depth 1 --recursive --recurse-submodules https://github.com/dimagi/commcare-hq.git cchq

pip install -U pip

mkvirtualenv hq
workon hq
pip install -r requirements/requirements.txt

sudo add-apt-repository ppa:webupd8team/sublime-text-2
sudo apt-get update
sudo apt-get install sublime-text


VPN
sudo vpnc rackspace
sudo vpnc-disconnect 


install vagrant
 * get deb from http://www.vagrantup.com/downloads

