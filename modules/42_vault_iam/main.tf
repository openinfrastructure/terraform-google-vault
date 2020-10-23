/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  service_account_member = "serviceAccount:${var.vault_service_account_email}"
  tls_buckets = compact([var.vault_tls_bucket])
  kms_keyring = var.kms_keyring == "" ? "projects/${var.project_id}/locations/us/keyrings/vault" : var.kms_keyring
}

# Give project-level IAM permissions to the service account.
resource "google_project_iam_member" "project-iam" {
  for_each = toset(var.service_account_project_iam_roles)
  project  = var.project_id
  role     = each.value
  member   = local.service_account_member
}

# Give additional project-level IAM permissions to the service account.
resource "google_project_iam_member" "additional-project-iam" {
  for_each = toset(var.service_account_project_additional_iam_roles)
  project  = var.project_id
  role     = each.key
  member   = local.service_account_member
}

# Give bucket-level permissions to the service account.
resource "google_storage_bucket_iam_member" "vault" {
  for_each = toset(var.service_account_storage_bucket_iam_roles)
  bucket   = var.vault_storage_bucket
  role     = each.key
  member   = local.service_account_member
}

# Give kms cryptokey-level permissions to the service account.
resource "google_kms_crypto_key_iam_member" "ck-iam" {
  crypto_key_id = "${local.kms_keyring}/cryptoKeys/${var.kms_crypto_key}"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = local.service_account_member
}

# Vault needs the cloudkms.cryptoKeys.get permission
# See: https://www.vaultproject.io/docs/configuration/seal/gcpckms.html
resource "google_kms_key_ring_iam_member" "ck-iam" {
  key_ring_id = local.kms_keyring
  role        = "roles/cloudkms.admin"
  member      = local.service_account_member
}

# Grant Vault the ability to create JWT tokens for itself.  This enables the
# shutdown script to login to Vault and execute vault operator step-down
resource "google_service_account_iam_member" "vault_server_TokenCreator" {
  service_account_id = "projects/-/serviceAccounts/${var.vault_service_account_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.vault_service_account_email}"
}

resource "google_storage_bucket_iam_member" "bucket-iam" {
  for_each = toset(local.tls_buckets)
  bucket   = each.value
  role     = "roles/storage.objectViewer"
  member   = local.service_account_member
}
