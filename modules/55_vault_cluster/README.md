# Vault Cluster

This module manages the minimum compute resources to achieve a HA Vault Cluster
in GCP.  The primary design goal is to enable the cluster to be ephemeral while
persisting the API address, vault data, TLS certificates, and auto-unseal KMS
keyring.

Design goals are:

 * [ ] Destroy and re-create the resources in this module with minimal impact
   to operations.
 * [ ] Quick boot time to enable fast rolling upgrades and HA recovery
 * [ ] Preemptible instance support with hand-off of active role to a standby
 * [ ] Auto healing

Auto-scaling is explicitly not a design goal at this time.
