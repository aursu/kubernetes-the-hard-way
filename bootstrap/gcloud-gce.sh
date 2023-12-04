#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export VERSION_TAG=v1.26.0

[ -d ingress-gce ] && rm -rf ingress-gce
git clone https://github.com/aursu/ingress-gce.git

(cd ingress-gce && git checkout ${VERSION_TAG} -b ${VERSION_TAG})
(cd ingress-gce && git ls-remote --exit-code --heads origin refs/heads/${VERSION_TAG} \
    && git pull origin refs/heads/${VERSION_TAG})

docker-compose build --build-arg path=$(pwd) rocky8docker
docker-compose run -ti --rm \
    -v $(pwd)/ingress-gce/bin/amd64:$(pwd)/ingress-gce/bin/amd64 \
    -v ~/.docker/config.json:/root/.docker/config.json rocky8docker
