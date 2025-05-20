#!/bin/bash

# ===================
# users.yml generator
# ===================

USER_PREIFX=$1
USER_COUNT=$2
USER_DOMAIN=$3
USER_LANG=$4

if [[ "$USER_PREFIX" == "" && "$USER_COUNT" == "" ]]; then
  echo "Format: yamlgen.sh <prefix> <count> [domain] [locale]"
  echo -e "For example:\n  ./yamlgen.sh zuser 5\n  ./yamlgen.sh zuser 7 mydom.net en\n"
  exit
fi

if [[ "$USER_DOMAIN" == "" ]]; then
  USER_DOMAIN=mydom.net
fi

if [[ "$USER_LANG" == "" ]]; then
  USER_LANG=en
fi

echo "# ======================"
echo "# Zitadel Users accounts"
echo "# ======================"

for cnt in $(seq 1 $USER_COUNT); do
  usr=$USER_PREIFX$cnt
  eml=$usr@$USER_DOMAIN
  pass=$(($(date +%s%N)/1000000 + ${RANDOM:0:32000}))
  pass=$(echo -n $pass | sha256sum)

  echo $usr:
  echo "  fname: \"$usr\""
  echo "  lname: \"$usr\""
  echo "  lang: \"$USER_LANG\""
  echo "  email: \"$eml\""
  echo "  pass: \"${pass:16:12}\""
done
