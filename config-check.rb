#!/usr/bin/env ruby
 
# Require YAML module
require 'yaml'

$config=nil

# Read YAML config.yaml file
begin
  $config = YAML.load_file('config.yaml')
rescue
  print "Cannot open config.yaml\n"
  exit 2
end

begin
  salt_pillar=$config['salt_pillar']
  $salt_env=$config['environment']
  if salt_pillar[-1] != "/"
    salt_pillar=salt_pillar+"/"
  end
  salt_pillar=salt_pillar+$salt_env+"_hosts.sls"
rescue
  print "Couldn't get the salt pillar file #{$salt_env}_hosts.sls\n"
  exit 3
end

if not FileTest.exist?salt_pillar
  print "Couldn't find the salt pillar file #{$salt_env}_hosts.sls\n"
  exit 4
end

