# Summary
This cookbook should be used as an example of how to automate the process of
running multiple instances of Microgateway on a single VM.  This doc
outlines how to accomplish this with Chef 12.0, Node.js and Nginx.

# edgemicro Cookbook

This cookbook starts Apigee Edgemicro 2.1.1 via npm and it will install the following components:
- Nginx
- Node LTS
- Edgemicro

If you enable Nginx from the attributes/default.rb file then it will
- install Nginx which will listen on port 80
- install and enable firewalld and only open ports 22, 80


## Requirements

This cookbook was tested on CentOS 7.

You must have an Apigee Edge public account.

You must create an edgemicro aware proxy.  Please see the following link which describes how to create the proxy in Edge.
- http://docs.apigee.com/microgateway/latest/edge-microgateway-tutorial

You should also have a target service to which the Apigee edgemicro proxy will send requests.

### Platforms

- CentOS 7

### Chef

- Chef 12.0 or later

### Microgateway
Microgateway is installed via the Node.js package manager, NPM, which is the preferred
way to install the Microgateway.

i.e.
```
npm install -g edgemicro@latest
```
or
```
npm install -g edgemicro@2.1.1
```

### Cookbooks
Depends on the following cookbooks when you enable nginx:
- `firewalld` to enable specific ports
- `nginx` to proxy requests to Edgemicro

Depends on the following cookbooks whether you enable or disable nginx:
- `yum` - to update all the yum repositories
- `tar` - to untar installation files
- `zipfile` - to unzip the microgateway zip file

## Attributes
- node['edgemicro']['user'] = 'vagrant'
- node['edgemicro']['initscript'] = 'init.sh'
- node['edgemicro']['initscript_mode'] = '0777'
- node['edgemicro']['version'] = '2.1.1'
- node['edgemicro']['folder_prefix'] = 'apigee-edge-micro-'
- node['edgemicro']['port'] = 8000
- node['edgemicro']['nginx_upstream_port'] = 8000
- node['edgemicro']['cluster_enabled'] = false
- node['edgemicro']['cluster_processes'] = 2
- node['edgemicro']['processes'] = 2
- node['edgemicro']['node_version'] = 'v4.4.7'
- node['edgemicro']['node_os_version'] = 'linux-x64'
- node['edgemicro']['node_tarball_mode'] = '0777'
- node['edgemicro']['nginx_enabled'] = true
- node['edgemicro']['nginx_conf'] = 'nginx.conf'
- node['edgemicro']['nginx_conf_mode'] = '0777'

Please update the following attributes
- node['edge']['org'] = 'apigee_edge_orgname'
- node['edge']['env'] = 'apigee_edge_environment'
- node['edge']['org_admin'] = 'apigee_edge_org_admin'
- node['edge']['org_admin_password'] = 'apigee_edge_org_admin_password'


<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['edgemicro']['user']</tt></td>
    <td>String</td>
    <td>edgemicro user</td>
    <td><tt>edgemicro</tt></td>
  </tr>
   <tr>
    <td><tt>['edgemicro']['init']</tt></td>
    <td>String</td>
    <td>inital run script; currently this file is blank.</td>
    <td><tt>init.sh</tt></td>
  </tr>
   <tr>
    <td><tt>['edgemicro']['initscript_mode']</tt></td>
    <td>String</td>
    <td>This is sets the mode for the init script when it is copied to the VM.</td>
    <td><tt>0777</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['version']</tt></td>
    <td>String</td>
    <td>This should be the latest version.</td>
    <td><tt>2.1.1</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['folder_prefix']</tt></td>
    <td>String</td>
    <td>The version above is appended to the folder prefix and this is the folder name that is extracted from the zip file downloaded from Apigee.</td>
    <td><tt>apigee-edge-micro-</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['port']</tt></td>
    <td>Number</td>
    <td>Default starting port for Edgemicro. Do not change this port value.</td>
    <td><tt>8000</tt></td>
  </tr>

  <tr>
    <td><tt>['edgemicro']['nginx_upstream_port']</tt></td>
    <td>Number</td>
    <td>This is a bit of a hack.  For some reason the port attribute above was not being set correctly when the Chef script executed for nginx.  So I had to define another starting port for Nginx. This should always be the same as t he port attribute above.</td>
    <td><tt>8000</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['cluster_enabled']</tt></td>
    <td>Boolean</td>
    <td>Microgateway has the ability to run in cluster mode with multiple child processes.  This enables cluster mode.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['cluster_processes']</tt></td>
    <td>Number</td>
    <td>If you enable cluster mode, then this controls how many child processes will be started.</td>
    <td><tt>2</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['processes']</tt></td>
    <td>Number</td>
    <td>You have the ability to run multiple Edgemicro parent processes on the same VM. This attribute controls how many processes will be started.  In order to run multiple parent processes on the same VM, then each process must listen on a different port.  The starting port is 8000 and it increments that number by 1 for each additional parent process.</td>
    <td><tt>2</tt></td>
  </tr>

  <tr>
    <td><tt>['edgemicro']['node_version']</tt></td>
    <td>String</td>
    <td>This is the version of Node that Chef will install. The recommended version for Edgemicro is Node LTS.</td>
    <td><tt>v4.4.7</tt></td>
  </tr>
   <tr>
    <td><tt>['edgemicro']['node_os_version']</tt></td>
    <td>String</td>
    <td>OS version on which Node will be installed. </td>
    <td><tt>linux-x64</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['node_tarball_mode']</tt></td>
    <td>String</td>
    <td>This is the mode of the node tar.gz that is downloaded from nodejs.org.</td>
    <td><tt>0777</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['nginx_enabled']</tt></td>
    <td>Boolean</td>
    <td>Enables nginx and firewalld. Only port 80 and 22 will be opened on firewall port.  Nginx will listen on port 80 and forward requests to localhost:edgemicro_port.</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['nginx_conf']</tt></td>
    <td>String</td>
    <td>This override the default nginx.conf with our settings.</td>
    <td><tt>nginx.conf</tt></td>
  </tr>
