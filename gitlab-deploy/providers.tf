# ===================================
# Terraform & Providers Configuration
# ===================================

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
}
