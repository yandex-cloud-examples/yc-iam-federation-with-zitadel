#!/bin/bash

NAME=$1
PASS=$2

if [[ "$NAME" == "" || "$PASS" == "" ]]; then
  echo "Zitadel Admin account creation tool"
  echo "Format: zadmin-create.sh <AdminName> <AdminPassword>"
  echo "  <AdminPassword> should be more than 8 chars length, consider regular and Capital chars, digits and special chars."
  echo -e "\nFor example:\n  ./zadmin-create.sh zadmin \"my%su318Per@Pass\"\n"
  exit
fi

if [[ "$TF_VAR_ZITA_BASE_URL" == "" || "$TF_VAR_ZT_TOKEN" == "" ]]; then
  echo "Please init environment with \"source examples/zitadel-config/env-setup.sh\"!"
  exit
fi

echo "Create Admin user account"
export USER_ID=$(curl -s -X POST $TF_VAR_ZITA_BASE_URL/v2/users/human -H "Authorization: Bearer $TF_VAR_ZT_TOKEN" -d "{
  \"username\": \"$NAME\",
  \"profile\": {
    \"givenName\": \"zAdmin\",
    \"familyName\": \"zAdmin\"},
    \"email\": {
      \"email\": \"$NAME@myorg.org\",
      \"isVerified\": true
    }, 
    \"password\": {
      \"password\": \"$PASS\",
      \"changeRequired\": false
    }
  }" | jq -r .userId)

echo "Grant IAM_OWNER role to Admin"
curl -s -X POST $TF_VAR_ZITA_BASE_URL/admin/v1/members -H "Authorization: Bearer $TF_VAR_ZT_TOKEN" -d "{ \"userId\": \"$USER_ID\", \"roles\": [ \"IAM_OWNER\" ]}"
