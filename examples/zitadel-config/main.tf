# ====================
# Call usersgen module
# ====================

module "usersgen" {
  source     = "../../usersgen"
  users_list = "${abspath(path.module)}/users.yml"

  template_file = "user.tpl"
  template_data = "{yc_org_id: bpXXXXXXXXXXXXXXXXXXX yc_ba_id: dnXXXXXXXXXXXXXXXXXXX"
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
    org_name  = "sws"
    yc_org_id = "bpXXXXXXXXXXXXXXXXXXX
  }

  # SMTP is disabled by default, configure enabled = true if required
  zitadel_smtp = {
    enabled        = false
    sender_address = "info@my-domain.net"
    reply_address  = "noreply@my-domain.net"
    sender_name    = "no-reply"
    tls            = true
    host           = "smtp.my-domain.net:25"
    user           = "smtp-sender"
    password       = "sm27ComplEx38passWord"
  }
}

output "yc_federation_url" {
  value = module.zitadel-config.yc_federation_url
}
