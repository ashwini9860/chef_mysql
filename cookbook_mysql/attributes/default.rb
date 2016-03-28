default[:bsql][:root_pass] = 'change'
default[:bsql][:user_list] = [{ :username => 'wordpress', :password => 'pass'}]
default[:bsql][:databases] = [{:name => 'wordpress'}]
default[:bsql][:hostname] = 'localhost'
default['bsql']['server_name'] = 'localhost'
default['bsql']['dbname'] = 'wordpress'
default['bsql']['dbusername'] = 'wordpress'
default['bsql']['dbpassword'] = 'pass'

