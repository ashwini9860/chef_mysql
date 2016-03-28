#
# Cookbook Name:: press
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#

# All rights reserved - Do Not Redistribute
#

directory "/var/www" do
action :create
mode '0755'
owner 'root'
group 'root'
end

execute "wordpress" do
command "wget -P /var/www http://wordpress.org/latest.tar.gz"
#command "sudo tar -xvf /home/ubuntu/latest.tar.gz"
action :run
not_if do
File.exist?("/var/www/latest.tar.gz")
end
end

execute "untar" do
command "tar -xf /var/www/latest.tar.gz -C /var/www"
action :run
not_if do
File.exist?("/var/www/wordpress")
end
end
execute "copy" do
command "cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config-sample.php.disable"
action :run
not_if do
File.exist?("/var/www/wordpress/wp-config-sample.php.disable")
end
end

template "/var/www/wordpress/wp-config-sample.php" do
source "wp-config.php.erb"
variables(
	:db_name => node['bsql']['dbname'],
	:db_user => node['bsql']['dbusername'],
	 
	:db_password => node['bsql']['dbpassword']
)
mode '0755'
owner 'root'
group 'root'
action :create
end
template "/var/www/wordpress/wp-config.php" do
source "wp-newconfig.php.erb"
variables(
	:db_name => node['bsql']['dbname'],
	:db_user => node['bsql']['dbusername'],
	:db_password => node['bsql']['dbpassword']
)
mode '0755'
owner 'root'
group 'root'
action :create
end
