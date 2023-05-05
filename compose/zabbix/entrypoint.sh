#!/bin/bash
echo "DBPassword=${ZBXPASSWD}" >> /etc/zabbix/zabbix_server.conf
sed -ie s/^#// /etc/zabbix/nginx.conf
service zabbix-server start
service zabbix-agent start
service php7.4-fpm start
service nginx start
