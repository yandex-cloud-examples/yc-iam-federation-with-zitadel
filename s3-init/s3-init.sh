#!/bin/bash

# ===============================
# Init S3 remote TF state storage 
# ===============================

check_input_params () {

  FOLDER_ID=$1
  BUCKET=$2

  printf "\n== Check input parameters ==\n"
  echo "Check that folder-id is exists ..."
  if ! yc resource-manager folder get $FOLDER_ID > /dev/null ; then
    exit
  else
    cloud_id=$(yc resource-manager folder get --id=$FOLDER_ID --format=json | jq -r .cloud_id)
  fi

  echo "Check that S3 bucket at the folder is exists ..."
  if yc storage bucket get --name=$BUCKET --folder-id=$FOLDER_ID 1>/dev/null 2>/dev/null ; then
    folder_id=$(yc storage bucket get --name=$BUCKET --format=json | jq -r .folder_id)
    if [[ "$folder_id" == "$FOLDER_ID" ]] ; then
      echo "ERROR: S3 bucket \"$BUCKET\" already exists at the specified folder"
      exit
    else
      echo "ERROR: S3 Bucket \"$BUCKET\" already exists at the folder $folder_id"
      exit
    fi
  else :
  # do nothing
  fi

  echo "Check that Lockbox Secret at the folder is exists ..."
  if yc lockbox secret get --name=$BUCKET --folder-id=$FOLDER_ID 1>/dev/null 2>/dev/null  ; then
    exit
  else :
  # do nothing
  fi

  return 0
}


# ========
# Main ()
# ========
if [ "$#" != "2" ]; then
  printf "Init S3 remote TF state storage\n" 
  printf "$0 <folder-id> <bucket-name>\n"
  printf "For example:\n$0 b1g22jx2133dpa3yvxc3 my-tf-state-storage\n"
  exit

else

  FOLDER_ID=$1
  BUCKET=$2
  SA_NAME=$BUCKET-sa

  check_input_params $FOLDER_ID $BUCKET $SECRET
  echo "Validations has been completed!"

  printf "\n== Create Service Account (SA) ==\n"
  SA_ID=$(yc iam service-account create --name="$SA_NAME" --folder-id=$FOLDER_ID --description="Hold the static key of TF remote storage" --format=json | jq -r .id)

  printf "\n== Grant roles to the SA ==\n"
  yc resource-manager folder add-access-binding --id=$FOLDER_ID --role="storage.uploader" --subject="serviceAccount:$SA_ID" 1>/dev/null
  
  printf "\n== Create Static key for the SA ==\n"
  PARAMS=($(yc iam access-key create --service-account-id=$SA_ID --description="Static key for S3 access" --format=json | jq -r '.access_key.key_id, .secret'))
  S3_KEY=${PARAMS[0]}
  S3_SECRET=${PARAMS[1]}

  printf "\n== Create Lockbox secret with S3 static key ==\n"
  yc lockbox secret create --name=$BUCKET --folder-id=$FOLDER_ID --payload="[{'key': '$S3_KEY', 'text_value': '$S3_SECRET'}]" > /dev/null

  printf "\n== Create S3 bucket for Remote TF state ==\n"
  yc storage bucket create --name=$BUCKET --folder-id=$FOLDER_ID > /dev/null

  echo "=== 1. Add lines below to your env-setup.sh ==="
  echo "SEC_LIST=(\$(yc lockbox payload get --name=$BUCKET --format=json | jq -r '.entries[0] | .key, .text_value'))"
  echo "export AWS_ACCESS_KEY_ID=\${SEC_LIST[0]}"
  echo "export AWS_SECRET_ACCESS_KEY=\${SEC_LIST[1]}"
  echo "============"
  echo ""
  echo "=== 2. Initialize Terraform S3 backend as following: ==="
  echo "terraform init -backend-config=\"bucket=$BUCKET\" -backend-config=\"key=zitadel-deploy.tfstate\""
fi
  exit
