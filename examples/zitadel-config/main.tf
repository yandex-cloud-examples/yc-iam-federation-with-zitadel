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
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "~> 1.2.1"
    }
  }
}

# ====================
# Call usersgen module
# ====================

module "usersgen" {
  source = "../../usersgen"

  zitadel_users = "${abspath(path.module)}/users.yml"
}

# ===========================
# Call zitadel-config module
# ===========================
module "zitadel-config" {
  source = "../../zitadel-config"

  system = {
    base_url = var.ZITA_BASE_URL
    jwt_key  = var.JWT_KEY
    zt_token = var.ZT_TOKEN
    yc_token = var.YC_TOKEN
  }

  zitadel_org = {
    org_name = "MyOrg"

    manager_uname = "userman"
    manager_pass  = "Fjdsdo5#7ggjdkjglpD"
    manager_fname = "Users"
    manager_lname = "Manager"
    manager_lang  = "en"
    manager_email = "userman@myorg.org"
    manager_role  = "ORG_USER_MANAGER"

    project_name = "yc-users"

    saml_app_name = "yc-federation-saml"
    yc_org_id     = "bpfljqv8z325tbjhusm"
    yc_fed_name   = "zitadel-federation"
    yc_fed_descr  = "YC and Zitadel integration"
  }
}

output "yc_federation_url" {
  value = module.zitadel-config.yc_federation_url
}
