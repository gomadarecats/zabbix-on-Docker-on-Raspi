#!/bin/bash
service postgresql start
service zabbix-server start
service zabbix-agent start
service php7.4-fpm start
service nginx start
