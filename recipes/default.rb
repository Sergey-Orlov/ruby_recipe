
packages = ["libssl-dev","zlib1g-dev","libreadline-dev", "libyaml-dev"]

packages.each do |dev_pkg|
  package dev_pkg
end

remote_file "#{Chef::Config[:file_cache_path]}/ruby-#{node[:ruby][:version]}.tar.gz" do
  # Include a not_if to prevent download on a bootstrap where the ruby version already
  # matches or when running under chef-solo (which deletes the tar file). Checksum will
  # handle things from there.
  not_if "#{node[:ruby][:prefix]}/bin/ruby -v | grep \"#{node[:ruby][:version].gsub('-', '')}\""
  source "http://ftp.ruby-lang.org/pub/ruby/#{node[:ruby][:version][0..2]}/ruby-#{node[:ruby][:version]}.tar.gz"
  checksum node[:ruby][:checksum]
end

bash "install_ruby" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar --no-same-owner -zxf ruby-#{node[:ruby][:version]}.tar.gz
    cd ruby-#{node[:ruby][:version]}
    ./configure
    make
    make install
  EOH
  action :run
end

bash "install_basic_gems" do
  user "root"
  code <<-EOH
    gem install bundler
    gem install foreman
  EOH
  action :run
end

cookbook_file "#{Chef::Config[:file_cache_path]}/Gemfile" do
  source "Gemfile"
  owner "root"
  group "root"
  mode "0644"
end

bash "install_omega_gems" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    bundle install
  EOH
  action :run
end