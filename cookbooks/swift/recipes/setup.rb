execute "clean-up" do
  command "rm /home/vagrant/postinstall.sh || true"
end

cookbook_file "/deadsnakes-key" do
  source "deadsnakes-key"
  mode 0644
end

# deadsnakes for py2.6
execute "deadsnakes key" do
  command "sudo apt-key add /deadsnakes-key"
  action :run
end


cookbook_file "/etc/apt/sources.list.d/fkrull-deadsnakes-precise.list" do
  source "etc/apt/sources.list.d/fkrull-deadsnakes-precise.list"
  mode 0644
end

execute "apt-get-update" do
  command "apt-get update && touch /tmp/.apt-get-update"
  if not node['full_reprovision']:
    creates "/tmp/.apt-get-update"
  end
  action :run
end

# packages
required_packages = [
  "curl", "gcc", "memcached", "rsync", "sqlite3", "xfsprogs", "git-core",
  "build-essential", "python-dev", "libffi-dev", "python-setuptools",
  "python-coverage", "python-dev", "python-nose", "python-simplejson",
  "python-xattr", "python-eventlet", "python-greenlet", "python-pastedeploy",
  "python-netifaces", "python-pip", "python-dnspython", "python-mock",
  "python2.6", "python2.6-dev",
]
extra_packages = node['extra_packages']
(required_packages + extra_packages).each do |pkg|
  package pkg do
    action :install
  end
end

# setup environment

execute "update-path" do
  command "echo 'export PATH=/vagrant/bin:$PATH' >> /home/vagrant/.profile"
  not_if "grep /vagrant/bin /home/vagrant/.profile"
  action :run
end

# swift command line env setup
#
{
  "ST_AUTH" => "http://#{node['hostname']}:8080/auth/v1.0",
  "ST_USER" => "test:tester",
  "ST_KEY" => "testing",
}.each do |var, value|
  execute "swift-env-#{var}" do
    command "echo 'export #{var}=#{value}' >> /home/vagrant/.profile"
    not_if "grep #{var} /home/vagrant/.profile"
    action :run
  end
end
