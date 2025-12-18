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
    access_key                  = "key"
    secret_key                  = "key"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  zone = var.yc-zone
}
