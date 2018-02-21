Chef Certification :

https://training.chef.io/basic-chef-fluency-badge
Exam costs : $75

--------
1.2 Setting Up the Lab Environment
-------------------------
Connect to the CentOS machine

#to enable to run sudo 
usermod -g wheel user

Download chef development and install
# wget https://packages.chef.io/files/stable/chefdk/2.4.17/el/7/chefdk-2.4.17-1.el7.x86_64.rpm
Install chef
# sudo rpm -ivh chefdk-2.4.17-1.el7.x86_64.rpm

Run chef client in local mode
# sudo chef-client --local-mode

1.3 Understanding Chef and Chef Convergence
-------------------------------------------
What is Chef?
- Chef put simply, is a configuration management and depolyment tool.
- Chef at its core, is designed for configuration management of nodes within an environment.
- chef has evolved over the years to be a very robust and complete Continuous integration, Continous Deployment, and infrastructure compliance tool.
- Chef is not just for on-premises environemnt, but also cloud based enviroments like AWS and Azure.

Anatomy of a Chef "Convergence"
--Pre-convergence - Phase before a node is configured
  - Lint tests occur in this phase - Lint tests run tools to analyze source code to identify stylistic problems, foodcritic is a tool for this when using chef.

-- Convergencce - Occurs when chef runs on the node.
  - Tests the defined resources to ensure they are in the desired state.
  - If they not, then the resources are put in the desired state(repaired)
  - "providers" are what do the work to enforce the desired configuration.
  - Chef can be run over and over again without changing configurations if configurations are already in place(idempotency)

-- Post-convergence - Occurs after the Chef convergence
  - Run tests that verifies a node is in the desired state of configuration also known as Unit Testing.

2.3 Common Chef Resources
--------------------------

Resources :
- A resource is a statement of desired configuration for a given item.
- A resource describes the desired state and steps for achieving the desired configuration.
- Resources are managed within "recipes" ( which will be covered in later videos) and are generally grouped together within cookbooks for management-specific software and tasks.
- A resource statement defines the desired state of the configuration, a resource maps to "provider" which defines the steps to achieve that desired state of configuration.

Resources:
Chef is idempotent, which means, during a Chef run(aka convergence) Chef determines if the desired configuration within a resource is set; if it is set, Chef does not run anything against the node. If the desired configuration does not match then Chef enforces the desired state configuration.

A resource has four components and is made up of a Ruby block of code
1. Resource Type
2. Resource Name
3. Resource Properties
4. Actions to be applied to the resource. 

Package Resource:
----------------
package 'httpd' do
  action :install
end

Note: In the absent of action, the default is :install
package 'httpd' do
end

what is happening here?
The httpd package is being installed ONLY if it is not already installed.
Why httpd over Nginx?

Package Actions:

:install - install a package(the default if no action is defined)
:nothing - This action does nothing UNTIL it is notified by another resource to perform an action
:purge - Removes the configuration files as well as teh package(Only for Debian)
:reconfig - Reconfigure a package
:remove - Removes a package(also removes configuration files)
:upgrade - Install a package, if it is already installed, ensure it is latest version.

Service Resource Type:
----------------------

service 'httpd' do
  action [:enable, :start]
End

The service httpd is enabled so it starts at boot time and then started so that is currently running

service 'apache' do
  service_name 'httpd'
  action [:enable, :start]
End

Service Actions: Service Actions are available as a property for the service resource type.

:disable - Disable a service so it does not start at startup
:enable - Enable a service to start at boot time
:nothing - Does nothing to the service
:reload - Reloads the service configuration
:start - Starts the service and keeps it running until stopped or disabled.
:restart - Restart a service
:stop - Stop a service

Service resource Type: Notifies property
----------------------------------------
What happens when a change is made that requires a restart to a service?

The notifies property allows a resource to "notify" another resource when the state changes

Example:
-------
file '/etc/httpd/vhost.conf' do
  content 'fake vhost file'
  notifies :restart, 'service[httpd]'
end

NOT_IF & ONLY_IF Guards
-----------------------

NOT IF - prevents a resource from executing when a condition returns true.

execute 'not-if-example' do
  command '/usr/bin/echo "10.0.2.1 webserver01" >> /etc/hosts'
  not_if 'test -z$(grep "10.0.2.1 webserver01" /etc/hosts)'
end

ONLY IF - Allow a resource to execute only if the condition returns true.

execute 'only-if-example' do
  command '/usr/bin/echo "10.0.2.1 webserver01" >> /etc/hosts'
  only_if 'test -z$(grep "10.0.2.1 webserver01" /etc/hosts)'
end

Installing Multiple Packages At One Time
----------------------------------------
%w{httpd vim tree emacs}.each do |pkg|
  package pkg do
    action : upgrade
  end
end

Installing Multiple Packages At One Time

package 'httpd'
  action :install
End

package 'emacs'
end  --#Works but is incorrect

package 'emacs' - it wont work and it is required do or end

Installing Multiple Packages At One Time
----------------------------------------

['mysql-server','mysql-common','mysql-client'].each do |pkg|
  package pkg do
    action :install
  end
end

2.3 Default Resource Actions:
-----------------------------
3 default resource types
1. package

package 'httpd' do
end
#In the absense of a defined "action" property the default action for the package resource type is ":install".

2. Service Resource type

service 'httpd' do
end
#In the absense of a defined "action" property the default action for the service resource type is ":nothing"

3. File Resource Type

file '/etc/motd' do
end
#In the absense of a defined "action" property the default action for teh file resource type is ":create".

2.4 Applying Chef Resource Hands On:
------------------------------------
vim learn.rb
  package 'apache' do
  end
:wq

#checking the ruby syntax
ruby -c learn.rb

#checking the chef syntax
foodcritic learn.rb

#run chef locally
chef-client --local-mode learn.rb

#will get an error as chef wont find the package as 'apache' hecen change the code
vim learn.rb
  package 'httpd' do
  end
:wq

ruby -c learn.rb && foodcritic learn.rb

chef-client --local-mode learn.rb

#systemctl status httpd

vim learn.rb
  package 'httpd' do
  end
  
  service 'httpd' do #default action is nothing hence service wont be restarted
  end 
:wq

vim learn.rb
  package 'httpd' do
  end
  
  service 'httpd' do 
    action [:enable, :start]
  end 
:wq

ruby -c learn.rb && foodcritic learn.rb

chef-client --local-mode learn.rb

resource will be applies which we ordered in recipes


#systemctl status httpd

# put helloworld page content

vim learn.rb
  package 'httpd' do
  end
  
  service 'httpd' do 
    action [:enable, :start]
  end 
  
  file '/var/www/index.html' do
  end

:wq

ruby -c learn.rb && foodcritic learn.rb

chef-client --local-mode learn.rb
resource will be applies which we ordered in recipes

#check the permission on the file
ls -al /var/www

vim learn.rb
  package 'httpd' do
  end
  
  service 'httpd' do 
    action [:enable, :start]
  end 
  
  file '/var/www/index.html' do
    action :delete
  end
  
  file '/var/www/html/index/html' do
    content 'hello world'
    mode '0755'
    owner 'root'
    group 'apache'
  end
  
:wq!

:wq



