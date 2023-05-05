FROM debian:bullseye-slim as postgres

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
                   ca-certificates \
                   sudo \
                   wget && \
    wget https://repo.zabbix.com/zabbix/6.0/raspbian/pool/main/z/zabbix-release/zabbix-release_6.0-5%2Bdebian11_all.deb

RUN dpkg -i zabbix-release_6.0-5+debian11_all.deb && \
    apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
                   zabbix-sql-scripts \
                   zabbix-agent \
                   postgresql && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /zabbix-release_6.0-5+debian11_all.deb

RUN sed -ie "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/13/main/postgresql.conf && \
    sed -ie '/# IPv4 local connections:/s/$/\nhost\tall\t\tall\t\t172.16.0.0\/12\t\tmd5/' /etc/postgresql/13/main/pg_hba.conf && \
    service postgresql start && \
    sudo -u postgres psql -c "create user zabbix" && \
    sudo -u postgres psql -c "create database zabbix" && \
    sudo -u postgres psql -c "alter database zabbix owner to zabbix" && \
    zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | \
    su zabbix -s /bin/bash -c psql zabbix && \
    sed -ie 's/Server=127.0.0.1/Server=zabbix/' /etc/zabbix/zabbix_agentd.conf

COPY --chmod=755 entrypoint.sh /entrypoint.sh

CMD /entrypoint.sh && while : ; do sleep 1; done

EXPOSE 5432
