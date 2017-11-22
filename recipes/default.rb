#
# Cookbook Name:: centos-oracle-prep
# Recipe:: default
#
# Author:: Lonnie VanZandt <lonniev@gmail.com>
# Copyright 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# a variety of utilities and build packages that the Oracle installer will need
%w(
  wget
  less
  unzip
  java-1.8.0-openjdk-devel
  binutils.x86_64
  compat-libcap1.x86_64
	gcc.x86_64
	gcc-c++.x86_64
	glibc.i686
	glibc.x86_64
	glibc-devel.i686
	glibc-devel.x86_64
	ksh
	compat-libstdc++-33
	libaio.i686
	libaio.x86_64
	libaio-devel.i686
	libaio-devel.x86_64
	libgcc.i686
	libgcc.x86_64
	libstdc++.i686
	libstdc++.x86_64
	libstdc++-devel.i686
	libstdc++-devel.x86_64
	libXi.i686
	libXi.x86_64
	libXtst.i686
	libXtst.x86_64
	make.x86_64
	sysstat.x86_64 )
.each do |pkg|
  yum_package pkg.to_s
end

# add the Oracle user
user 'oracle' do
  comment 'the oracle System user'
  manage_home true
  shell '/bin/bash'
  password '$1$JvHNBHi5$Iuq39SXBDq7IIjNUxOqfo0'
  group 'oracle'
end

# add the Oracle groups
%w( oinstall dba )
.each do |grp|
  group grp.to_s do
    action :create
    members 'oracle'
  end
end

# give ~oracle a useful .bash_profile
file "/home/oracle/.bash_profile" do
  owner 'oracle'
  group 'oracle'
  mode '0755'
  content <<~HERE
    # borrowed from https://wiki.centos.org/HowTos/Oracle12onCentos7

    TMPDIR=$TMP; export TMPDIR
    ORACLE_BASE=/home/oracle/app/oracle; export ORACLE_BASE
    ORACLE_HOME=$ORACLE_BASE/product/12.1.0/dbhome_1; export ORACLE_HOME
    ORACLE_SID=orcl; export ORACLE_SID
    PATH=$ORACLE_HOME/bin:$PATH; export PATH
    LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:/usr/lib64; export LD_LIBRARY_PATH
    CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH

    export DISPLAY=:1.0
  HERE
end

# copy over the Oracle images from some accessible remote site
%w( /media /media/oracle )
.each do |dir|
  directory dir.to_s do
    owner 'oracle'
    group 'oracle'
    mode '0777'
    action :create
  end
end

%w( linuxamd64_12102_database_1of2.zip linuxamd64_12102_database_2of2.zip )
.each do |file|
  remote_file "/media/oracle/#{file}" do
    source "https://storage.googleapis.com/windchill/#{file}"
    owner 'oracle'
    group 'oracle'
    mode '0755'
    action :create
  end
end

# now unzip the downloaded files
%w( linuxamd64_12102_database_1of2.zip linuxamd64_12102_database_2of2.zip )
.each do |zip|
  execute "unzip #{zip}" do
    command "unzip -q -o -d /home/oracle /media/oracle/#{zip}"
    user 'oracle'
    group 'oracle'
  end
end
