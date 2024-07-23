
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
  initial_password   = local.init_pass

  lifecycle {
    ignore_changes = [initial_password, display_name, phone, email]
  }
}

resource "zitadel_user_grant" "${USER_UNAME}" {
  org_id     = zitadel_org.org.id
  project_id = zitadel_project.project.id
  user_id    = zitadel_human_user.${USER_UNAME}.id
  #role_keys = ["user"]
}

resource "terracurl_request" "${USER_UNAME}" {
  name         = "${USER_UNAME}"
  url          = "$${var.system.base_url}/v2beta/users/$${zitadel_human_user.${USER_UNAME}.id}/password"
  method       = "POST"
  request_body = <<EOF
    {
      "newPassword": { "password": "${USER_PASS}", "changeRequired": false },
      "currentPassword": "$${local.init_pass}"
    }
  EOF
  headers = {
    Authorization = "Bearer $${var.system.zt_token}"
  }
  response_codes = [200]

  depends_on = [zitadel_human_user.${USER_UNAME}]

  lifecycle {
    ignore_changes = [headers, request_body]
  }
}

resource "yandex_organizationmanager_saml_federation_user_account" "${USER_UNAME}" {
  federation_id = yandex_organizationmanager_saml_federation.yc_federation.id
  name_id       = "${USER_UNAME}"
}
