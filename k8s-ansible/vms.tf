resource "yandex_compute_instance" "cluster-k8s" {
  count   = 3
  name                      = "node-${count.index}"
  zone                      = "${var.subnet-zones[count.index]}"
  hostname                  = "node-${count.index}"
  platform_id = "standard-v3"
  allow_stopping_for_update = true
  labels = {
    index = "${count.index}"
  }

  scheduling_policy {
  preemptible = false
  }

  resources {
    cores  = var.cores
    memory = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu-2204-lts}"
      type        = var.type
      size        = var.size
    }
  }

  network_interface {
    subnet_id  = var.subnet-ids[count.index]
    nat        = true
  }

  metadata = {
    user-data = "${file("cloud-init.yml")}"
    ssh-keys = file("~/.ssh/id_ed25519.pub")
  }
}