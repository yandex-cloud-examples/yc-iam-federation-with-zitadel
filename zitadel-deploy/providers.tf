# ===================================
# Terraform & Providers Configuration
# ===================================

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.141.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
  required_version = ">= 1.8.0"
}
