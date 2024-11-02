# =================
# Compute Resources
# =================

data "yandex_compute_image" "bbb_vm_image" {
  family = var.bbb_vm.image_family
}

locals {
  # BBB Setup script preparation
  bbb_setup_fn = "bbb-setup.sh"
  bbb_setup = templatefile("${path.module}/templates/bbb-vm-setup.tpl", {
    ADMIN_NAME = var.bbb_vm.admin_user
    CERT_PRIV  = var.bbb_vm.cert_priv
    CERT_PUB   = var.bbb_vm.cert_pub
    FQDN       = "${var.bbb_vm.pub_name}.${trimsuffix(data.yandex_dns_zone.dns_zone.zone, ".")}"
  })
}

resource "yandex_compute_instance" "bbb_vm1" {
  folder_id   = var.bbb_vm.infra_folder_id
  name        = var.bbb_vm.name
  hostname    = var.bbb_vm.name
  platform_id = "standard-v3"
  zone        = var.bbb_vm.infra_zone_id

  resources {
    cores  = var.bbb_vm.vcpu
    memory = var.bbb_vm.ram
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.bbb_vm_image.id
      type     = "network-ssd"
      size     = var.bbb_vm.disk_size
    }
  }

  network_interface {
    subnet_id          = var.bbb_vm.infra_subnet1_id
    nat                = true
    nat_ip_address     = yandex_vpc_address.bbb_vm.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.bbb_vm_sg.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/templates/bbb-vm-init.tpl", {
      ADMIN_NAME    = var.bbb_vm.admin_user
      ADMIN_SSH_KEY = file("${var.bbb_vm.admin_key_file}.pub")
    })
  }

  lifecycle {
    ignore_changes = [boot_disk.0.initialize_params.0.image_id]
  }

  provisioner "file" {
    source      = var.bbb_vm.cert_priv
    destination = "privkey.pem"
  }

  provisioner "file" {
    source      = var.bbb_vm.cert_pub
    destination = "fullchain.pem"
  }

  provisioner "file" {
    content     = local.bbb_setup
    destination = local.bbb_setup_fn
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/${local.bbb_setup_fn}",
      "### sudo ~/${local.bbb_setup_fn}"
    ]
  }

  connection {
    type        = "ssh"
    user        = var.bbb_vm.admin_user
    host        = yandex_vpc_address.bbb_vm.external_ipv4_address[0].address
    agent       = false
    private_key = file("${var.bbb_vm.admin_key_file}")
  }
}
