default[:bsql][:root_pass] = 'change'
default[:bsql][:user_list] = [{ :username => 'wordpress', :password => 'pass'}]
default[:bsql][:databases] = [{:name => 'wordpress'}]
default[:bsql][:hostname] = 'localhost'

