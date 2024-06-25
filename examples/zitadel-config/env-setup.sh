#!/bin/bash

# yc config profile activate prod
export YC_TOKEN=$(yc iam create-token)
export TF_VAR_YC_CLOUD_ID=$(yc config get cloud-id)
export TF_VAR_YC_TOKEN=$YC_TOKEN

export SRC_PATH="../zitadel-deploy"
export TF_VAR_ZITA_BASE_URL=$(terraform -chdir=$SRC_PATH output -raw zita_base_url)
export TF_VAR_JWT_KEY=$(terraform -chdir=$SRC_PATH output -raw jwt_key_full_path)

export TF_VAR_ZT_TOKEN=$(../../zitadel-config/ztgen.py $TF_VAR_JWT_KEY $TF_VAR_ZITA_BASE_URL)
