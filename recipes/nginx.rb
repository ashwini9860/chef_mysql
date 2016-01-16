#
# Cookbook Name:: gatest
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "php5-fpm" do
action :install
end

package "nginx" do
action :install
end
service "nginx" do
action [:enable, :start]
end
execute "permission" do
command "chown www-data:www-data -R /var/www/"
#command "sudo usermod -G www-data root"
action :run
end

template "/etc/nginx/sites-available/default" do
source "vhost.erb"
variables({
#	:doc_root => node['gatest']['doc_root'],
	:server_name => node['bsql']['server_name']
	})
action :create
notifies :restart, resources(:service => "nginx")
#action :install
end
package "php5-mysql" do
action :install
end
file "/usr/share/nginx/html/index.php" do
content "<?php
phpinfo();
?>"
mode "0755"
owner "root"
group "root"
end

service "nginx" do
action :restart
end

service "php5-fpm" do
action :restart
end
