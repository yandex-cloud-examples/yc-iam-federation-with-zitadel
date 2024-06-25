# ===================================
# Terraform & Providers Configuration
# ===================================

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
