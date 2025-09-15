# ====================
# Zitadel Organization
# ====================

// Organization
resource "zitadel_org" "org" {
  name = var.zitadel_org.org_name
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

resource "zitadel_password_complexity_policy" "default" {
  org_id        = zitadel_org.org.id
  min_length    = "8"
  has_uppercase = true
  has_lowercase = true
  has_number    = true
  has_symbol    = false
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
