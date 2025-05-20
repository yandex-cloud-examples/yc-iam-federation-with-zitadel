#!/bin/bash

# yc config profile activate prod
export YC_TOKEN=$(yc iam create-token)
export TF_VAR_YC_CLOUD_ID=$(yc config get cloud-id)
export TF_VAR_YC_TOKEN=$YC_TOKEN

echo "Configure TF_VAR_ZITA_BASE_URL & TF_VAR_JWT_KEY variables with zitadel-deploy outputs."
export TF_VAR_ZITA_BASE_URL="https://idp.mydom.net:8443"
export TF_VAR_JWT_KEY="~/.ssh/zitadel-sa.json"

export TF_VAR_ZT_TOKEN=$(../../zitadel-config/ztgen.py $TF_VAR_JWT_KEY $TF_VAR_ZITA_BASE_URL)
