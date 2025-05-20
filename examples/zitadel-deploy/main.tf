# ===========================
# Call zitadel-deploy module
# ===========================
module "zitadel-deploy" {
  source = "../../zitadel-deploy"

  # YC Infra and Network attributes
  yc_infra = {
    project       = "myproject"
    cloud_id      = var.YC_CLOUD_ID
    folder_name   = "infra"
    zone_id       = "ru-central1-d"
    dns_zone_name = "mydomain-net"
    network       = "infra-net"
    subnet1       = "infra-subnet-d"
  }

  # PostgreSQL MDB Cluster attributes
  pg_cluster = {
    name      = "myproject"
    version   = "17"
    flavor    = "s2.medium"
    disk_size = 50 # Gigabytes
    db_name   = "zitadel-db"
    db_user   = "dbadmin"
    db_pass   = "My82Sup@paS98"
    db_port   = "6432"
  }

  # Zitadel Docker container attributes
  zitadel_cntr = {
    name            = "zitadel"
    cr_name         = "mirror.gcr.io"
    cr_base_image   = "ubuntu:24.04"
    zitadel_source  = "https://github.com/zitadel/zitadel/releases/download"
    zitadel_version = "3.0.4"
    zitadel_file    = "zitadel-linux-amd64.tar.gz"
    yq_source       = "https://github.com/mikefarah/yq/releases/download"
    yq_version      = "4.44.2"
    yq_file         = "yq_linux_amd64"
  }

  # Zitadel VM attributes
  zitadel_vm = {
    name            = "zitadel-vm"
    public_dns_name = "idp" # idp.mydomain.net
    vcpu            = 2
    ram             = 8  # Gigabytes
    disk_size       = 80 # Gigabytes
    image_family    = "ubuntu-2404-lts"
    port            = "8443"
    jwt_path        = "~/.ssh"
    admin_user      = "labadm"
    admin_key_file  = "~/.ssh/id_ed25519" # SSH Private key path
  }
}

output "zitadel_base_url" {
  value = module.zitadel-deploy.zitadel_base_url
}

output "jwt_key_full_path" {
  value = module.zitadel-deploy.jwt_key_full_path
}
