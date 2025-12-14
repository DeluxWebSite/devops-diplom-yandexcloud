resource "yandex_kubernetes_cluster" "regional_cluster_diplom" {
  description = "K8s regional cluster"
  name        = "regional_cluster_diplom"


  network_id = yandex_vpc_network.network-vpc-diplom.id

  kms_provider {
    key_id = "${yandex_kms_symmetric_key.key-a.id}"
  }

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.vpc_subnet-1.zone
        subnet_id = yandex_vpc_subnet.vpc_subnet-1.id
      }

      location {
        zone      = yandex_vpc_subnet.vpc_subnet-2.zone
        subnet_id = yandex_vpc_subnet.vpc_subnet-2.id
      }

      location {
        zone      = yandex_vpc_subnet.vpc_subnet-3.zone
        subnet_id = yandex_vpc_subnet.vpc_subnet-3.id
      }
    }

    version   = "1.30"
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

    master_logging {
      enabled                    = true
      folder_id                  = data.yandex_resourcemanager_folder.diplom-folder.id
      kube_apiserver_enabled     = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      audit_enabled              = true
    }

    scale_policy {
      auto_scale {
        min_resource_preset_id = "s-c2-m8"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.diplom-sa.id
  node_service_account_id = yandex_iam_service_account.diplom-sa.id

  labels = {
    diplom  = "melnick-s-v"
  }

  release_channel = "STABLE"

  workload_identity_federation {
    enabled = true
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller
  ]
}

data "yandex_kubernetes_cluster" "regional_cluster_diplom" {
  name = "My Managed Kubernetes cluster"
}

resource "yandex_kubernetes_cluster_iam_binding" "viewer" {
  cluster_id = yandex_kubernetes_cluster.regional_cluster_diplom.id

  role = "viewer"

  members = [
    "userAccount:my_user_account_id",
    "serviceAccount:${yandex_iam_service_account.diplom-sa.id}",
  ]
}