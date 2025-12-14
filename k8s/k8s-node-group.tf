
resource "yandex_kubernetes_node_group" "node_group_diplom" {
  cluster_id  = yandex_kubernetes_cluster.egional_cluster_diplom.id
  name        = "node_group_diplom"
  description = "K8s node group"
  version     = "1.30"

  labels = {
    diplom  = "k8s-node-group"
  }

  instance_template {
    platform_id = "standard-v2"

    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

    network_interface {
      nat        = false
      subnet_ids = [yandex_vpc_subnet.vpc_subnet-1.id,yandex_vpc_subnet.vpc_subnet-2.id, yandex_vpc_subnet.vpc_subnet-3.id]
    }

    resources {
      memory = 2
      cores  = 2
      core_fraction = 5 # % CPU
    }

    boot_disk {
      type = "network-hdd"
      size = 20
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
      initial = 3
      max     = 6
      min     = 3
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
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
}
