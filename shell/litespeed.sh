#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-03
# Changed: 修复安装时无法继续问题

useradd -M -s /sbin/nologin www
mkdir -p /home/wwwroot/default

[ ! -s $SRC_DIR/lsws-4.2.8-std-i386-linux.tar.gz ] && wget -c $GET_URI/litespeed/lsws-4.2.8-std-i386-linux.tar.gz -O $SRC_DIR/lsws-4.2.8-std-i386-linux.tar.gz

cd $SRC_DIR
tar zxf lsws-4.2.8-std-i386-linux.tar.gz
cd lsws-4.2.8
rm -f LICENSE

expect -c "
spawn ./install.sh
expect \"license?\" { send \"Yes\r\" }
expect \"Destination\" { send \"\r\" }
expect \"User name\" { send \"$webuser\r\" }
expect \"Password:\" { send \"$webpass\r\" }
expect \"Retype password:\" { send \"$webpass\r\" }
expect \"Email addresses\" { send \"$webemail\r\" }
expect \"User\" { send \"www\r\" }
expect \"Group\" { send \"www\r\" }
expect \"HTTP port\" { send \"$port\r\" }
expect \"Admin HTTP port\" { send \"\r\" }
expect \"Setup up PHP\" { send \"Y\r\" }
expect \"separated list)\" { send \"\r\" }
expect \"Add-on module\" { send \"N\r\" }
expect \"server restarts\" { send \"Y\r\" }
expect \"right now\" { send \"Y\r\" }
"

sed -i 's/<vhRoot>\$SERVER_ROOT\/DEFAULT\/<\/vhRoot>/<vhRoot>\/home\/wwwroot\/default\/<\/vhRoot>/g' /usr/local/lsws/conf/httpd_config.xml
sed -i 's/<configFile>\$VH_ROOT\/conf\/vhconf\.xml<\/configFile>/<configFile>\$SERVER_ROOT\/conf\/default\.xml<\/configFile>/g' /usr/local/lsws/conf/httpd_config.xml

cp $PWD_DIR/conf/vhconf.xml /usr/local/lsws/conf/default.xml
rm -rf /usr/local/lsws/DEFAULT/
mkdir -p /home/wwwlogs/litespeed
chown -R lsadm:lsadm /usr/local/lsws/admin/

service lsws restart