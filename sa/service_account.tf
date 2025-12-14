resource "yandex_resourcemanager_folder" "diplom-folder" {
  cloud_id = var.cloud_id
  name     = var.yc-folder-name
}

resource "yandex_iam_service_account" "diplom-sa" {
  description = "Service account to allow Terraform to manage catalog"
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
  name        = "diplom-sa"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.diplom-sa.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "sa-admin" {
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
  role      = "storage.admin"
  members   = [
    "serviceAccount:${yandex_iam_service_account.diplom-sa.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "encrypterDecrypter" {
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
  role      = "kms.keys.encrypterDecrypter"
  members   = [
    "serviceAccount:${yandex_iam_service_account.diplom-sa.id}"
  ]
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  description        = "Static access key for object storage"
  service_account_id = yandex_iam_service_account.diplom-sa.id
}

