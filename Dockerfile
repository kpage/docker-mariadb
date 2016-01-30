FROM alpine:3.3
MAINTAINER Nigel Banks <nigel.g.banks@gmail.com>

ENV MYSQL_ROOT_USER=root \
    MYSQL_ROOT_PASSWORD=

EXPOSE 3306
VOLUME /var/lib/mysql

# Install Dependancies
RUN mkdir /entrypoint && \
    apk --update add mariadb openssl ca-certificates libssh2 curl && \
    curl -L https://github.com/jwilder/dockerize/releases/download/v0.2.0/dockerize-linux-amd64-v0.2.0.tar.gz | \
    tar -xzf - -C /usr/local/bin && \
    apk del openssl ca-certificates libssh2 curl && \
    rm -rf /var/cache/apk/* && \
    rm -fr /root/.cache/* && \
    rm -fr /tmp/* && \
    echo '' > /root/.ash_history

COPY my.cnf.tmpl /entrypoint/my.cnf.tmpl
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld_safe"]
