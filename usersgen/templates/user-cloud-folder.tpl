
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

resource "yandex_resourcemanager_cloud" "${USER_UNAME}" {
  organization_id = var.yc_org_id
  name            = "${USER_UNAME}"
}

resource "yandex_billing_cloud_binding" "${USER_UNAME}" {
  billing_account_id = var.YC_BA_ID
  cloud_id           = yandex_resourcemanager_cloud.${USER_UNAME}.id

  depends_on = [yandex_resourcemanager_cloud.${USER_UNAME}]
}

resource "yandex_resourcemanager_folder" "${USER_UNAME}" {
  cloud_id = yandex_resourcemanager_cloud.${USER_UNAME}.id
  name     = "default"

  depends_on = [yandex_billing_cloud_binding.${USER_UNAME}]
}

resource "yandex_resourcemanager_cloud_iam_member" "${USER_UNAME}_cloud_binding" {
  cloud_id = yandex_resourcemanager_cloud.${USER_UNAME}.id
  role     = "editor"
  member   = "federatedUser:$${yandex_organizationmanager_saml_federation_user_account.${USER_UNAME}.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "${USER_UNAME}_folder_binding" {
  folder_id = yandex_resourcemanager_folder.${USER_UNAME}.id
  role      = "admin"
  member    = "federatedUser:$${yandex_organizationmanager_saml_federation_user_account.${USER_UNAME}.id}"
}