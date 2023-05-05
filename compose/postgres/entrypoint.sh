#!/bin/bash
service postgresql start
sudo -u postgres psql -c "alter user zabbix with password '${ZBXPASSWD}'"
service zabbix-agent start
