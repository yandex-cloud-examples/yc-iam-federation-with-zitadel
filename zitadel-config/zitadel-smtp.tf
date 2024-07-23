# ==========================
# Zitadel SMTP configuration
# ==========================

resource "zitadel_smtp_config" "instance" {
  count            = var.zitadel_smtp.enabled ? 1 : 0
  sender_address   = var.zitadel_smtp.sender_address
  reply_to_address = var.zitadel_smtp.reply_address
  sender_name      = var.zitadel_smtp.sender_name
  tls              = var.zitadel_smtp.tls
  host             = var.zitadel_smtp.host
  user             = var.zitadel_smtp.user
  password         = var.zitadel_smtp.password
}
