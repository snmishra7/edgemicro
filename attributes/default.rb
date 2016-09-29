default['edgemicro']['user'] = 'vagrant'
default['edgemicro']['initscript'] = 'init.sh'
default['edgemicro']['version'] = '2.1.1'
default['edgemicro']['folder_prefix'] = 'apigee-edge-micro-'
default['edgemicro']['port'] = 8000
default['edgemicro']['nginx_upstream_port'] = 8000

#enable nginx
default['edgemicro']['nginx_enabled'] = true
#for clusters
default['edgemicro']['cluster_enabled'] = false
default['edgemicro']['cluster_processes'] = 2 # must be 2 or greater
default['edgemicro']['processes'] = 2

default['edgemicro']['initscript_mode'] = '0777'
default['edgemicro']['nginx_conf'] = 'nginx.conf'
default['edgemicro']['nginx_conf_mode'] = '0777'
default['edgemicro']['node_version'] = 'v4.4.7'
default['edgemicro']['node_os_version'] = 'linux-x64'
default['edgemicro']['node_tarball_mode'] = '0777'

default['edge']['org'] = 'apigee_edge_org_name'
default['edge']['env'] = 'apigee_edge_env'
default['edge']['org_admin'] = 'apige_edge_org_admin'
default['edge']['org_admin_password'] = 'apigee_edge_admin_password'
