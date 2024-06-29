# ===================================
# DNS & Certificate Manager resources
# ===================================

data "yandex_dns_zone" "dns_zone" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  name      = var.yc_infra.dns_zone_name
}

# Create DNS record for the VM with created public ip address
resource "yandex_dns_recordset" "vm_dns_rec" {
  zone_id = data.yandex_dns_zone.dns_zone.id
  name    = var.zitadel_vm.name
  type    = "A"
  ttl     = 300
  data    = ["${yandex_vpc_address.vm_pub_ip.external_ipv4_address.0.address}"]
}

# Create LE certificate request for VM
resource "yandex_cm_certificate" "vm_le_cert" {
  folder_id   = data.yandex_resourcemanager_folder.folder.id
  name        = var.zitadel_vm.name
  description = "LE certificate for the ${var.zitadel_vm.name} VM"
  domains     = ["${local.zitadel_fqdn}"]
  managed {
    challenge_type = "DNS_CNAME"
  }
}

# Create domain validation DNS record for Let's Encrypt service
resource "yandex_dns_recordset" "validation_dns_rec" {
  zone_id = data.yandex_dns_zone.dns_zone.id
  name    = yandex_cm_certificate.vm_le_cert.challenges[0].dns_name
  type    = yandex_cm_certificate.vm_le_cert.challenges[0].dns_type
  data    = [yandex_cm_certificate.vm_le_cert.challenges[0].dns_value]
  ttl     = 60
}

