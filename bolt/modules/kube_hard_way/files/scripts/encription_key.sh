#!/bin/bash

if [ -f /var/lib/kubernetes/enc.key ]; then
    export ENCRYPTION_KEY=$(cat /var/lib/kubernetes/enc.key)
else
    export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
    echo -n $ENCRYPTION_KEY > /var/lib/kubernetes/enc.key

    if yq -V 2>/dev/null 1>&2 && test -f /var/lib/kubernetes/encryption-config.yaml; then
        yq -i ".resources[0].providers[0].aescbc.keys[0].secret = \"$ENCRYPTION_KEY\"" /var/lib/kubernetes/encryption-config.yaml
    fi
fi