<tr>
    <td><tt>['edgemicro']['nginx_conf_mode']</tt></td>
    <td>String</td>
    <td>This sets the mode of nginx.conf file when it is copied to the VM.</td>
    <td><tt>0777</tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['org']</tt></td>
    <td>String</td>
    <td>Apigee Edge organization name.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['env']</tt></td>
    <td>String</td>
    <td>Apigee Edge environment name.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['org_admin']</tt></td>
    <td>String</td>
    <td>Apigee Edge org admin email address.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['edgemicro']['org_admin_password']</tt></td>
    <td>String</td>
    <td>Apigee Edge org admin password.</td>
    <td><tt></tt></td>
  </tr>
</table>


## Usage

Make sure to update the following attributes in the attributes/default.rb file.
- node['edge']['org'] = 'apigee_edge_orgname'
- node['edge']['env'] = 'apigee_edge_environment'
- node['edge']['org_admin'] = 'apigee_edge_org_admin'
- node['edge']['org_admin_password'] = 'apigee_edge_org_admin_password'

### Enable Nginx and Firewalld
This will enable Nginx and enable Firewalld on the CentOS machine.
node['edgemicro']['nginx_enabled'] = true

### Change how many parent processes to start
The following attribute will determine how many parent Edgemicro processes to start.

e.g. The processes attribute is set to 2. Therefore, Chef will start 2 Edgemicro processes the first one listening on port 8000 and the second one on listening on port 8001.
- node['edgemicro']['port'] = 8000
- node['edgemicro']['processes'] = 2

If you change the node['edgemicro']['processes'] to 4, then it will start 4 parent processes starting at port 8000 and ending on port 8003.  These ports must be available on the VM.

### Enable Edgemicro cluster mode
By default Edgemicro cluster is disabled.
- node['edgemicro']['cluster_enabled'] = false

To enable Microgateway cluster mode then change the values as shown below.
- node['edgemicro']['cluster_enabled'] = true
- node['edgemicro']['cluster_processes'] = 2

With the setting above, cluster mode is enabled.  The cluster_proceses attribute determines how many child processes each Edgemicro gateway parent process will create.

e.g. If cluster mode is enabled and the cluster_processes attribute is set to 2, then one Edgemicro process will start 2 child processes.  Therefore, there will be 3 processes all together (1 parent and 2 children).


### Kitchen
cd into the edgemicro directory:

- `kitchen list` to list all the kitchen recipes.
- `kitchen converge default-centos-7` to start edgemicro running in an virtual box machine.
- `kitchen destroy` to destroy the edgemicro virtual box VM.
- `kitchen login` to login to the VM.

#### After kitchen up finishes execution
Once Kitchen finished executing you should see a message similar to the one below.

```
-----> Kitchen is finished. (3m5.22s)
```

Now you can run the following command to login to the VM and see nginx and edgemicro running.
```
kitchen login
```

Grep for edgemicro.  You can see the edgemicro instances running on their respective ports.
```
# ps -ef | grep edgemicro

root     12303     1  1 19:09 ?        00:00:00 node /usr/local/bin/edgemicro start -o org -e env -k key -s secret --port 8000
root     12318     1  1 19:09 ?        00:00:00 node /usr/local/bin/edgemicro start -o org -e env -k key -s secret --port 8001
root     12380 12366  0 19:10 pts/0    00:00:00 grep --color=auto edgemicro
```

Grep for nginx. You can see Nginx is running.
```
#ps -ef | grep nginx

root     12232     1  0 19:08 ?        00:00:00 nginx: master process nginx -c /home/vagrant/nginx/nginx.conf
nginx    12233 12232  0 19:08 ?        00:00:00 nginx: worker process
root     12386 12366  0 19:11 pts/0    00:00:00 grep --color=auto nginx
```
#### Send request to nginx
Now you can send requests to the nginx server, which will route requests to the edgemicro.
We start Nginx listening on port 80 by default.

```
# curl http://{ip_of_vm}:80/base_path/pathsuffix
```

### Berksfile
cd into the edgemicro directory.
- `berks install` to install the dependent cookbooks to your local machine (~/.berkshelf).


### edgemicro::default

Just include `edgemicro` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[edgemicro]"
  ]
}
```


## Contributing
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors: Sean Williams

Apache 2.0
