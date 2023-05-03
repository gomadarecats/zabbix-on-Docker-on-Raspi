FROM debian:bullseye-slim as zabbix

ARG ZBXPASSWD

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
                   zabbix-server-pgsql \
                   zabbix-frontend-php \
                   php7.4-pgsql \
                   zabbix-nginx-conf \
                   zabbix-sql-scripts \
                   zabbix-agent \
                   postgresql \
                   locales && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /zabbix-release_6.0-5+debian11_all.deb && \
    sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen && \
    locale-gen &&\
    locale-gen ja_JP.UTF-8 && \
    echo 'export LANG=ja_JP.UTF-8' >> ~/.bashrc && \
    source ~/.bashrc

RUN service postgresql start && \
    sudo -u postgres psql -c "create user zabbix" && \
    sudo -u postgres psql -c "alter user zabbix with password '$ZBXPASSWD'" && \
    sudo -u postgres psql -c "create database zabbix" && \
    sudo -u postgres psql -c "alter database zabbix owner to zabbix" && \
    zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | \
    su zabbix -s /bin/bash -c psql zabbix && \
    echo "DBPassword=$ZBXPASSWD" >> /etc/zabbix/zabbix_server.conf && \
    sed -ie s/^#// /etc/zabbix/nginx.conf

COPY --chmod=755 entrypoint.sh /entrypoint.sh

CMD /entrypoint.sh && while : ; do sleep 1; done

EXPOSE 8080
