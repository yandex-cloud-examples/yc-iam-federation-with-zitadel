# ========================
# Zitadel-deploy TF-Module
# ========================


# ==========================
# Infra & Network attributes
# ==========================
variable "yc_infra" {
  description = "YC Infra resources"
  type = object(
    {
      cloud_id      = string
      folder_name   = string
      zone_id       = string
      dns_zone_name = string
      network       = string # VPC Network name
      subnet1       = string # VPC subnet1 name
      #zone_id2      = string # VPC zone Id and Subnet for HA deployment
      #subnet2       = string
    }
  )
}

# =============================
# PostgreSQL cluster attributes
# =============================
variable "pg_cluster" {
  description = "Postgress MDB cluster attributes"
  type = object(
    {
      name      = string
      version   = string
      flavor    = string
      disk_size = number
      db_port   = string
      db_name   = string # Database name
      db_user   = string # Database admin username
      db_pass   = string # Database admin password
    }
  )
}

# =====================
# Zitadel VM attributes
# =====================
variable "zitadel_vm" {
  description = "Zitadel VM attributes"
  type = object(
    {
      name         = string
      version      = string # Zitadel version
      vcpu         = number
      ram          = number
      disk_size    = number
      image_family = string # Base OS image
      port         = string
      jwt_path     = string
      admin_user   = string
      #admin_pass     = string
      admin_key_file = string # Admin's SSH public key file
      cr_name        = string # Containers images regitsry name
      cr_base_image  = string
    }
  )
}

# ===============
# Zitadel Outputs
# ===============

output "zita_base_url" {
  value = local.zita_base_url
}

output "jwt_key_full_path" {
  value = "${var.zitadel_vm.jwt_path}/${local.jwt_key_file}"
}
