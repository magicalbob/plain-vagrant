#!/usr/bin/env ruby

# Run the salt role for the salt-master

require './config-check.rb'

# Get name of salt master & make sure salt-master is running on it
salt_master=$config['salt_master']
master_cmd="vagrant ssh #{salt_master} -c 'sudo service salt-master status'"
if not system(master_cmd)
  print "salt master is not running! Try again once it is.\n"
  exit 5
end

# Run salt highstate for salt master
master_cmd="vagrant ssh -c \"sudo su -c \'salt-call --log-level=info state.highstate > /root/logs/#{salt_master}.log 2\>\&1\'\" #{salt_master}"
print master_cmd + "\n"
master_res=""
system(master_cmd)
