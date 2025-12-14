resource "yandex_kms_symmetric_key" "key-a" {
  description       = "Simmetric key"
  folder_id   = yandex_resourcemanager_folder.diplom-folder.id
  name              = "symmetric-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
  lifecycle {
    prevent_destroy = false
  }
}

resource "yandex_storage_bucket" "backend-encrypted" {
  bucket     = var.backend_bucket_id
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  anonymous_access_flags {
    read = false
    list = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
