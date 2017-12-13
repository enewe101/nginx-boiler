#!/usr/bin/env bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"


# Enable firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable


# Create a non-root user to run the app
echo creating non-root user called $HOST_USER
useradd --create-home $HOST_USER
echo $HOST_USER:$HOST_USER_PASS | chpasswd
usermod -aG sudo $HOST_USER


# Copy some .vimrc into appuser to make development a bit easier
cp $SCRIPTPATH/../config/.vimrc /home/$HOST_USER/.vimrc


# Install docker
# Remove any old version
echo installing docker...
apt-get remove docker docker-engine docker.io &> /dev/null
apt-get update > /dev/null
apt-get install -y\
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common > /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88 | grep fingerprint
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" > /dev/null
apt-get update > /dev/null
apt-get install -y docker-ce


# Make the HOST_USER able to run docker
echo adding $HOST_USER to docker group...
groupadd docker
usermod -aG docker $HOST_USER
systemctl enable docker


# Install docker-compose
echo installing docker-compose
curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose  
chmod +x /usr/local/bin/docker-compose


# Move the git repo to the HOST_USER's home dir
cp -r $SCRIPTPATH/.. /home/$HOST_USER/app 
cd /home/$HOST_USER/app


# TODO: This is a precaution to prevent accidentally commiting a new project's
# edits to the webap-boiler repo.  Remove only after setting up your new repo
# and breaking ties to the boiler plate repo.
git remote rm origin


# Give the app folder and everything in it to appuser
chown -R $HOST_USER:$HOST_USER /home/$HOST_USER/app


# Drop into the non-root user
su $HOST_USER

