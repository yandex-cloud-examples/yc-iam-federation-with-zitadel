#cloud-config

datasource:
  Ec2:
    strict_id: false
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
