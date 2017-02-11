#!/usr/bin/env ruby

# Sun the salt role for each machine in vagrant test environment

require './config-check.rb'

# Get name of salt master & make sure salt-master is running on it
salt_master=$config['salt_master']
print("Salt Master: #{salt_master}\n")
master_cmd="vagrant ssh #{salt_master} -c 'sudo service salt-master status'"
if not system(master_cmd)
  print "salt master is not running! Try again once it is.\n"
  exit 5
end

# Loop through all the minions in the environment and run their state
servers=%x[ruby get_hosts.rb --names-only].split("\n")

# Iterate through each host in the environment, running the salt highstates (but not for master, cos already done that)
servers.each do |server|
  if server != $salt_master
    master_cmd="vagrant ssh -c \"sudo su -c \'salt-call --log-level=info state.highstate > /root/logs/#{server}.log 2\>\&1\'\" #{server}"
    print master_cmd + "\n"
    master_res=""
    Process.spawn(master_cmd) { |f| master_res=f.gets }
    print master_res
  end
end
