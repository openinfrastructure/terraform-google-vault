# Vault IAM Policies

This nested module manages IAM policies which are expected to have a long
lifecycle separate from the ephemeral compute resources.

The policies grant the vault-server service account access to the backed data
bucket and KMS key.  Additionally the vault-admin service account is granted
access to the terraform state bucket used to manage vault.
