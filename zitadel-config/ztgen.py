#!/usr/bin/env python3

# Zitadel JWT Doc:  https://zitadel.com/docs/guides/integrate/private-key-jwt
# Prerequsities:    pip3 install requests jwt

from jwt import JWT, jwk_from_pem
import json
import time
import requests
import sys

if len(sys.argv) == 3:
    sa_file_name = sys.argv[1]
    zita_url = sys.argv[2]
else:
    print("args: <path-to-zitadel-sa-key-file> <zitadel-base-url>")
    print("Example: ./ztgen.py ~/zita-key-sa.json https://idp.my.dom:8443")
    exit(1)

# Load json file with Zitadel SA key
with open(sa_file_name) as fd:
    sa = json.load(fd)

signing_key = jwk_from_pem(bytes(sa["key"], 'utf-8'))

payload = {
    'iss': sa["userId"],
    'sub': sa["userId"],
    'aud': zita_url,
    # Issued at time
    'iat': int(time.time()),
    # JWT expiration time (10 minutes maximum)
    'exp': int(time.time()) + 600,
}

# Create JWT
jwt_instance = JWT()
encoded_jwt = jwt_instance.encode(
    payload, signing_key, alg='RS256', optional_headers={"kid": sa["keyId"]})

# Request OAuth token from Zitadel
url = f'{zita_url}/oauth/v2/token'
headers = {'Content-Type': 'application/x-www-form-urlencoded'}
data = {
    'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    'scope': 'openid urn:zitadel:iam:org:project:id:zitadel:aud',
    'assertion': encoded_jwt
}

res = requests.post(url, headers=headers, data=data, timeout=30)
print(res.json()["access_token"])
