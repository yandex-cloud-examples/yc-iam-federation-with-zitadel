# ==========================
# YC MDB Postgress Resources
# ==========================

resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  folder_id   = data.yandex_resourcemanager_folder.folder.id
  name        = var.pg_cluster.name
  environment = "PRODUCTION"
  network_id  = data.yandex_vpc_network.net.id

  config {
    version = var.pg_cluster.version
    resources {
      resource_preset_id = var.pg_cluster.flavor
      disk_type_id       = "network-ssd"
      disk_size          = var.pg_cluster.disk_size
    }
  }

  host {
    zone      = var.yc_infra.zone_id
    subnet_id = data.yandex_vpc_subnet.subnet1.id
  }
}

resource "yandex_mdb_postgresql_user" "pg_user" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = var.pg_cluster.db_user
  password   = var.pg_cluster.db_pass
}

resource "yandex_mdb_postgresql_database" "pg_db" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = var.pg_cluster.db_name
  owner      = yandex_mdb_postgresql_user.pg_user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
}
