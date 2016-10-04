#
# Cookbook Name:: edgemicro
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'yum'
include_recipe 'tar'
include_recipe 'firewalld'
#include_recipe 'yum-epel'
#include_recipe 'net-tools'

user_home = '/home/' + node['edgemicro']['user']

user 'Creating edgemicro user' do
  username node['edgemicro']['user']
  comment 'edgemicro user'
  home "#{user_home}"
  shell '/bin/bash'
end


cookbook_file 'Create init script in users home directory' do
  path "#{user_home}/" + node['edgemicro']['initscript']
  user node['edgemicro']['user']
  source node['edgemicro']['initscript']
  mode node['edgemicro']['initscript_mode']
end

execute node['edgemicro']['initscript'] do
  command './' + node['edgemicro']['initscript']
  #cwd '/root'
  #user 'root'
  cwd "#{user_home}"
  user node['edgemicro']['user']
end

if (node['edgemicro']['nginx_enabled'] == true) then
  include_recipe 'nginx'

  ##open port 80
  firewalld_service 'http' do
    action :add
    zone   'public'
  end

  directory "#{user_home}/nginx" do
  #directory '/home/vagrant/nginx' do
    #path "#{user_home}/nginx"
    #path "/home/vagrant/nginx"
    owner node['edgemicro']['user']
    group node['edgemicro']['user']
    mode '0777'
    action :create
  end

  #Update the ngnix conf file
  cookbook_file "#{user_home}/nginx/" + node['edgemicro']['nginx_conf'] do
  #cookbook_file "/home/vagrant/nginx/" + node['nginx']['conf'] do
    owner node['edgemicro']['user']
    path "#{user_home}/nginx/" + node['edgemicro']['nginx_conf']
    #path "/home/vagrant/nginx/" + node['nginx']['conf']
    source node['edgemicro']['nginx_conf']
    mode node['edgemicro']['nginx_conf_mode']
  end


  replacement_string = ''
  port = node['edgemicro']['nginx_upstream_port']

  ruby_block 'update the replacement_string' do
    block do
      #Chef::Config.from_file("/etc/chef/client.rb")
      for i in 1..node['edgemicro']['processes'] do
        if (i > 1)
          port += 1
          #previous_port = port_current - 1
        end
        replacement_string += 'server localhost:' + port.to_s + ";\r\n"
      end

    end
    action :run
  end


  bash 'replacement string' do
    code <<-EOF
      echo "#{replacement_string}"
    EOF
  end

  ruby_block 'update the nginx.conf file' do
    block do

      #Find and replace the contents of nginx.conf
      file_names = ["#{user_home}/nginx/" + node['edgemicro']['nginx_conf']]
      #file_names = ["/vagrant/home/nginx/" + node['nginx']['conf']]

      file_names.each do |file_name|
        text = File.read(file_name)
        new_contents = text.gsub(/REPLACEME/, "#{replacement_string}")

        # To merely print the contents of the file, use:
        puts new_contents

        # To write changes to the file, use:
        File.open(file_name, "w") {|file| file.puts new_contents }
      end
    end
    action :run
  end

  nginx_conf = node['edgemicro']['nginx_conf']


  #restart nginx gracefully
  bash 'Restart nginx' do
    code <<-EOF
      nginx -s stop
      nginx -c #{user_home}/nginx/#{nginx_conf}
    EOF
  end

end #if (node['edgemicro']['nginx_enabled'] == true)

node_tar_ball = 'node-' + node['edgemicro']['node_version'] + '-' + node['edgemicro']['node_os_version'] + '.tar.gz'
node_uri = 'https://nodejs.org/dist/' + node['edgemicro']['node_version'] + "/#{node_tar_ball}"

=begin
remote_file "Download Node LTS" do
  path "#{user_home}/#{node_tar_ball}"
  source "#{node_uri}"
  owner node['edgemicro']['user']
  group node['edgemicro']['user']
  mode node['node']['tarball_mode']
  action :create
  #notifies :run, 'execute[untar]', :immediate
end
=end

tar_extract "#{node_uri}" do
  target_dir '/usr/local/'
  creates '/usr/local/bin/node'
  tar_flags [ '-P','--strip-components 1' ]
  #user node['edgemicro']['user']
  #user 'root'
end

#install edgemicro via npm
bash 'Install edgemicro via npm' do
  code <<-EOF
    npm install -g edgemicro@#{node['edgemicro']['version']}
  EOF
