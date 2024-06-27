# ====================
# Zitadel VM resources
# ====================

locals {
  zita_fqdn     = "${var.zitadel_vm.name}.${trimsuffix(data.yandex_dns_zone.dns_zone.zone, ".")}"
  zita_endpoint = "${local.zita_fqdn}:${var.zitadel_vm.port}"
  zita_base_url = "https://${local.zita_endpoint}"
  jwt_key_file  = "${var.zitadel_vm.name}-sa.json"
}

# Service Account for Zitadel VM & their bindings
resource "yandex_iam_service_account" "zita_vm_sa" {
  folder_id   = data.yandex_resourcemanager_folder.folder.id
  name        = "${var.zitadel_vm.name}-sa"
  description = "Service account for ${var.zitadel_vm.name} VM"
}

resource "yandex_lockbox_secret_iam_binding" "zita_masterkey" {
  secret_id = yandex_lockbox_secret.zita_masterkey.id
  role      = "lockbox.payloadViewer"
  members   = ["serviceAccount:${yandex_iam_service_account.zita_vm_sa.id}"]
}

resource "yandex_lockbox_secret_iam_binding" "pg_host" {
  secret_id = yandex_lockbox_secret.pg_host.id
  role      = "lockbox.payloadViewer"
  members   = ["serviceAccount:${yandex_iam_service_account.zita_vm_sa.id}"]
}

resource "yandex_lockbox_secret_iam_binding" "pg_user" {
  secret_id = yandex_lockbox_secret.pg_user.id
  role      = "lockbox.payloadViewer"
  members   = ["serviceAccount:${yandex_iam_service_account.zita_vm_sa.id}"]
}

resource "yandex_resourcemanager_folder_iam_binding" "cm_certs" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  role      = "certificate-manager.certificates.downloader"
  members   = ["serviceAccount:${yandex_iam_service_account.zita_vm_sa.id}"]
}

# Prepare Zitadel provisioning script
locals {
  zita_setup_fn = "zita-setup.sh"
  zita_setup = templatefile("${path.module}/templates/zitadel-setup.tpl", {
    CNTR_NAME     = var.zitadel_cntr.name
    ZT_SRC        = var.zitadel_cntr.zitadel_source
    ZT_VER        = var.zitadel_cntr.zitadel_version
    ZT_FILE       = var.zitadel_cntr.zitadel_file
    YQ_SRC        = var.zitadel_cntr.yq_source
    YQ_VER        = var.zitadel_cntr.yq_version
    YQ_FILE       = var.zitadel_cntr.yq_file
    CR_NAME       = var.zitadel_cntr.cr_name
    CR_BASE_IMAGE = var.zitadel_cntr.cr_base_image
    ADMIN_NAME    = var.zitadel_vm.admin_user
    SA_NAME       = "${var.zitadel_vm.name}-sa"
    DB_HOST       = yandex_mdb_postgresql_cluster.pg_cluster.host.0.fqdn
    DB_PORT       = var.pg_cluster.db_port
    DB_NAME       = var.pg_cluster.db_name
    DB_USER       = var.pg_cluster.db_user
    DB_PASS       = var.pg_cluster.db_pass
    VM_FQDN       = local.zita_fqdn
    VM_PORT       = var.zitadel_vm.port
  })
}

# Create Zitadel VM
data "yandex_compute_image" "vm_image" {
  family = var.zitadel_vm.image_family
}

resource "yandex_compute_instance" "zita_vm1" {
  folder_id          = data.yandex_resourcemanager_folder.folder.id
  name               = var.zitadel_vm.name
  hostname           = var.zitadel_vm.name
  description        = local.zita_fqdn
  platform_id        = "standard-v3"
  zone               = data.yandex_vpc_subnet.subnet1.zone
  service_account_id = yandex_iam_service_account.zita_vm_sa.id

  resources {
    cores  = var.zitadel_vm.vcpu
    memory = var.zitadel_vm.ram
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_image.id
      type     = "network-ssd"
      size     = var.zitadel_vm.disk_size
    }
  }

  network_interface {
    subnet_id          = data.yandex_vpc_subnet.subnet1.id
    nat                = true
    nat_ip_address     = yandex_vpc_address.vm_pub_ip.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.vm_sg.id]
  }

  # Build the CloudInit config
  metadata = {
    user-data = templatefile("${path.module}/templates/zitadel-vm-init.tpl", {
      ADMIN_NAME     = var.zitadel_vm.admin_user
      ADMIN_SSH_KEY  = file(var.zitadel_vm.admin_key_file)
      zita_masterkey = yandex_lockbox_secret.zita_masterkey.id
      pg_host        = yandex_lockbox_secret.pg_host.id
      pg_db          = var.pg_cluster.db_name
      pg_user        = yandex_lockbox_secret.pg_user.id
      cert_id        = yandex_cm_certificate.vm_le_cert.id
    })
  }
  # Copy provisioning script to VM
  provisioner "file" {
    content     = local.zita_setup
    destination = local.zita_setup_fn
  }

  # Copy filed for build Docker container
  provisioner "file" {
    source      = "${path.module}/docker/"
    destination = "."
  }

  connection {
    type = "ssh"
    user = var.zitadel_vm.admin_user
    host = yandex_vpc_address.vm_pub_ip.external_ipv4_address[0].address
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/zita-setup.sh",
      "sudo ~/zita-setup.sh"
    ]
  }

  lifecycle {
    ignore_changes = [boot_disk.0.initialize_params.0.image_id]
  }

  depends_on = [yandex_mdb_postgresql_database.pg_db]
}

# Copy JWT Key from VM to Terraform node
resource "null_resource" "copy_jwt_key" {
  provisioner "local-exec" {
    command = <<-CMD
    scp ${var.zitadel_vm.admin_user}@${yandex_vpc_address.vm_pub_ip.external_ipv4_address[0].address}:${local.jwt_key_file} ${var.zitadel_vm.jwt_path}/${local.jwt_key_file}
    ssh ${var.zitadel_vm.admin_user}@${yandex_vpc_address.vm_pub_ip.external_ipv4_address[0].address} rm ${local.jwt_key_file}
    CMD
  }
  depends_on = [yandex_compute_instance.zita_vm1]
}
