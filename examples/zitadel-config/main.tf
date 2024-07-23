# ====================
# Call usersgen module
# ====================

module "usersgen" {
  source     = "../../usersgen"
  users_list = "${abspath(path.module)}/users.yml"

  # User only
  template_file = "user.tpl"

  # User + Cloud + Folder
  # template_file = "user-cloud-folder.tpl"

  # User + Cloud + Folder + VPC + Egress gateway + Route table
  # template_file = "user-cloud-folder-vpc-gw-rt.tpl"

  # User + Gitlab
  # template_file = "user-gitlab.tpl"

  # User + Gitlab + Cloud + Folder
  # template_file = "user-gitlab-cloud-folder.tpl"
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

  # STMP is disabled by default, configure enabled = true if required
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
