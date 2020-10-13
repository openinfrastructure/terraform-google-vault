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

variable "project_id" {
  description = "Project ID to contain managed resources."
  type        = string
}

variable "region" {
  description = "Region in which to create resources."
  type        = string
}

variable "name_prefix" {
  description = "The name prefix to us for managed resources, for example 'vault'.  Intended for major version upgrades of the module.  Use a unique value for each region.  See also UPGRADE.md for major version upgrades."
  type        = string
  default     = "vault"
}

variable "vault_instance_base_image" {
  description = "Base operating system image in which to install Vault. This must be a Debian-based system at the moment due to how the metadata startup script runs."
  type        = string
  default     = "debian-cloud/debian-10"
}

variable "machine_type" {
  description = "The machine type used with the instance template https://cloud.google.com/compute/docs/machine-types"
  type        = string
  default     = "n1-standard-1"
}

variable "preemptible" {
  description = "Allows instance to be preempted. This defaults to false. See https://cloud.google.com/compute/docs/instances/preemptible"
  type        = bool
  default     = false
}

variable "num_instances" {
  description = "The number of instances in the instance group"
  type        = number
  default     = 1
}

variable "min_ready_sec" {
  description = "Minimum number of seconds to wait for after a newly created instance becomes available. This value must be from range. [0,3600]"
  type        = number
  default     = 60
}

variable "hc_initial_delay_secs" {
  description = "The number of seconds that the managed instance group waits before it applies autohealing policies to new instances or recently recreated instances."
  type        = number
  default     = 60
}

variable "zones" {
  description = "The zones to distribute instances across.  If empty, all zones in the region are used.  ['us-west1-a', 'us-west1-b', 'us-west1-c']"
  type        = list(string)
  default     = []
}

variable "disk_type" {
  description = "The persistent disk type to use with the vault server instance template.  See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#disk_type"
  type        = string
  default     = "pd-standard"
}

variable "disk_size_gb" {
  description = "The size in GB of the persistent disk attached to each multinic instance.  The source_image size is used if unspecified."
  type        = string
  default     = null
}

variable "vault_port" {
  description = "Numeric port on which to run and expose Vault."
  type        = number
  default     = 8200
}

variable "vault_tls_disable_client_certs" {
  description = "Use client certificates when provided. You may want to disable this if users will not be authenticating to Vault with client certificates."
  type        = bool
  default     = false
}

variable "vault_tls_require_and_verify_client_cert" {
  description = "Always use client certificates. You may want to disable this if users will not be authenticating to Vault with client certificates."
  type        = bool
  default     = false
}

variable "vault_storage_bucket" {
  description = "Storage bucket name where the backend is configured. This bucket will not be created in this module"
  type        = string
}

variable "vault_tls_bucket" {
  description = "GCS Bucket override where Vault will expect TLS certificates are stored.  The vault_storage_bucket is used if not provided."
  type        = string
  default     = null
}

variable "vault_ui_enabled" {
  description = "Controls whether the Vault UI is enabled and accessible."
  type        = bool
  default     = true
}

variable "vault_version" {
  description = "Version of vault to install. This version must be 1.0+ and must be published on the HashiCorp releases service."
  type        = string
  default     = "1.5.4"
}

variable "user_startup_script" {
  description = "Additional user-provided code injected after Vault is setup"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "The service account bound to the compute instances.  vault-server@PROJECT_ID.iam.gserviceaccount.com is used if not provided."
  type        = string
  default     = null
}

variable "vault_args" {
  description = "Additional command line arguments passed to Vault server"
  type        = string
  default     = ""
}

variable "vault_ca_cert_filename" {
  description = "GCS object path within the vault_tls_bucket. This is the root CA certificate."
  type        = string
  default     = "ca.crt"
}

variable "vault_tls_cert_filename" {
  description = "GCS object path within the vault_tls_bucket. This is the vault server certificate."
  type        = string
  default     = "vault.crt"
}

variable "vault_tls_key_filename" {
  description = "Encrypted and base64 encoded GCS object path within the vault_tls_bucket. This is the Vault TLS private key."
  type        = string
  default     = "vault.key.enc"
}

variable "vault_kms_key_init" {
  description = "KMS Crypto key specific for seal and unseal.  Full path.  for example projects/vault/locations/us/keyRings/vault/cryptoKeys/vault-init"
  type        = string
}

variable "vault_kms_key_tls" {
  description = "KMS Crypto key specific for TLS decryption.  Full path.  If not specified, defaults to vault_kms_key_init."
  type        = string
  default     = null
}

variable "subnetwork" {
  description = "The self link of the VPC subnet for Vault, must include the project and region in the URI."
  type        = string
}

variable "http_proxy" {
  description = "Optional HTTP proxy for downloading agents and vault executable on startup.  This is only used on the first startup of the Vault cluster and will NOT set the global HTTP_PROXY environment variable. i.e. If you configure Vault to manage credentials for other services, default HTTP routes will be taken."
  type        = string
  default     = ""
}

variable "api_addr" {
  description = "The URI to access the vault API through the load balancer.  For example, https://vault.dev.ois.run:8443.  Defaults to https://var.vault_cluster_address:var.vault_port if not specified."
  type        = string
  default     = null
}

variable "vault_log_level" {
  description = "Log level to run Vault in. See the Vault documentation for valid values."
  type        = string
  default     = "warn"
}

variable "vault_instance_labels" {
  description = "Labels to apply to the Vault instances."
  type        = map(string)
  default     = {}
}

variable "vault_instance_tags" {
  description = "Instance tags to apply to the vault instance, intended for use with firewall rules."
  type        = list(string)
  default     = ["allow-ssh", "allow-vault"]
}

variable "vault_instance_metadata" {
  description = "Additional metadata to add to the Vault instances."
  type        = map(string)
  default     = {}
}

variable "vault_cluster_address" {
  type        = string
  description = "The IP address bound to forwarding rules.  The caller is expected to reserve an external or internal address with a google_compute_address resource and pass in the IP value here.  Example: 10.10.10.10"
}

variable "load_balancing_scheme" {
  description = "Options are INTERNAL or EXTERNAL. If `EXTERNAL`, the forwarding rule will be of type EXTERNAL and the provided IP address must an an external address. If `INTERNAL` the type will be INTERNAL the provided address must be an internal IP address."
  type        = string
  default     = "EXTERNAL"
}

variable "service_label" {
  type        = string
  description = "The service label to set on the internal load balancer. If not empty, this enables internal DNS for internal load balancers. By default, the service label is disabled. This has no effect on external load balancers."
  default     = null
}

variable "name_suffix" {
  description = "A name suffix to append to all resources to allow multiple deployments in the same region. For example, -fab1"
  type        = string
  default     = ""
}
