#
# Cookbook Name:: bsql
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "update" do
command "apt-get update -y"
action :run
end

package "mysql-server" do
action :install
end

#package "mysql-devel" do
#action :install
#end

service "mysql" do
action [:enable, :start]
end

bash 'mysql_install' do
code <<-EOH
	/usr/bin/mysqladmin drop test -f

	/usr/bin/mysql -e "delete from user where user = ' ';" -D mysql
		
	/usr/bin/mysql -e "delete from user where user 'root' and host = \'#{node[:hostname]}\';" -D mysql
	
	/usr/bin/mysql -e "SET PASSWORD FOR 'root'@'::1' = PASSWORD('#{node[:bsql][:root_pass]}');" -D mysql

	/usr/bin/mysql -e "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('#{node[:bsql][:root_pass]}';" -D mysql

	/usr/bin/mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('#{node[:bsql][:root_pass]}');" -D mysql

	/usr/bin/mysqladmin flush-privileges -p#{node[:bsql][:root_pass]}

EOH
action :run
only_if "/usr/bin/mysql -u root -e 'show databases;'"
end

for db in node[:bsql][:databases] do
bash "add mysql database #{db[:name]}" do
code <<-EOH
	/usr/bin/mysql -e "CREATE DATABASE #{db[:name]};" -u root -p#{node[:bsql][:root_pass]}
EOH
action :run
not_if <<-EOH
/usr/bin/mysql -e "SHOW DATABASES LIKE \'#{db[:name]}\';" -p#{node[:bsql][:root_pass]} | grep -c #{db[:name]}
EOH
end
end

#add user which remotely login
for user in node[:bsql][:user_list] do
log "add mysql user #{user[:username]}" do
message "#{user[:username]}"
level :info
end

bash "add mysql user #{user[:username]}" do
code <<-EOH
 	/usr/bin/mysql -e "CREATE USER \'#{user[:username]}\'@'localhost' IDENTIFIED BY \'#{user[:password]}\';" -D mysql -u root -p#{node[:bsql][:root_pass]}

	/usr/bin/mysql -e "CREATE USER \'#{user[:username]}\'@'%' IDENTIFIED BY \'#{user[:password]}\';" -D mysql -u root -p#{node[:bsql][:root_pass]}
	
	/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON *.* TO \'#{user[:username]}\'@'localhost';" -u root -p#{node[:bsql][:root_pass]}

	/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON *.* TO \'#{user[:username]}\'@'%';" -u root -p#{node[:bsql][:root_pass]}

	/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO \'#{user[:username]}\'@'localhost IDENTIFIED BY \'#{user[:password]}\';" -u root -p#{node[:bsql][:root_pass]}


	/usr/bin/mysqladmin flush-privileges -p#{node[:bsql][:root_pass]}
EOH
action :run
not_if <<-EOH
	/usr/bin/mysql -u root =p#{node[:bsql][:root_pass]} -e "SELECT User FROM user WHERE User = '#{user[:username]}';" -D mysql | grep remote
EOH
end
end

include_recipe "bsql::wordpress"
include_recipe "bsql::nginx"






