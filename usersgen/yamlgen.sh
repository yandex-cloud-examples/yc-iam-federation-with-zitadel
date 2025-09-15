#!/bin/bash

# ===================
# users.yml generator
# ===================

USER_PREFIX=$1
USER_COUNT=$2
USER_DOMAIN=$3
USER_LANG=$4

if [[ "$USER_PREFIX" == "" || "$USER_COUNT" == "" || ! "$USER_PREFIX" =~ ^[a-zA-Z] || ! "$USER_COUNT" =~ ^[0-9]+$ ]]; then
  echo "Format: yamlgen.sh <prefix> <count> [domain] [locale]"
  echo -e "For example:\n  ./yamlgen.sh zuser 5\n  ./yamlgen.sh zuser 7 mydom.net en\n"
  exit
fi

if [[ "$USER_DOMAIN" == "" ]]; then
  USER_DOMAIN=org.dom
fi

if [[ "$USER_LANG" == "" ]]; then
  USER_LANG=en
fi

echo "# ======================"
echo "# Zitadel Users accounts"
echo "# ======================"

for cnt in $(seq 1 $USER_COUNT); do
  usr=$USER_PREFIX$cnt
  eml=$usr@$USER_DOMAIN

  pass=$(openssl rand -base64 12)
  if [[ ! "$pass" =~ [0-9] ]]; then :
    pass=${RANDOM:0:1}$pass
  fi

  echo $usr:
  echo "  fname: \"$usr\""
  echo "  lname: \"$usr\""
  echo "  lang: \"$USER_LANG\""
  echo "  email: \"$eml\""
  echo "  pass: \"${pass}\""
done
