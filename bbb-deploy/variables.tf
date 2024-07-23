# =============
# bbb TF-Module
# =============

variable "bbb_vm" {
  description = "Big Blue Button (BBB) VM attributes"
  type = object(
    {
      name         = string
      pub_name     = string
      version      = string
      vcpu         = number
      ram          = number
      disk_size    = number
      image_family = string
      port         = string
      cert_priv    = string
      cert_pub     = string

      infra_zone_id       = string # imported from zitadel-deploy
      infra_folder_id     = string # imported from zitadel-deploy
      infra_dns_zone_name = string # imported from zitadel-deploy
      admin_user          = string # imported from zitadel-deploy
      admin_key_file      = string # imported from zitadel-deploy
      infra_net_id        = string # imported from zitadel-deploy
      infra_subnet1_id    = string # imported from zitadel-deploy
    }
  )
}
