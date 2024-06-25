#cloud-config

datasource:
  Ec2:
    strict_id: false
  pg_db: ${pg_db}
  secrets:
    zita_masterkey: ${zita_masterkey}
    pg_host: ${pg_host}
    pg_user: ${pg_user}
    le_cert_id: ${cert_id}
ssh_pwauth: no
users:
  - name: ${ADMIN_NAME}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh-authorized-keys:
      - "${ADMIN_SSH_KEY}"
packages:
  - docker.io
  - jq
runcmd:
  - sleep 1
  - sudo -i
  - usermod -aG docker ${ADMIN_NAME}
