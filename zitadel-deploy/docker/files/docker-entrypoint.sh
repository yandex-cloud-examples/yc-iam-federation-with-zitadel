#!/bin/bash

# Get FQDN
export ZITADEL_EXTERNALDOMAIN=$(curl -sf -H Metadata-Flavor:Google 169.254.169.254/computeMetadata/v1/instance/description)

# Get IAM-Token
export YC_TOKEN=$(curl -sf -H Metadata-Flavor:Google 169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token | jq -r .access_token)

# Get LE Certificate from Certificate Manager
export cert_id=$(curl -sf -H Metadata-Flavor:Google 169.254.169.254/latest/user-data | yq '.datasource.secrets.le_cert_id')

read ZITADEL_TLS_KEY <<<$(curl -sf -H "Authorization: Bearer $YC_TOKEN" https://data.certificate-manager.api.cloud.yandex.net/certificate-manager/v1/certificates/$cert_id:getContent | jq -r '"\(.privateKey|@base64)"')

read ZITADEL_TLS_CERT <<<$(curl -sf -H "Authorization: Bearer $YC_TOKEN" https://data.certificate-manager.api.cloud.yandex.net/certificate-manager/v1/certificates/$cert_id:getContent | jq -r '"\(.certificateChain[])"'|base64 -w0)

# Get Zitadel Masterkey
export masterkey_id=$(curl -sf -H Metadata-Flavor:Google 169.254.169.254/latest/user-data | yq '.datasource.secrets.zita_masterkey')
export ZITADEL_MASTERKEY=$(curl -sf -H "Authorization: Bearer $YC_TOKEN" https://payload.lockbox.api.cloud.yandex.net/lockbox/v1/secrets/$masterkey_id/payload | jq -r .entries[0].textValue)

# Get PostgreSQL hostname
export pg_host_id=$(curl -sf -H Metadata-Flavor:Google 169.254.169.254/latest/user-data | yq '.datasource.secrets.pg_host')
export ZITADEL_DATABASE_POSTGRES_HOST=$(curl -sf -H "Authorization: Bearer $YC_TOKEN" https://payload.lockbox.api.cloud.yandex.net/lockbox/v1/secrets/$pg_host_id/payload | jq -r .entries[0].textValue)

# Get PostgreSQL database name
export ZITADEL_DATABASE_POSTGRES_DATABASE=$(curl -sf -H Metadata-Flavor:Google 169.254.169.254/latest/user-data | yq '.datasource.pg_db')

# Get PostgreSQL username & password
export pg_user_id=$(curl -sf -H Metadata-Flavor:Google 169.254.169.254/latest/user-data | yq '.datasource.secrets.pg_user')
export ZITADEL_DATABASE_POSTGRES_USER_USERNAME=$(curl -sf -H "Authorization: Bearer $YC_TOKEN" https://payload.lockbox.api.cloud.yandex.net/lockbox/v1/secrets/$pg_user_id/payload | jq -r .entries[0].key)
export ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME=$ZITADEL_DATABASE_POSTGRES_USER_USERNAME
export ZITADEL_DATABASE_POSTGRES_USER_PASSWORD=$(curl -sf -H "Authorization: Bearer $YC_TOKEN" https://payload.lockbox.api.cloud.yandex.net/lockbox/v1/secrets/$pg_user_id/payload | jq -r .entries[0].textValue)
export ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD=$ZITADEL_DATABASE_POSTGRES_USER_PASSWORD

# Start Zitadel
exec /opt/zitadel/zitadel start-from-setup --masterkeyFromEnv
