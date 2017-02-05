#!/usr/bin/env ruby

# Goes through a salt pillar (specified in the config file) of hostnames and set each one ready
# for salt to build it with the right role.

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

# Find the IP of salt-master first
salt_master=config['salt_master']
master_cmd="ruby get_hosts.rb #{salt_master}"
master_IP=""
IO.popen(master_cmd) { |f| master_IP=f.gets }
master_IP=master_IP.split("\n")[0]

# Make sure eth1 is up on each machine (this seems to be a bug)
servers=%x[ruby get_hosts.rb --names-only].split("\n")

# Iterate through host in the environment 
servers.each do |server|
  master_cmd="vagrant ssh -c \"sudo su -c \'ifup eth1\'\" #{server}"
  master_res=""
  IO.popen(master_cmd) { |f| master_res=f.gets }
  print master_res
end

# Set up /etc/hosts of salt-master
master_cmd="vagrant ssh -c \"sudo su -c \'echo #{master_IP} #{salt_master} salt \>\> /etc/hosts\'\" #{salt_master}"
master_res=""
IO.popen(master_cmd) { |f| master_res=f.gets }
print master_res

# Set up hostname of salt-master
master_cmd="vagrant ssh -c \"sudo su -c \'hostname #{salt_master}\'\" #{salt_master}"
master_res=""
IO.popen(master_cmd) { |f| master_res=f.gets }
print master_res

# Set salt-master to always start
master_cmd="vagrant ssh -c \"sudo su -c \'chkconfig salt-master on\'\" #{salt_master}"
master_res=""
IO.popen(master_cmd) { |f| master_res=f.gets }
print master_res

# Increase timeout of salt-master
master_cmd="vagrant ssh -c \"sudo su -c \'echo timeout: 600 >> /etc/salt/master\'\" #{salt_master}"
master_res=""
IO.popen(master_cmd) { |f| master_res=f.gets }
print master_res

# Start salt-master
master_cmd="vagrant ssh -c \"sudo su -c \'service salt-master start\'\" #{salt_master}"
master_res=""
IO.popen(master_cmd) { |f| master_res=f.gets }
print master_res

# Now loop through all the machines to start their salt-minion
servers=%x[ruby get_hosts.rb --names-only].split("\n")

# Iterate through host in the environment 
servers.each do |server|
  # Set up /etc/hosts of minion
  master_cmd="vagrant ssh -c \"sudo su -c \'echo #{master_IP} #{salt_master} salt \>\> /etc/hosts\'\" #{server}"
  master_res=""
  IO.popen(master_cmd) { |f| master_res=f.gets }
  print master_res

  # Set up hostname of minion
  master_cmd="vagrant ssh -c \"sudo su -c \'hostname #{server}\'\" #{server}"
  master_res=""
  IO.popen(master_cmd) { |f| master_res=f.gets }
  print master_res

  # Work out role of machine
  salt_role=server.split("-")[server.split("-").length - 2]
  numeric_tail=Integer(salt_role[-1]) rescue false
  if numeric_tail
    salt_role=salt_role[0..-2]
  end

  # Set up grains of minion
  master_cmd="vagrant ssh -c \"sudo su -c \'echo environment: #{salt_env} > /etc/salt/grains && echo role: #{salt_role} >> /etc/salt/grains\'\" #{server}"
  master_res=""
  IO.popen(master_cmd) { |f| master_res=f.gets }
  print master_res

  # Set the salt-minion to auto-start if machine re-starts
  master_cmd="vagrant ssh -c \"sudo su -c \'chkconfig salt-minion on\'\" #{server}"
  master_res=""
  IO.popen(master_cmd) { |f| master_res=f.gets }
  print master_res

  # Start the salt-minion
  master_cmd="vagrant ssh -c \"sudo su -c \'service salt-minion start\'\" #{server}"
  master_res=""
  IO.popen(master_cmd) { |f| master_res=f.gets }
  print master_res
end

# Finally, accept the salt key of each of the minions (except the salt-master)
servers.each do |server|
  # Accept salt key
  master_cmd="vagrant ssh -c \"sudo su -c \'salt-key -y -a #{server}\'\" #{salt_master}"
  master_res=""
  IO.popen(master_cmd) { |f| master_res=f.gets }
  print master_res
end
