# ==================================
# Terraform & Provider Configuration
# ==================================

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.122.0"
    }
    zitadel = {
      source  = "zitadel/zitadel"
      version = "~> 1.3.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "~> 1.2.1"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 17.1.0"
    }
  }
  required_version = ">= 1.8.0"
}

provider "zitadel" {
  domain           = local.zita_fqdn
  port             = local.zita_port
  insecure         = "false"
  jwt_profile_file = pathexpand(var.system.jwt_key)
}
