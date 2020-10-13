# Vault KMS Key Ring

The Vault keyring is used to initialize vault and encrypt the unseal keys.
This keyring is persistent and separated out into it's own module so that Vault
compute resources can be ephemeral.

This allows the key ring to persist when the compute resources go through a
destroy / apply cycle.
