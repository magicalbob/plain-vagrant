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

# Add pass renderer from develop branch of salt
master_cmd="vagrant ssh #{salt_master} -c \"sudo su -c \'cp /renderers/pass.py /usr/lib/python2.7/site-packages/salt/renderers/\'\""
print master_cmd + "\n"
system(master_cmd)

master_cmd="vagrant ssh #{salt_master} -c \"sudo su -c \'yum install -y pass\'\""
print master_cmd + "\n"
system(master_cmd)

# Run salt highstate for salt master
master_cmd="vagrant ssh -c \"sudo su -c \'salt-call --log-level=info state.highstate > /root/logs/#{salt_master}.log 2\>\&1\'\" #{salt_master}"
print master_cmd + "\n"
master_res=""
system(master_cmd)
