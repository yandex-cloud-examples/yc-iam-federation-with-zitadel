# ====================
# Zitadel Organization
# ====================

// Organization
resource "zitadel_org" "org" {
  name       = var.zitadel_org.org_name
  is_default = true
}

locals {
  init_pass = "VxP67@t4d-l3mI3%d285cM"
}

// Manager account for users management
resource "zitadel_human_user" "manager" {
  org_id             = zitadel_org.org.id
  user_name          = var.zitadel_org.manager_uname
  first_name         = var.zitadel_org.manager_fname
  last_name          = var.zitadel_org.manager_lname
  display_name       = "${var.zitadel_org.manager_fname} ${var.zitadel_org.manager_lname}"
  preferred_language = var.zitadel_org.manager_lang
  email              = var.zitadel_org.manager_email
  is_email_verified  = true
  initial_password   = local.init_pass

  lifecycle {
    ignore_changes = [initial_password, email]
  }
}

# https://zitadel.com/docs/apis/resources/user_service/user-service-set-password
resource "terracurl_request" "manager" {
  name         = "admin"
  url          = "${var.system.base_url}/v2beta/users/${zitadel_human_user.manager.id}/password"
  method       = "POST"
  request_body = <<EOF
    {
      "newPassword": { "password": "${var.zitadel_org.manager_pass}", "changeRequired": false },
      "currentPassword": "${local.init_pass}"
    }
  EOF
  headers = {
    Authorization = "Bearer ${var.system.zt_token}"
  }
  response_codes = [200]

  depends_on = [zitadel_human_user.manager]

  lifecycle {
    ignore_changes = [headers, request_body]
  }
}

// Manager's role in organizaion
resource "zitadel_org_member" "manager_org_role" {
  org_id  = zitadel_org.org.id
  user_id = zitadel_human_user.manager.id
  roles   = ["${var.zitadel_org.manager_role}"]
}

# =====================
# Organization Policies
# =====================

resource "zitadel_login_policy" "default" {
  org_id                        = zitadel_org.org.id
  user_login                    = true
  allow_register                = false
  allow_external_idp            = false
  force_mfa                     = false
  force_mfa_local_only          = false
  passwordless_type             = "PASSWORDLESS_TYPE_NOT_ALLOWED"
  hide_password_reset           = "true"
  password_check_lifetime       = "240h0m0s"
  external_login_check_lifetime = "240h0m0s"
  mfa_init_skip_lifetime        = "0s" # Disable 2FA at all!
  second_factor_check_lifetime  = "18h0m0s"
  multi_factor_check_lifetime   = "12h0m0s"
  ignore_unknown_usernames      = false
  default_redirect_uri          = ""
  allow_domain_discovery        = true
  disable_login_with_email      = true
  disable_login_with_phone      = true
}

resource "zitadel_domain_policy" "default" {
  org_id                                      = zitadel_org.org.id
  user_login_must_be_domain                   = false
  validate_org_domains                        = false
  smtp_sender_address_matches_instance_domain = false
}

resource "zitadel_notification_policy" "default" {
  org_id          = zitadel_org.org.id
  password_change = false
}
