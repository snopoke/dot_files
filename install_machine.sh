sudo apt-get install virtualenvwrapper couchdb git

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update 
sudo apt-get install google-chrome-stable


keepass

mkdir src
cd src
git clone --depth 1 --recursive --recurse-submodules https://github.com/dimagi/commcare-hq.git cchq

pip install -U pip

mkvirtualenv hq
workon hq
pip install -r requirements/requirements.txt

# java
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get install oracle-java7-installer
java -version

sudo apt-get install keepassx keepass2

sudo apt-get install vpnc network-manager-vpnc

sudo apt-get install postgresql postgresql-contrib postgresql-server-dev-9.3 python-dev
cat requirements/apt-packages.txt | sed 's/#.*$//g' | xargs sudo apt-get install -y
sudo ln -s /usr/include/freetype2 /usr/local/include/freetype


wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-0.90.12.deb
sudo dpkg -i elasticsearch-0.90.12.deb

sudo vi /etc/elasticsearch/elasticsearch.yml
# network.bind_host: localhost
sudo service elasticsearch restart


sudo add-apt-repository ppa:webupd8team/sublime-text-2
sudo apt-get update
sudo apt-get install sublime-text


VPN
sudo vpnc rackspace
sudo vpnc-disconnect 


install vagrant
 * get deb from http://www.vagrantup.com/downloads

 install skype



