#!/usr/bin/env bash

# Initial script to configure Raspbian to execute
# Docker in a virtual python3 environment.

# https://www.raspberrypi.org/blog/docker-comes-to-raspberry-pi/
if ! command -v docker &> /dev/null; then
  curl -sSL https://get.docker.com | sh
fi

# Allow execution as non-root user
sudo usermod -aG docker pi

# http://www.knight-of-pi.org/installing-python3-6-on-a-raspberry-pi/
if ! command -v python3 &> /dev/null; then
  sudo apt-get install python3-dev libffi-dev libssl-dev -y
  wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz
  tar xJf Python-3.6.3.tar.xz
  cd Python-3.6.3
  ./configure
  make
  sudo make install
  sudo rm /usr/bin/python
  sudo ln -s /usr/local/bin/python3 /usr/bin/python
fi

if ! command -v pip3 &> /dev/null; then
  sudo pip3 install --upgrade pip
fi

if ! command -v virtualenv &> /dev/null; then
  # Install virtualenv
  pip3 install --user virtualenv
fi

virtualenv ~/.pihole.venv

. ~/.pihole.venv/bin/activate

# Install docker-compose
# https://docs.docker.com/compose/install/

if ! pip3 list | grep -F 'docker-compose' &>/dev/null; then
  pip3 install docker-compose
fi

#if [ ! -d pihole-doh-letsencrypt ]; then
#  # https://github.com/SoarinFerret/pihole-doh-letsencrypt.git
#  git clone https://github.com/SoarinFerret/pihole-doh-letsencrypt.git
#  cd pihole-doh-letsencrypt
#fi


sudo mkdir -p /pihole_certs
docker-compose pull
docker-compose up -d

# Remove password
#docker exec pihole pihole -a -p

# Create certificates
#  Run once (may need to run in container (docker exec -it letsencrypt_doh /bin/bash)
#docker exec -t letsencrypt_doh certbot certonly --standalone --preferred-challenges dns -d pi-hole.wysechoice.net -d udm.wysechoice.net -d qnap.wysechoice.net -d check-mk.wysechoice.net

