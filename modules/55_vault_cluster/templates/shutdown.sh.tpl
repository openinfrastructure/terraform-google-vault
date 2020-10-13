#! /bin/bash
#
# This script uses the 30 second shutdown window on preemption to block traffic
# from the load balancer health check while still processing any outstanding
# requests.  Additionally, the active role is given up.

# TODO: Execute vault operator step-down after authenticating.

# Make the loadbalancer health check fail
iptables -A INPUT -p tcp --dport 8210 -j REJECT
# Sleep 20 seconds to finish processing any outsntanding requests.  The vault
# service will be stopped after the google-shutdown-service.
sleep 20
