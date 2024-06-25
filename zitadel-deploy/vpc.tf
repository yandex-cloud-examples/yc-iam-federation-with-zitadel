# =============
# VPC resources
# =============

# Infra Folder
data "yandex_resourcemanager_folder" "folder" {
  name     = var.yc_infra.folder_name
  cloud_id = var.yc_infra.cloud_id
}

# Infra Network
data "yandex_vpc_network" "net" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  name      = var.yc_infra.network
}

# Infra Subnet#1
data "yandex_vpc_subnet" "subnet1" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  name      = var.yc_infra.subnet1
}

# =============================================
# Infra Subnet#2. If HA deployemnt is required.
# =============================================
#data "yandex_vpc_subnet" "subnet2" {
#  folder_id = data.yandex_resourcemanager_folder.folder.id
#  name      = var.yc_infra.subnet2
#}

# Create public ip address for VM
resource "yandex_vpc_address" "vm_pub_ip" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  name      = var.zitadel_vm.name
  external_ipv4_address {
    zone_id = var.yc_infra.zone_id
  }
}

# Create Security Group for VM
resource "yandex_vpc_security_group" "vm_sg" {
  name       = "${var.zitadel_vm.name}-sg"
  folder_id  = data.yandex_resourcemanager_folder.folder.id
  network_id = data.yandex_vpc_network.net.id

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
    port           = var.zitadel_vm.port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
