FROM debian:bullseye-slim as build

RUN apt update && \
    apt upgrade -y && \
    apt install -y wget && \
    apt clean &&  \
    rm -rf /var/lib/apt/lists/* && \
    wget https://repo.zabbix.com/zabbix/6.0/raspbian/pool/main/z/zabbix-release/zabbix-release_6.0-5%2Bdebian11_all.deb && \
    echo '#!/bin/bash\n \
    service postgresql start &\n \
    service zabbix-server start &\n \
    service zabbix-agent start &\n \
    service php7.4-fpm start &\n \
    service nginx start' \
    > exec.sh && \
    chmod 755 exec.sh

#----------

FROM debian:bullseye-slim as zabbix

RUN apt update && \
    apt upgrade -y && \
    apt install -y ca-certificates

COPY --from=build /zabbix-release_6.0-5+debian11_all.deb /
COPY --from=build /exec.sh /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
    sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen && \
    locale-gen &&\
    locale-gen ja_JP.UTF-8 && \
    echo 'export LANG=ja_JP.UTF-8' >> ~/.bashrc && \
    source ~/.bashrc

VOLUME /var/lib/postgresql/data

USER postgres

RUN service postgresql start && \
    psql -c "create user zabbix" && \
    psql -c "alter user zabbix with password '<PASSWORD>'" && \
    psql -c "create database zabbix" && \
    psql -c "alter database zabbix owner to zabbix"

USER root

RUN service postgresql start && \
    zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | \
    su zabbix -s /bin/bash -c 'psql zabbix'

RUN echo 'DBPassword=<PASSWORD>' >> /etc/zabbix/zabbix_server.conf && \
    sed -ie 's/^#//' /etc/zabbix/nginx.conf

CMD /exec.sh && while : ; do sleep 1; done

EXPOSE 8080