end


results = "/tmp/configure_output.txt"
file results do
  action :delete
end

#ENV['MICROGATEWAY_INSTALL'] = "/usr/local/share/" + node['edgemicro']['folder_prefix'] + node['edgemicro']['version']
ENV['EDGEMICRO_KEY'] = ''
ENV['EDGEMICRO_SECRET'] = ''

node_results = "/tmp/node_version.txt"
file node_results do
  action :delete
end

bash 'configure microgateway' do
  #user node['edgemicro']['user']
  code <<-EOF
    node -v > /tmp/node_version.txt
    edgemicro init &> init.txt
    edgemicro configure -o #{node['edge']['org']} -e #{node['edge']['env']} -u #{node['edge']['org_admin']} -p #{node['edge']['org_admin_password']} &> #{results}
  EOF
end

#echo $MICROGATEWAY_INSTALL
#$MICROGATEWAY_INSTALL/cli/edgemicro configure -o org -e env -u user@apigee.com -p password &> #{results}

=begin
execute "configure microgateway" do
  cwd "/apigee-edge-micro-2.0.4/cli"
  command "./edgemicro configure -o org -e env -u user@apigee.com -p password &> #{results}"
end
=end

key = "/tmp/key.txt"
file key do
  action :delete
end

secret = "/tmp/secret.txt"
file secret do
  action :delete
end

bash 'extract key and secret' do
  code <<-EOF
  grep key: /tmp/configure_output.txt | sed 's/key:\s//' | sed -e 's/^[ \t]*//' > /tmp/key.txt
  grep secret: /tmp/configure_output.txt | sed 's/secret:\s//' | sed -e 's/^[ \t]*//' > /tmp/secret.txt
EOF
#environment ({ 'EDGEMICRO_KEY' => "/tmp/key.txt" })
#environment ({ 'EDGEMICRO_SECRET' => "/tmp/secret.txt" })
end

bash 'extract key and secret' do
  code <<-EOF
EOF
environment ({ 'EDGEMICRO_KEY' => "cat /tmp/key.txt" })
environment ({ 'EDGEMICRO_SECRET' => "cat /tmp/secret.txt" })
end

port_current = node['edgemicro']['port']
#directory = "#{user_home}"
directory = "root"


for i in 1..node['edgemicro']['processes'] do
  if (i > 1)
    port_current += 1
    previous_port = port_current - 1

=begin
    #this code is not needed anymore since we have the --port option
    bash 'change port' do
        #user node['edgemicro']['user']
        #action :nothing
        #notifies :run, 'bash[reset port back to 8000]', :immediate
        code <<-EOF
          sudo sed -i -- 's/#{previous_port}/#{port_current}/g' #{directory}/.edgemicro/#{node['edge']['org']}-#{node['edge']['env']}-config.yaml
          sudo cat #{directory}/.edgemicro/#{node['edge']['org']}-#{node['edge']['env']}-config.yaml
        EOF
    end
=end
  end

  if (node['edgemicro']['nginx_enabled'] == false) then
    firewalld_port port_current.to_s + '/tcp' do
      action :add
      zone   'public'
    end
  end

  start_results = "/tmp/start_output_port_" + port_current.to_s + ".txt"
  file start_results do
    action :delete
  end

  if node['edgemicro']['cluster_enabled'] == true
    bash 'start microgateway as background process in cluster mode ' + port_current.to_s do
      #user node['edgemicro']['user']
      #notifies :run, 'bash[start 2nd microgateway as background process]', :immediate
      #user 'vagrant' #this does not run the command as the vagrant user
      code <<-EOF
        edgemicro start -o #{node['edge']['org']} -e #{node['edge']['env']} -k $(cat /tmp/key.txt) -s $(cat /tmp/secret.txt) -c -p #{node['edgemicro']['cluster_processes']} --port #{port_current} &> #{start_results} &
        sleep 7
      EOF
    end

  else

    bash 'start microgateway as background process ' + port_current.to_s do
      #user node['edgemicro']['user']
      #notifies :run, 'bash[start 2nd microgateway as background process]', :immediate
      #user 'vagrant' #this does not run the command as the vagrant user
      code <<-EOF
        edgemicro start -o #{node['edge']['org']} -e #{node['edge']['env']} -k $(cat /tmp/key.txt) -s $(cat /tmp/secret.txt) --port #{port_current} &> #{start_results} &
        sleep 7
      EOF
    end
  end
end
