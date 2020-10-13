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
  description = "Project ID to manage resources within."
  type        = string
}

variable "region" {
  description = "Region in which to create resources."
  type        = string
  default     = "us-east4"
}

#
#
# KMS
# --------------------

variable "kms_keyring" {
  description = "KMS keyring used to encrypt Vault init keys.  This keyring must persist, otherwise Vault automatic unseal will fail.  Note, keyrings cannot be deleted.  The default generates a unique name."
  type        = string
  default     = ""
}

variable "kms_crypto_key" {
  description = "The name of the Cloud KMS Key used for encrypting initial TLS certificates and for configuring Vault auto-unseal. Terraform will create this key."
  type        = string
  default     = "vault-init"
}

variable "kms_protection_level" {
  description = "The protection level to use for the KMS crypto key."
  type        = string
  default     = "software"
}
