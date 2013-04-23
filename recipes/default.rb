require_recipe 'build-essential'

package "wget" do
  action :install
end

execute "ldconfig" do
  user "root"
  action :nothing
end

remote_file "/tmp/freetds-#{node['freetds']['version']}.tar.gz" do
  source "http://mirrors.ibiblio.org/freetds/stable/git/freetds-#{node['freetds']['version']}.tar.gz"
  mode 0644
  action :create_if_missing
end

execute "tar -xzf freetds-#{node['freetds']['version']}.tar.gz" do
  cwd "/tmp"
  user "root"
  creates "/tmp/freetds-#{node['freetds']['version']}"
end

execute "compile freetds" do
  command "./configure --with-openssl=/usr/lib64/openssl && make && make install"
  user "root"
  cwd "/tmp/freetds-#{node['freetds']['version']}"
  creates "/usr/local/lib/libsybdb.so.5"
  not_if do
    File.exists? "/usr/local/lib/libsybdb.so.5"
  end
  notifies :run, resources(:execute => "ldconfig")
end

#template freetds_conf do
#  source "freetds.conf"
#  owner "root"
#  group "root"
#  mode 0644
#end
