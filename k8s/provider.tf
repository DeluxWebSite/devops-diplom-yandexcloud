terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.8"
}

provider "yandex" {
  service_account_key_file = file("~/.ssh/authorized_key.json")
  cloud_id  = "${var.cloud_id}"
  zone = var.yc-zone
}
