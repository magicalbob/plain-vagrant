#!/usr/bin/env ruby

# Sun the salt role for each machine in vagrant test environment

# Require YAML module
require 'yaml'

# Read YAML config.yaml file
begin
  config = YAML.load_file('config.yaml')
rescue
  print "Cannot open config.yaml\n"
  exit 2
end

begin
  salt_pillar=config['salt_pillar']
  salt_env=config['environment']
  if salt_pillar[-1] != "/"
    salt_pillar=salt_pillar+"/"
  end
  salt_pillar=salt_pillar+salt_env+"_hosts.sls"
rescue
  print "Couldn't get the salt pillar file #{salt_pillar}\n"
  exit 3
end

# Read YAML file with box details
begin
  servers = YAML.load_file(salt_pillar)
rescue
  print "Couldn't open the salt pillar file #{salt_pillar}\n"
  exit 4
end

# Get name of salt master & make sure salt-master is running on it
salt_master=config['salt_master']
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
