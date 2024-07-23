# ====================
# Gitlab configuration
# ====================

locals {

  gitlab_url = "https://${var.gitlab.domain}.gitlab.yandexcloud.net"

  config_out = "../../zitadel-config/gitlab.tf"

  config_data = templatefile("${path.module}/templates/gitlab-config.tpl", {
    GROUP_NAME = var.gitlab.group_name
    GITLAB_URL = local.gitlab_url
    TOKEN_FILE = pathexpand(var.gitlab.token_file)
  })
}

resource "local_file" "gitlab_config" {
  content         = local.config_data
  filename        = local.config_out
  file_permission = 644
}
