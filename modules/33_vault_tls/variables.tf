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

variable "manage_tls" {
  description = "Set to `false` if you'd like to manage and upload your own TLS files. See `Managing TLS` for more details"
  type        = bool
  default     = true
}

variable "tls_save_ca_to_disk" {
  description = "Save the CA public certificate on the local filesystem. The CA is always stored in GCS, but this option also saves it to the filesystem."
  type        = bool
  default     = true
}

variable "tls_ca_subject" {
  description = "The `subject` block for the root CA certificate."
  type = object({
    common_name         = string,
    organization        = string,
    organizational_unit = string,
    street_address      = list(string),
    locality            = string,
    province            = string,
    country             = string,
    postal_code         = string,
  })

  default = {
    common_name         = "Example Inc. Root"
    organization        = "Example, Inc"
    organizational_unit = "Department of Certificate Authority"
    street_address      = ["123 Example Street"]
    locality            = "The Intranet"
    province            = "CA"
    country             = "US"
    postal_code         = "95559-1227"
  }
}

variable "tls_dns_names" {
  description = "List of DNS names added to the Vault server self-signed certificate"
  type        = list(string)
  default     = ["vault.example.net"]
}

variable "tls_ips" {
  description = "List of IP addresses added to the Vault server self-signed certificate"
  type        = list(string)
  default     = ["127.0.0.1"]
}

variable "tls_cn" {
  description = "The TLS Common Name for the TLS certificates"
  type        = string
  default     = "vault.example.net"
}

variable "tls_ou" {
  description = "The TLS Organizational Unit for the TLS certificate"
  type        = string
  default     = "IT Security Operations"
}

variable "vault_tls_key_filename" {
  description = "Encrypted and base64 encoded GCS object path within the vault_tls_bucket. This is the Vault TLS private key."
  type        = string
  default     = "vault.key.enc"
}

variable "vault_tls_cert_filename" {
  description = "GCS object path within the vault_tls_bucket. This is the vault server certificate."
  type        = string
  default     = "vault.crt"
}

variable "vault_ca_cert_filename" {
  description = "GCS object path within the vault_tls_bucket. This is the root CA certificate."
  type        = string
  default     = "ca.crt"
}

variable "vault_tls_bucket" {
  description = "GCS Bucket to store TLS certificates in."
  type        = string
}

variable "vault_kms_key_tls" {
  description = "KMS key used to encrypt TLS secrets.  The same keyring as the vault init keyring may be used here.  Full path."
  type        = string
}
