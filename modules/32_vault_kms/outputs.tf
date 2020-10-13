/**
 * Copyright 2020 Open Infrastructure Services, LLC
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

output "vault_kms_keyring" {
  description = "The vault keyring used to unseal vault storage in GCS.  This keyring should persist with a long term lifecycle."
  value       = google_kms_key_ring.vault.id
}

output "vault_kms_key_init" {
  description = "The KMS key used to unseal vault storage in GCS.  This keyring should persist with a long term lifecycle."
  value       = google_kms_crypto_key.vault-init.id
}
