
# ===========================
# BBB configuration resources
# ===========================

resource "zitadel_application_oidc" "bbb_oidc" {
  org_id                      = zitadel_org.org.id
  project_id                  = zitadel_project.project.id
  name                        = "bbb-greenlight-oidc"
  redirect_uris               = ["${BBB_URL}/auth/openid_connect/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris   = ["${BBB_URL}"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  version                     = "OIDC_VERSION_1_0"
  clock_skew                  = "0s"
  dev_mode                    = true
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = true # false
  id_token_userinfo_assertion = true # false
  additional_origins          = []
}

locals {
  // BBB GreenLight configuration
  bbb_gl_config_fn = "${GL_CONFIG}"
  bbb_gl_config = templatefile("../bbb/templates/bbb-gl-config.tpl", {
    CLIENT_ID     = zitadel_application_oidc.bbb_oidc.client_id
    CLIENT_SECRET = zitadel_application_oidc.bbb_oidc.client_secret
    ISSUER        = local.zitadel_base_url
    REDIRECT      = "${BBB_URL}"
  })
}

resource "terraform_data" "bbb_config_deploy" {
  triggers_replace = zitadel_application_oidc.bbb_oidc

  connection {
    type        = "ssh"
    user        = ${ADMIN_NAME}
    host        = ${BBB_HOST}
    agent       = false
    private_key = file("${ADMIN_SSH_KEY}")
  }

  provisioner "file" {
    content     = local.bbb_gl_config
    destination = local.bbb_gl_config_fn
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh -c 'cat ${ADMIN_NAME}/${GL_CONFIG} >> /root/greenlight-v3/.env'",
      "sudo sh -c 'cd /root/greenlight-v3/ && docker-compose down && docker-compose up -d'"
    ]
  }
}
