# ================
# Gitlab resources
# ================

provider "gitlab" {
  base_url = "${GITLAB_URL}/api/v4/"
  token    = chomp(file("${TOKEN_FILE}"))
}

resource "gitlab_group" "group1" {
  name             = "${GROUP_NAME}"
  path             = "${GROUP_NAME}"
  description      = "${GROUP_NAME} users group"
  visibility_level = "private"
}

resource "gitlab_project" "project1" {
  name             = "${GROUP_NAME}"
  description      = "${GROUP_NAME} group repository"
  visibility_level = "private"
  namespace_id     = gitlab_group.group1.id
}

# https://zitadel.com/docs/guides/integrate/services/gitlab-self-hosted
resource "zitadel_application_oidc" "gitlab_oidc" {
  org_id                      = zitadel_org.org.id
  project_id                  = zitadel_project.project.id
  name                        = "gitlab-omniauth-oidc"
  redirect_uris               = ["${GITLAB_URL}/users/auth/openid_connect/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris   = ["${GITLAB_URL}"]
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
