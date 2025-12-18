resource "yandex_kubernetes_cluster" "regional-cluster-diplom" {
  description = "K8s regional cluster"
  name        = "regional-cluster-diplom"
  folder_id = var.folder_id
  network_id = var.network-vpc-diplom_id

  kms_provider {
    key_id = var.simmetric_key_id
  }

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = "ru-central1-a"
        subnet_id = var.vpc_subnet-1_id
      }

      location {
        zone      = "ru-central1-b"
        subnet_id = var.vpc_subnet-2_id
      }

      location {
        zone      = "ru-central1-d"
        subnet_id = var.vpc_subnet-3_id
      }
    }

    version   = "1.32"
    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }

      maintenance_window {
        day        = "friday"
        start_time = "10:00"
        duration   = "4h30m"
      }
    }

    scale_policy {
      auto_scale {
        min_resource_preset_id = "s-c4-m16"
      }
    }
  }

  service_account_id      = var.sa_id
  node_service_account_id = var.sa_id

  labels = {
    my_key       = "my_value"
    my_other_key = "my_other_value"
  }

  release_channel = "STABLE"

  # workload_identity_federation {
  #   enabled = true
  # }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller
  ]
}

resource "yandex_kubernetes_cluster_iam_binding" "viewer" {
  cluster_id = yandex_kubernetes_cluster.regional-cluster-diplom.id
  role = "viewer"
  members = [
    "serviceAccount:${var.sa_id}"
  ]
}
