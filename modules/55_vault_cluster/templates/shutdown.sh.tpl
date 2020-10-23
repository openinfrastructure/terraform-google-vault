#! /bin/bash
#
# This script uses the 30 second shutdown window on preemption to block traffic
# from the load balancer health check while still processing any outstanding
# requests.  Additionally, the active role is given up.

export PATH="/usr/local/bin:$${PATH}"

# Make the loadbalancer health check fail
iptables -A INPUT -p tcp --dport 8210 -j REJECT

export VAULT_ADDR="http://127.0.0.1:8200"

# Get the service account email
service_account="$(curl -sf -H Metadata-Flavor:Google metadata/computeMetadata/v1/instance/service-accounts/default/email)"
domain="$${service_account##*@}"
project="$${domain%%.*}"

# Login to vault using the vault-server google service account.
vault login -method=gcp \
    role="step-down" \
    service_account="$${service_account}" \
    project="$${project}" \
    jwt_exp="15m"

# Hand off the active role to the other node in the cluster
vault operator step-down

# Sleep 20 seconds to finish processing any outsntanding requests.  The vault
# service will be stopped after the google-shutdown-service.
sleep 20
