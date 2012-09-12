require_recipe 'build-essential'

package "wget" do
  action :install
end

execute "ldconfig" do
  user "root"
  action :nothing
end

remote_file "/tmp/#{node['freetds']['version']}" do
  source "ftp://ftp.astron.com/pub/freetds/stable/freetds-#{node['freetds']['version']}.tar.gz"
  mode 0644
  action :create_if_missing
end

execute "tar -xf freetds-#{node['freetds']['version']}.tar.gz" do
  cwd "/tmp"
  user "root"
  creates freetds_dir
end

execute "compile freetds" do
  command "./configure && make && make install"
  user "root"
  cwd "/tmp/freetds-#{node['freetds']['version']}"
  creates "/usr/local/lib/libsybdb.so.5"
  notifies :run, resources(:execute => "ldconfig")
end

template freetds_conf do
  source "freetds.conf"
  owner "root"
  group "root"
  mode 0644
end
