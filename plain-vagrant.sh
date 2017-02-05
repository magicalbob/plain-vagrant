#!/bin/bash

set -e

# cd into the vagrant directory (this is for automated start)
cd $(dirname $0)

# force destruction of the vagrant, in case it is already set up
vagrant destroy -f

# bring up the vagrant environment
vagrant up

# make sure all the machines are configured (as salt minions, with right hostname etc)
ruby prepare.rb

# should set up salt-master first (should .... but haven't yet)

# now run the salt roles on each of the machines
ruby install.rb
