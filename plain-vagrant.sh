#!/bin/bash

set -e

# cd into the vagrant directory (this is for automated start)
cd $(dirname $0)

# get salt git
if [ ! -d salt ]
then
  git clone https://github.com/saltstack/salt.git
fi

pushd salt
git checkout develop
popd

# force destruction of the vagrant, in case it is already set up
vagrant destroy -f

# bring up the vagrant environment
vagrant up

# make sure all the machines are configured (as salt minions, with right hostname etc)
ruby prepare.rb

# run state.highstate for salt-master first 
ruby salt-master.rb

# now run the salt roles on each of the machines
ruby install.rb

# make sure terminal is sane
stty sane
