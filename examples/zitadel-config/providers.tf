# ==================================
# Terraform & Provider Configuration
# ==================================

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.141.0"
    }
    zitadel = {
      source  = "zitadel/zitadel"
      version = "~> 2.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "~> 1.2.2"
    }
  }
  /*
  # =========================
  # S3 remote TF state config
  # =========================
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    region = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
  */
}
