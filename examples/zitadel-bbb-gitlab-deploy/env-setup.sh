#!/bin/bash

# yc config profile activate prod
export YC_TOKEN=$(yc iam create-token)
export TF_VAR_YC_CLOUD_ID=$(yc config get cloud-id)
export TF_VAR_YC_TOKEN=$YC_TOKEN
