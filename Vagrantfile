# -*- mode: ruby -*-
# # vi: set ft=ruby :
 
# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"
 
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
  print "Couldn't get the salt pillar file #{salt_env}_hosts.sls\n"
  exit 3
end

if not FileTest.exist?salt_pillar
  print "Couldn't find the salt pillar file #{salt_env}_hosts.sls\n"
  exit 4
end

# Work out logs directory
salt_log=Dir.pwd + "/logs"

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |vagrant_config|

  servers=%x[ruby get_hosts.rb --names-only].split("\n")

  # Iterate through entries in YAML file
  servers.each do |server|
    begin
      vagrant_config.vm.define server do |srv|
        # If the server is the salt master mount the saltstack
        if config['salt_master'] == server
          srv.vm.synced_folder config['salt_states'], "/srv/salt"
          srv.vm.synced_folder config['salt_pillar'], "/srv/pillar"
        end
        
        # create shared folder for install.rb to put logs in to
        srv.vm.synced_folder salt_log, "/root/logs"

        # Increae timeout (so visual basic has time to do what it needs to do)
        srv.vm.boot_timeout=6000

        # If special settings are set in the config for this machine set them up
        special_box=""
        special_memory=config['default_memory']
        special_disks=""
        config['special_box'].each do |special|
          if special['host'] == server
            special_box=special['box']
            special_memory=special['memory']
            # mounts is an optional list of host directory and where to mount in box
            if special['mounts'].is_a?(Array)
              special['mounts'].each do |special_mounts|
                srv.vm.synced_folder special_mounts[0], special_mounts[1], type: "rsync"
              end
            end
            # extra_disks is an optional list of disk file name and size in GB
            if special['extra_disks'].is_a?(Array)
              special_disks=special['extra_disks']
            end
            break
          end
        end
        # set the vagrant box. Use default if a specific box has not been specified.
        if special_box == ""
          srv.vm.box=config['default_box']
        else
          srv.vm.box=special_box
        end 
        # get the ip of the machine from the pillar. Use it to set the private NIC
        get_ip="ruby get_hosts.rb #{server}"
        srv_ip=""
        IO.popen(get_ip) { |f| srv_ip=f.gets }
        srv_ip=srv_ip.split("\n")[0]
        srv.vm.network "private_network", ip: srv_ip
        srv.vm.provider :virtualbox do |vb|
          vb.name = server
          vb.memory = special_memory
          # Attach any extra disks specified in config
          if special_disks.is_a?(Array)
            disk_id=0
            special_disks.each do |extra_disk|
              if not File.exist?(extra_disk[0])
                vb.customize [
                  'createhd',
                  '--filename', extra_disk[0],
                  '--format', 'VDI',
                  '--size', extra_disk[1] * 1024
                ]
              end
              vb.customize [
                'storageattach', :id,
                '--storagectl', 'IDE Controller', # The name may vary
                '--port', 1, '--device', disk_id,
                '--type', 'hdd', '--medium',
                extra_disk[0]
              ]
              disk_id+=1
            end
          end
          # Set cpu count to 1 (for virtualbox running in a VM)
          vb.cpus = 1
        end
      end
    rescue StandardError, SyntaxError, NameError => boom
#        do nothing - it'll be the salt pillar top level (probably)
    end
  end
end
