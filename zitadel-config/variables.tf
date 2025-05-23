# ========================
# zitadel-config TF-Module
# ========================

# =============
# System things
# =============
variable "system" {
  description = "System attributes"
  type = object(
    {
      base_url = string # Zitadel VM Base URL
      jwt_key  = string # Full path to Zitadel JWT key file
      zt_token = string # OAuth session token
      yc_token = string # YC IAM Token
    }
  )
}

locals {
  zita_fqdn = split(":", split("//", var.system.base_url)[1])[0]
  zita_port = split(":", var.system.base_url)[2]
}

# ============
# Zitadel Org
# ============
variable "zitadel_org" {
  description = "Zitadel Org attributes"
  type = object(
    {
      org_name      = string # Organization name
      manager_uname = string # Org Manager user name
      manager_pass  = string # manager password
      manager_fname = string # manager First Name
      manager_lname = string # manager Last Name
      manager_lang  = string # manager Default Language
      manager_email = string # manager e-mail
      manager_role  = string # manager Role: https://zitadel.com/docs/guides/manage/console/managers#roles

      project_name = string # Zitadel Users Project name

      saml_app_name = string # Zitadel SAML App (YC Federation integration)
      yc_org_id     = string # Yandex Cloud Organization Id
      yc_fed_name   = string # Yandex Cloud Federation Name
      yc_fed_descr  = string # Yandex Cloud Federation Description
    }
  )
}

# ==================================================
# Zitadel SMTP config. Optional. Disabled by default
# ==================================================
variable "zitadel_smtp" {
  description = "Zitadel Instance SMTP configuration"
  type = object(
    {
      enabled        = bool # SMTP enabled / disabled
      sender_address = string
      reply_address  = string
      sender_name    = string
      tls            = bool
      host           = string
      user           = string
      password       = string
    }
  )

  default = {
    enabled        = false # disabled
    sender_address = null
    reply_address  = null
    sender_name    = null
    tls            = false
    host           = null
    user           = null
    password       = null
  }
}

# ===============
# Zitadel Outputs
# ===============
output "yc_federation_url" {
  value = "https://console.yandex.cloud/federations/${yandex_organizationmanager_saml_federation.yc_federation.id}"
}
