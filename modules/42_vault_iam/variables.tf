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

variable "project_id" {
  description = "Project ID to contain managed resources."
  type        = string
}

variable "kms_keyring" {
  description = "Name of the Cloud KMS KeyRing for unsealing vault and TLS keys.  If blank, defaults to `projects/PROJECT_ID/locations/us/keyRings/vault`.  For example, 'projects/myproject/locations/us-west1/keyRings/vault'"
  type        = string
  default     = ""
}

variable "kms_crypto_key" {
  description = "The name of the Cloud KMS Key used for encrypting initial TLS certificates and for configuring Vault auto-unseal."
  type        = string
  default     = "vault-init"
}

variable "vault_service_account_email" {
  description = "Vault service account email"
  type        = string
}

variable "service_account_project_iam_roles" {
  description = "List of IAM roles for the Vault admin service account to function. If you need to add additional roles, update `service_account_project_additional_iam_roles` instead."
  type        = list(string)
  default     = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ]
}

variable "service_account_project_additional_iam_roles" {
  type    = list(string)
  default = []

  description = "List of custom IAM roles to add to the project."
}

variable "service_account_storage_bucket_iam_roles" {
  description = "List of IAM roles for the Vault admin service account to have on the storage bucket."
  type = list(string)

  default = [
    "roles/storage.legacyBucketReader",
    "roles/storage.objectAdmin",
  ]
}

variable "manage_tls" {
  description = "Set to `false` if you'd like to manage and upload your own TLS files. See `Managing TLS` for more details"
  type        = bool
  default     = true
}

variable "vault_storage_bucket" {
  description = "Storage bucket name where the backend is configured."
  type        = string
}

variable "vault_tls_bucket" {
  description = "GCS Bucket override where Vault will expect TLS certificates are stored."
  type        = string
  default     = ""
}
