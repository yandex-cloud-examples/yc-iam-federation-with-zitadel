# =================
# BBB VPC resources
# =================

# Reserve Public IP for BBB VM
resource "yandex_vpc_address" "bbb_vm" {
  name = var.bbb_vm.name

  external_ipv4_address {
    zone_id = var.bbb_vm.infra_zone_id
  }
}

# BBB VM Security Group
resource "yandex_vpc_security_group" "bbb_vm_sg" {
  name       = "${var.bbb_vm.name}-sg"
  folder_id  = var.bbb_vm.infra_folder_id
  network_id = var.bbb_vm.infra_net_id

  egress {
    description    = "Permit ALL"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "https"
    protocol       = "TCP"
    port           = var.bbb_vm.port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
