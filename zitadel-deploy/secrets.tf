# ===============
# Lockbox secrets
# ===============

// Zitadel Masterkey
resource "yandex_lockbox_secret" "zita_masterkey" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  name      = "${var.zitadel_vm.name}-masterkey"
}

locals {
  zita_masterkey = replace(replace(substr(base64sha256(timestamp()), 5, 32), "+", "v"), "/", "Z")
}

resource "yandex_lockbox_secret_version" "zita_masterkey" {
  secret_id = yandex_lockbox_secret.zita_masterkey.id
  entries {
    key        = "${var.zitadel_vm.name}-masterkey"
    text_value = local.zita_masterkey
  }
  lifecycle {
    ignore_changes = [entries]
  }
}

// PostgreSQL cluster hostname (FQDN)
resource "yandex_lockbox_secret" "pg_host" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  name      = "${var.zitadel_vm.name}-pg-host"
}

resource "yandex_lockbox_secret_version" "pg_host" {
  secret_id = yandex_lockbox_secret.pg_host.id
  entries {
    key        = "hostname"
    text_value = "c-${yandex_mdb_postgresql_cluster.pg_cluster.id}.rw.mdb.yandexcloud.net"
  }
}

// PostgreSQL cluster Username & Password
resource "yandex_lockbox_secret" "pg_user" {
  folder_id = data.yandex_resourcemanager_folder.folder.id
  name      = "${var.zitadel_vm.name}-pg-user"
}

resource "yandex_lockbox_secret_version" "pg_user" {
  secret_id = yandex_lockbox_secret.pg_user.id
  entries {
    key        = var.pg_cluster.db_user
    text_value = var.pg_cluster.db_pass
  }
}
