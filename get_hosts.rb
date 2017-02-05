#!/usr/bin/env ruby
# -*- mode: ruby -*-
# # vi: set ft=ruby :

# Goes through a salt pillar (specified in the config file) of hostnames and either
# lists all the host names (if argument --names-only is supplied) or the IP address
# of a specified host otherwise. 
 
# Require YAML module
require 'yaml'

onlyNames=0
hostName=""
 
if ARGV.length != 1
  print "Usage: Usage: get_hosts [--names-only|hostname]\n"
  exit 1
end

if ARGV[0] == "--names-only"
  onlyNames=1
else
  hostName=ARGV[0]
end

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
 
# Iterate through entries in YAML file
servers.each do |servers|
  servers.each do |server_list|
    machine=YAML.load(YAML.dump(server_list))
    begin
      machine.each do |machine_entry|
        if config['zone'] == "BOTH" or
           machine_entry[1]['zone'] == config['zone'] or
           machine_entry[1]['zone'] == "BOTH"
          if onlyNames==1
            excludeHost=0
            begin
              if config['exclude'].include?machine_entry[1]['host_name']
                excludeHost=1
              end
            rescue
            end
            if excludeHost==0
              print machine_entry[1]['host_name']+"\n"
            end
          else
            if hostName == machine_entry[1]['host_name']
              print machine_entry[1]['ip_addr']+"\n"
              exit 0
            end
          end
        end
      end
    rescue StandardError, SyntaxError, NameError => boom
#        print boom
    end
  end
end

if onlyNames==1
  exit 0
end

print "Host #{hostName} not found\n"
exit 50
