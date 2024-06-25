# ==================================
# Terraform & Provider Configuration
# ==================================
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.122.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
  }
}

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
    dns_zone_name = "mydomain-net"
    network       = "infra-net"
    subnet1       = "infra-subnet-b"
    #zone_id2 = "ru-central1-d"  # If HA deployment is required
    #subnet2  = "infra-subnet-d" #
  }

  # PostgreSQL MDB Cluster attributes
  pg_cluster = {
    name      = "zitadel-pg-cluster"
    version   = "16"
    flavor    = "s2.medium"
    disk_size = 50 # Gigabytes
    db_name   = "zitadb"
    db_user   = "dbadmin"
    db_pass   = "My82Sup@paS98"
    db_port   = "6432"
  }

  # Zitadel VM attributes
  zitadel_vm = {
    name         = "zitadel-vm"
    version      = "2.53.2"
    vcpu         = 2
    ram          = 8  # Gigabytes
    disk_size    = 80 # Gigabytes
    image_family = "ubuntu-2204-lts"
    port         = "8443"
    jwt_path     = "/home/myuser/.ssh"
    admin_user   = "admin"
    #admin_pass     = "Fr#dR3n48Ga-Mov"
    admin_key_file = "~/.ssh/id_ed25519.pub"
    cr_name        = "mirror.gcr.io"
    cr_base_image  = "ubuntu:22.04"
  }
}

output "zita_base_url" {
  value = module.zitadel-deploy.zita_base_url
}

output "jwt_key_full_path" {
  value = module.zitadel-deploy.jwt_key_full_path
}
