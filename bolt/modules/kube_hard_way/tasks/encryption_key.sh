#!/bin/bash

# Error if non-root
if [ $(id -u) -ne 0 ]; then
    echo "kube_hard_way::encryption_key task must be run as root"
    exit 1
fi

if [ -n "$PT_force" ]; then
    force=$PT_force
else
    force=0
fi

export PATH="/usr/local/bin:$PATH"

if [ -f /var/lib/kubernetes/enc.key ]; then
    export ENCRYPTION_KEY=$(cat /var/lib/kubernetes/enc.key)
else
    export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
    echo -n $ENCRYPTION_KEY > /var/lib/kubernetes/enc.key

    if [ $force -ne 0 ] && yq -V 2>/dev/null 1>&2 && test -f /var/lib/kubernetes/encryption-config.yaml; then
        yq -i ".resources[0].providers[0].aescbc.keys[0].secret = \"$ENCRYPTION_KEY\"" /var/lib/kubernetes/encryption-config.yaml
    fi
fi

echo "{\"key\":\"$ENCRYPTION_KEY\"}"

exit 0