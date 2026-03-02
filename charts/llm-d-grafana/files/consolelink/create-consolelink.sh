#!/bin/bash

set -ex

ROUTE=$(oc get route -n grafana grafana-route -ojsonpath='{.status.ingress[0].host}')
export ROUTE

cat << EOF | oc apply -f-
$(cat /mnt/consolelink.yaml.tpl)
  href: https://${ROUTE}/
EOF
