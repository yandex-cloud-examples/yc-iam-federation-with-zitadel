# ===================================
# DNS & Certificate Manager resources
# ===================================

data "yandex_dns_zone" "dns_zone" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  name      = var.yc_infra.dns_zone_name
}

/*
# Create DNS record for the Zitadel instance
resource "yandex_dns_recordset" "zitadel_vm" {
  zone_id = data.yandex_dns_zone.dns_zone.id
  name    = "id"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_vpc_address.vm_pub_ip.external_ipv4_address.0.address}"]
}
*/

resource "yandex_dns_recordset" "dns_zone_root" {
  zone_id = data.yandex_dns_zone.dns_zone.id
  name    = "@"
  type    = "A"
  ttl     = 300
  data    = ["${yandex_vpc_address.vm_pub_ip.external_ipv4_address.0.address}"]
}

locals {
  domain = trimsuffix(data.yandex_dns_zone.dns_zone.zone, ".")
}

# Create wildcard LE certificate for a whole domain
resource "yandex_cm_certificate" "domain_le_cert" {
  folder_id   = data.yandex_resourcemanager_folder.folder.id
  name        = "zitadel"
  description = "LE certificate for the whole domain"
  domains     = ["*.${local.domain}", "${local.domain}"]
  managed {
    challenge_type = "DNS_CNAME"
  }
}

# Create domain validation DNS record for Let's Encrypt service
resource "yandex_dns_recordset" "domain_le_validation_dns_rec" {
  zone_id = data.yandex_dns_zone.dns_zone.id
  name    = yandex_cm_certificate.domain_le_cert.challenges[0].dns_name
  type    = yandex_cm_certificate.domain_le_cert.challenges[0].dns_type
  data    = [yandex_cm_certificate.domain_le_cert.challenges[0].dns_value]
  ttl     = 60
}
