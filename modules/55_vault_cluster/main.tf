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

locals {
  service_account_email = var.service_account_email == null ? "vault-server@${var.project_id}.iam.gserviceaccount.com" : var.service_account_email
  api_addr              = var.api_addr == null ? "https://${var.vault_cluster_address}:${var.vault_port}" : var.api_addr
  vault_tls_bucket      = var.vault_tls_bucket == null ? var.vault_storage_bucket : var.vault_tls_bucket
  vault_kms_key_tls     = var.vault_kms_key_tls == null ? var.vault_kms_key_init : var.vault_kms_key_tls

  # Vault needs these broken down
  # vault_kms_keyring: projects/v6-vault-f295/locations/us-west1/keyRings/vault-9f1f
  vault_kms_key_init_project   = split("/", var.vault_kms_key_init)[1]
  vault_kms_key_init_location  = split("/", var.vault_kms_key_init)[3]
  vault_kms_key_init_keyring   = split("/", var.vault_kms_key_init)[5]
  vault_kms_key_init_cryptokey = split("/", var.vault_kms_key_init)[7]

  # TLS values
  vault_kms_key_tls_project   = split("/", local.vault_kms_key_tls)[1]
  vault_kms_key_tls_location  = split("/", local.vault_kms_key_tls)[3]
  vault_kms_key_tls_keyring   = split("/", local.vault_kms_key_tls)[5]
  vault_kms_key_tls_cryptokey = split("/", local.vault_kms_key_tls)[7]

  # Internal or External load balancer is supported, but not both at once.
  lb_scheme         = upper(var.load_balancing_scheme)
  use_internal_lb   = local.lb_scheme == "INTERNAL"
  use_external_lb   = local.lb_scheme == "EXTERNAL"
  # LB and Autohealing health checks have different behavior.  The load
  # balancer shouldn't route traffic to a secondary vault instance, but it
  # should consider the instance healthy for autohealing purposes.
  # See: https://www.vaultproject.io/api-docs/system/health
  hc_workload_request_path = "/v1/sys/health?uninitcode=200"
  hc_autoheal_request_path = "/v1/sys/health?uninitcode=200&standbyok=true"

  # Health Check intervals for load balancer health checks.  These are
  # intentionally more agressive then auto-healing health checks.
  check_interval_sec  = 5
  timeout_sec         = 2
  healthy_threshold   = 1
  unhealthy_threshold = 2

  # Default to all zones in the region unless zones were provided.
  zones = length(var.zones) > 0 ? var.zones : data.google_compute_zones.available.names
}

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance_template" "vault" {
  project      = var.project_id
  region       = var.region
  name_prefix  = "${var.name_prefix}${var.name_suffix}"
  machine_type = var.machine_type
  tags         = var.vault_instance_tags
  labels       = var.vault_instance_labels

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  disk {
    source_image = var.vault_instance_base_image
    type         = "PERSISTENT"
    disk_type    = var.disk_type
    mode         = "READ_WRITE"
    boot         = true
    auto_delete  = true
    disk_size_gb = var.disk_size_gb
  }

  service_account {
    email  = local.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = merge(
    var.vault_instance_metadata,
    {
      "google-compute-enable-virtio-rng" = "true"
      "startup-script"                   = data.template_file.vault-startup-script.rendered
      "shutdown-script"                  = data.template_file.vault-shutdown-script.rendered
    },
  )

  scheduling {
    preemptible       = var.preemptible
    automatic_restart = var.preemptible ? false : true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "vault-startup-script" {
  template = file("${path.module}/templates/startup.sh.tpl")

  vars = {
    # Vars passed to startup script
    config                  = data.template_file.vault-config.rendered
    service_account_email   = local.service_account_email
    vault_args              = var.vault_args
    vault_port              = var.vault_port
    vault_version           = var.vault_version
    vault_tls_bucket        = local.vault_tls_bucket
    vault_ca_cert_filename  = var.vault_ca_cert_filename
    vault_tls_key_filename  = var.vault_tls_key_filename
    vault_tls_cert_filename = var.vault_tls_cert_filename
    http_proxy              = var.http_proxy

    vault_kms_key_tls_project = local.vault_kms_key_tls_project
    vault_kms_key_tls         = local.vault_kms_key_tls
    user_startup_script       = var.user_startup_script
  }
}

data "template_file" "vault-shutdown-script" {
  template = file("${path.module}/templates/shutdown.sh.tpl")
}

data "template_file" "vault-config" {
  template = file(format("%s/templates/config.hcl.tpl", path.module))

  vars = {
    # Vars passed to vault config file
    api_addr                                 = local.api_addr
    vault_kms_key_init_project               = local.vault_kms_key_init_project
    vault_kms_key_init_location              = local.vault_kms_key_init_location
    vault_kms_key_init_keyring               = local.vault_kms_key_init_keyring
    vault_kms_key_init_cryptokey             = local.vault_kms_key_init_cryptokey
    vault_storage_bucket                     = var.vault_storage_bucket
    vault_cluster_address                    = var.vault_cluster_address
    vault_port                               = var.vault_port
    vault_log_level                          = var.vault_log_level
    vault_tls_disable_client_certs           = var.vault_tls_disable_client_certs
    vault_tls_require_and_verify_client_cert = var.vault_tls_require_and_verify_client_cert
    vault_ui_enabled                         = var.vault_ui_enabled
  }
}

############################
## Internal Load Balancer ##
############################

resource "google_compute_health_check" "ilb" {
  count   = local.use_internal_lb ? 1 : 0
  project = var.project_id
  name    = "vault-ilb${var.name_suffix}"

  check_interval_sec  = local.check_interval_sec
  timeout_sec         = local.timeout_sec
  healthy_threshold   = local.healthy_threshold
  unhealthy_threshold = local.unhealthy_threshold

  https_health_check {
    port         = var.vault_port
    request_path = local.hc_workload_request_path
  }
}

resource "google_compute_region_backend_service" "vault_internal" {
  count         = local.use_internal_lb ? 1 : 0
  project       = var.project_id
  name          = "vault${var.name_suffix}"
  region        = var.region
  health_checks = [google_compute_health_check.ilb[0].self_link]

  backend {
    group = google_compute_region_instance_group_manager.vault.instance_group
  }
}

resource "google_compute_forwarding_rule" "ilb" {
  count                 = local.use_internal_lb ? 1 : 0
  project               = var.project_id
  name                  = "vault-ilb${var.name_suffix}"
  region                = var.region
  ip_protocol           = "TCP"
  ip_address            = var.vault_cluster_address
  load_balancing_scheme = local.lb_scheme
  network_tier          = "PREMIUM"
  allow_global_access   = true
  subnetwork            = var.subnetwork
  service_label         = var.service_label
  backend_service       = google_compute_region_backend_service.vault_internal[0].self_link
}

############################
## External Load Balancer ##
############################

resource "google_compute_http_health_check" "elb" {
  count   = local.use_external_lb ? 1 : 0
  project = var.project_id
  name    = "vault-elb${var.name_suffix}"

  check_interval_sec  = local.check_interval_sec
  timeout_sec         = local.timeout_sec
  healthy_threshold   = local.healthy_threshold
  unhealthy_threshold = local.unhealthy_threshold
  # This port aligns with the http only listener in the config.hcl file.
  port                = 8210
  request_path        = local.hc_workload_request_path
}

resource "google_compute_target_pool" "vault" {
  count   = local.use_external_lb ? 1 : 0
  project = var.project_id

  name   = "vault${var.name_suffix}"
  region = var.region

  health_checks = [google_compute_http_health_check.elb[0].name]
}

resource "google_compute_forwarding_rule" "elb" {
  count   = local.use_external_lb ? 1 : 0
  project = var.project_id

  name                  = "vault-elb${var.name_suffix}"
  region                = var.region
  ip_address            = var.vault_cluster_address
  ip_protocol           = "TCP"
  load_balancing_scheme = local.lb_scheme
  network_tier          = "PREMIUM"
  port_range            = "1-65535"
  target                = google_compute_target_pool.vault[0].self_link
}

############################
## Managed Instance Group ##
############################

resource "google_compute_health_check" "autoheal" {
  project = var.project_id
  name    = "vault-health-autoheal${var.name_suffix}"

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 2

  https_health_check {
    port         = var.vault_port
    request_path = local.hc_autoheal_request_path
  }
}

resource "google_compute_region_instance_group_manager" "vault" {
  project                   = var.project_id
  name                      = "vault${var.name_suffix}"
  region                    = var.region
  base_instance_name        = "vault${var.name_suffix}"
  distribution_policy_zones = local.zones
  target_size               = var.num_instances
  wait_for_instances        = false

  auto_healing_policies {
    health_check      = google_compute_health_check.autoheal.id
    initial_delay_sec = var.hc_initial_delay_secs
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_unavailable_fixed = 0
    max_surge_fixed       = length(local.zones)
    min_ready_sec         = var.min_ready_sec
  }

  target_pools = local.use_external_lb ? [google_compute_target_pool.vault[0].self_link] : []

  named_port {
    name = "vault-ui"
    port = 443
  }

  named_port {
    name = "vault-api"
    port = var.vault_port
  }

  ## Update safely with:
  # REGION=us-west1
  # MIG="$(gcloud compute instance-groups managed list --format='value(name)')"
  # TEMPLATE="$(gcloud compute instance-groups managed describe $MIG" --region=us-west1 --format='value(instanceTemplate)')"
  # gcloud compute instance-groups managed rolling-action \
  #   start-update $MIG --version template=$TEMPLATE \
  #   --region=$REGION --max-unavailable 1
  version {
    instance_template = google_compute_instance_template.vault.self_link
    name              = "active"
  }
}
