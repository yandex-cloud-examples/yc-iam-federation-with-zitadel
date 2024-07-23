# ===========================
# Call zitadel-deploy module
# ===========================
module "zitadel-deploy" {
  source = "../../zitadel-deploy"

  # YC Infra and Network attributes
  yc_infra = {
    cloud_id      = var.YC_CLOUD_ID
    folder_name   = "infra"
    zone_id       = "ru-central1-b"
    dns_zone_name = "yclabs-net" # "mydomain-net"
    network       = "infra-net"
    subnet1       = "infra-subnet-b"
  }

  # PostgreSQL MDB Cluster attributes
  pg_cluster = {
    name      = "zitadel-pg-cluster"
    version   = "16"
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
    cr_base_image   = "ubuntu:22.04"
    zitadel_source  = "https://github.com/zitadel/zitadel/releases/download"
    zitadel_version = "2.55.0"
    zitadel_file    = "zitadel-linux-amd64.tar.gz"
    yq_source       = "https://github.com/mikefarah/yq/releases/download"
    yq_version      = "4.44.2"
    yq_file         = "yq_linux_amd64"
  }

  # Zitadel VM attributes
  zitadel_vm = {
    name           = "zita1" # "zitadel-vm"
    vcpu           = 2
    ram            = 8  # Gigabytes
    disk_size      = 80 # Gigabytes
    image_family   = "ubuntu-2204-lts"
    port           = "8443"
    jwt_path       = "~/.ssh"
    admin_user     = "admin"
    admin_key_file = "~/.ssh/id_ed25519" # SSH Private key path
  }
}

output "zitadel_base_url" {
  value = module.zitadel-deploy.zitadel_base_url
}

output "jwt_key_full_path" {
  value = module.zitadel-deploy.jwt_key_full_path
}

# ======================
# Call bbb-deploy module
# ======================
module "bbb-deploy" {
  source = "../../bbb-deploy"

  # BBB attributes
  bbb_vm = {
    name         = "bbb1"
    pub_name     = "b"
    version      = "2.7.4"
    vcpu         = 12  # 24
    ram          = 24  # 32
    disk_size    = 300 # 500
    image_family = "ubuntu-2004-lts"
    port         = "443"
    cert_priv    = "bbb-cert-priv-key.pem"
    cert_pub     = "bbb-cert-pub-chain.pem"

    # Import from the module zitadel-deploy
    infra_zone_id       = "${module.zitadel-deploy.infra_zone_id}"
    infra_folder_id     = "${module.zitadel-deploy.infra_folder_id}"
    infra_dns_zone_name = "${module.zitadel-deploy.infra_dns_zone_name}"
    admin_user          = "${module.zitadel-deploy.admin_user}"
    admin_key_file      = "${module.zitadel-deploy.admin_key_file}"
    infra_net_id        = "${module.zitadel-deploy.infra_net_id}"
    infra_subnet1_id    = "${module.zitadel-deploy.infra_subnet1_id}"
  }
}
