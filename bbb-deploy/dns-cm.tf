# ===================================
# DNS & Certificate Manager resources
# ===================================

# Get specified DNS Zone
data "yandex_dns_zone" "dns_zone" {
  folder_id = var.bbb_vm.infra_folder_id
  name      = var.bbb_vm.infra_dns_zone_name
}

# Add A record for BBB VM
resource "yandex_dns_recordset" "bbb_a_record" {
  zone_id = data.yandex_dns_zone.dns_zone.id
  name    = "${var.bbb_vm.pub_name}.${data.yandex_dns_zone.dns_zone.zone}"
  type    = "A"
  ttl     = 600
  data    = ["${yandex_vpc_address.bbb_vm.external_ipv4_address[0].address}"]
}

# Create LE certificate request for BBB VM
resource "yandex_cm_certificate" "bbb_le_request" {
  folder_id = var.bbb_vm.infra_folder_id
  name      = var.bbb_vm.pub_name
  domains   = ["${var.bbb_vm.pub_name}.${trimsuffix(data.yandex_dns_zone.dns_zone.zone, ".")}"]
  managed {
    challenge_type = "DNS_CNAME"
  }
}

# Create domain validation DNS record for BBB request
resource "yandex_dns_recordset" "bbb_dns_validation" {
  zone_id = data.yandex_dns_zone.dns_zone.id
  name    = yandex_cm_certificate.bbb_le_request.challenges[0].dns_name
  type    = yandex_cm_certificate.bbb_le_request.challenges[0].dns_type
  data    = [yandex_cm_certificate.bbb_le_request.challenges[0].dns_value]
  ttl     = 60
}

# Still waiting upon the certificate will be issued (up to 30 min!)
data "yandex_cm_certificate_content" "cert_check_status" {
  folder_id          = var.bbb_vm.infra_folder_id
  name               = var.bbb_vm.pub_name
  wait_validation    = true
  private_key_format = "PKCS1"
  depends_on         = [yandex_dns_recordset.bbb_dns_validation]
}
