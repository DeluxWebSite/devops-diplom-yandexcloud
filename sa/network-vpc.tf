resource "yandex_vpc_network" "network-vpc-diplom" {
  name = "network-vpc-diplom"
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
}

resource "yandex_vpc_subnet" "vpc_subnet-1" {
  name           = "vpc_subnet-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-vpc-diplom.id
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "vpc_subnet-2" {
  name           = "vpc_subnet-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-vpc-diplom.id
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_subnet" "vpc_subnet-3" {
  name           = "vpc_subnet-3"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.network-vpc-diplom.id
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}


