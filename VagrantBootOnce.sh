#!/usr/bin/env bash

apt-get update
add-apt-repository ppa:apt-fast/stable
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install apt-fast
sh -c 'echo debconf apt-fast/maxdownloads string 32 | debconf-set-selections'
sh -c 'echo debconf apt-fast/dlflag boolean true | debconf-set-selections'
sh -c 'echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections'

add-apt-repository ppa:plt/racket
apt-get update
apt-fast -y install racket firefox graphviz
#raco pkg install --auto rosette  # DO this manually in user space

apt-fast -y install make
