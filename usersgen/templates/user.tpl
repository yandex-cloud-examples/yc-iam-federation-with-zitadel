
# =============
# ${USER_UNAME}
# =============

resource "zitadel_human_user" "${USER_UNAME}" {
  org_id             = zitadel_org.org.id
  user_name          = "${USER_UNAME}"
  first_name         = "${USER_FNAME}"
  last_name          = "${USER_LNAME}"
  display_name       = "${USER_UNAME}"
  preferred_language = "${USER_LANG}"
  email              = "${USER_EMAIL}"
  is_email_verified  = true
  initial_password   = "${USER_PASS}"
  initial_skip_password_change = true

  lifecycle {
    ignore_changes = [initial_password, display_name, phone, email]
  }
}

resource "zitadel_user_grant" "${USER_UNAME}" {
  org_id     = zitadel_org.org.id
  project_id = zitadel_project.project.id
  user_id    = zitadel_human_user.${USER_UNAME}.id
}

resource "yandex_organizationmanager_saml_federation_user_account" "${USER_UNAME}" {
  federation_id = yandex_organizationmanager_saml_federation.yc_federation.id
  name_id       = "${USER_UNAME}"
}
