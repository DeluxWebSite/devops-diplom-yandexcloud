output "current-workspace-name" {
  value = terraform.workspace
}

output "yc-id" {
  value = yandex_resourcemanager_folder.diplom-folder.cloud_id
}

output "yc-folder-id" {
  value = yandex_resourcemanager_folder.diplom-folder.id
}

output "yc-zone" {
  value = var.yc-zone
}

output "network-id" {
  value = yandex_vpc_network.network-vpc-diplom.id
}
output "vpc-network-subnet-1" {
  value = yandex_vpc_subnet.vpc_subnet-1.id
}
output "vpc-network-subnet-2" {
  value = yandex_vpc_subnet.vpc_subnet-2.id
}
output "vpc-network-subnet-3" {
  value = yandex_vpc_subnet.vpc_subnet-3.id
}

output "s3_access_key" {
  description = "Yandex Cloud S3 access key"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "Yandex Cloud S3 secret key"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive   = true
}

resource "local_file" "keys" {
  content = <<-EOT
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
    access_key                  = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
    secret_key                  = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  zone = var.yc-zone
}
  EOT
  filename = "../backend/provider.tf"
}

