
resource "yandex_kubernetes_node_group" "node-group-diplom" {
  cluster_id  = yandex_kubernetes_cluster.regional-cluster-diplom.id
  name        = "node-group-diplom"
  description = "K8s node group"
  version     = "1.32"

  labels = {
    diplom_node_group  = "k8s-node-group"
  }

  instance_template {
    platform_id = "standard-v1"

    metadata = {
        user-data = "${file("cloud-init.yml")}"
    }

    network_interface {
      nat        = true
      subnet_ids = [ var.vpc_subnet-1_id, var.vpc_subnet-2_id,  var.vpc_subnet-3_id]
    }

    resources {
      memory = var.memory
      cores  = var.cores
      core_fraction = var.core_fraction
    }

    boot_disk {
      type = var.type
      size = var.size
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      initial = var.scale_initial
      max     = var.scale_max
      min     = var.scale_min
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
     location {
      zone = "ru-central1-b"
    }
     location {
      zone = "ru-central1-d"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

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

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller
  ]

}
