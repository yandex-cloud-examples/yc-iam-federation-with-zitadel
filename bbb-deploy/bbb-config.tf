# ==============================
# BBB TF configuration generator
# ==============================

locals {
  config_out = "../../zitadel-config/bbb-config.tf"

  config_data = templatefile("${path.module}/templates/bbb-config.tpl", {
    BBB_URL       = "https://${var.bbb_vm.pub_name}.${trimsuffix(data.yandex_dns_zone.dns_zone.zone, ".")}"
    GL_CONFIG     = "greenlight-config.txt"
    BBB_HOST      = yandex_vpc_address.bbb_vm.external_ipv4_address[0].address
    ADMIN_NAME    = var.bbb_vm.admin_user
    ADMIN_SSH_KEY = pathexpand(var.bbb_vm.admin_key_file)
  })
}

resource "local_file" "bbb_config" {
  content         = local.config_data
  filename        = local.config_out
  file_permission = 644
}
