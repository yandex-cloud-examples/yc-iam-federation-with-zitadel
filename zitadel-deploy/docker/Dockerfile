ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG ZT_VER

RUN \
  # Install System Packages
  apt-get update && apt-get -y upgrade && \
  apt-get -y install curl jq && \
  # Copy YC Managed Database CA certificates (for future use)
  curl -sL https://storage.yandexcloud.net/cloud-certs/CA.pem -o /usr/local/share/ca-certificates/yc-ca && \
  update-ca-certificates && \
  # Install yq tool
  curl -sLO https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
  mv yq_linux_amd64 /usr/local/bin/yq && \
  chmod a+x /usr/local/bin/yq && \
  # Install target version of Zitadel
  curl -sLO https://github.com/zitadel/zitadel/releases/download/v$ZT_VER/zitadel-linux-amd64.tar.gz && \
  tar -zxf zitadel-linux-amd64.tar.gz && \
  mkdir -p /opt/zitadel && \
  mv zitadel-linux-amd64/zitadel /opt/zitadel/ && \
  # Clean Up
  rm -rf zitadel-linux-amd64/ zitadel-linux-amd64.tar.gz install.sh && \
  apt-get -y remove $DEV_PACKAGES && \
  apt-get -y autoremove && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY ./files/ ./

ENV PATH "$PATH:/opt/yc/bin"

ENV ZITADEL_MASTERKEY="32-random-chars-string"
ENV ZITADEL_LOG_LEVEL=info
ENV ZITADEL_LOG_FORMATTER_FORMAT=text
ENV ZITADEL_PORT=8443
ENV ZITADEL_EXTERNALPORT=8443
ENV ZITADEL_EXTERNALDOMAIN=idp.mydomain.net

ENV ZITADEL_EXTERNALSECURE=true
ENV ZITADEL_TLS_ENABLED=true
ENV ZITADEL_TLS_KEY="base64 encoded content of LE certificate"
ENV ZITADEL_TLS_CERT="base64 encoded content of LE certificate"

ENV ZITADEL_DATABASE_POSTGRES_HOST=pg-hostname.mydomain.net
ENV ZITADEL_DATABASE_POSTGRES_PORT=6432
ENV ZITADEL_DATABASE_POSTGRES_DATABASE=dbname
ENV ZITADEL_DATABASE_POSTGRES_MAXOPENCONNS=10
ENV ZITADEL_DATABASE_POSTGRES_USER_USERNAME=dbadmin
ENV ZITADEL_DATABASE_POSTGRES_USER_PASSWORD=dbpasswd
ENV ZITADEL_DATABASE_POSTGRES_USER_SSL_MODE=disable
ENV ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME=dbadmin
ENV ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD=dbpasswd
ENV ZITADEL_DATABASE_POSTGRES_ADMIN_SSL_MODE=disable

ENTRYPOINT ["/docker-entrypoint.sh"]
