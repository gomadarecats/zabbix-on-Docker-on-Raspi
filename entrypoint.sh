#!/bin/bash
service postgresql start
sudo -u postgres psql -c "create user zabbix"
sudo -u postgres psql -c "alter user zabbix with password '${ZBXPASS}'"
sudo -u postgres psql -c "create database zabbix"
sudo -u postgres psql -c "alter database zabbix owner to zabbix"
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz |
su zabbix -s /bin/bash -c psql zabbix
echo "DBPassword=${ZBXPASS}" >> /etc/zabbix/zabbix_server.conf
sed -ie s/^#// /etc/zabbix/nginx.conf
service zabbix-server start
service zabbix-agent start
service php7.4-fpm start
service nginx start
