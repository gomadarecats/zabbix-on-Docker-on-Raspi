FROM debian:bullseye-slim as zabbix

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
                   ca-certificates \
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
                   locales && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /zabbix-release_6.0-5+debian11_all.deb && \
    sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen && \
    locale-gen && \
    locale-gen ja_JP.UTF-8 && \
    echo 'export LANG=ja_JP.UTF-8' >> ~/.bashrc && \
    source ~/.bashrc && \
    sed -ie 's/# DBHost=localhost/DBHost=postgres/' /etc/zabbix/zabbix_server.conf && \
    sed -ie 's/^#//' /etc/zabbix/nginx.conf

COPY --chmod=755 entrypoint.sh /entrypoint.sh

CMD /entrypoint.sh && while : ; do sleep 1; done

EXPOSE 8080
