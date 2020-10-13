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

output "ca_cert_pem" {
  description = "CA certificate used to verify Vault TLS client connections."
  value       = tls_self_signed_cert.root.*.cert_pem
  sensitive   = false
}

output "ca_key_pem" {
  description = "Private key for the CA."
  value       = tls_private_key.root.*.private_key_pem
  sensitive   = true
}
