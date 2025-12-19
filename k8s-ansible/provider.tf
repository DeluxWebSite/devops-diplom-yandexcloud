terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.8"

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
   }
    bucket                      = "diplom-tf-backend"
    region                      = "ru-central1"
    key                         = "terraform.tfstate"
    access_key                  = "YCAJEig9WsrdkxvlM5lMW32bC"
    secret_key                  = "YCP_J7bD4sTxdBMwQVg_64Qb59rU7R2vPoMTS299"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  service_account_key_file = file("~/.ssh/authorized_key.json")
  cloud_id  = "${var.cloud_id}"
  folder_id = var.folder_id
  zone = var.yc-zone
}
