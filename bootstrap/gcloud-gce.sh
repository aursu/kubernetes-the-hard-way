#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export VERSION_TAG=v1.26.0

# cleanup
[ -d ingress-gce ] \
    && docker-compose run --rm \
        -v $(pwd)/ingress-gce:$(pwd)/ingress-gce \
        -w $(pwd)/ingress-gce rocky8cleanup rm -rf bin .go \
    && rm -rf ingress-gce

# setup
git clone https://github.com/aursu/ingress-gce.git

# update
(cd ingress-gce && git checkout ${VERSION_TAG} -b ${VERSION_TAG})
(cd ingress-gce && git ls-remote --exit-code --heads origin refs/heads/${VERSION_TAG} \
    && git pull origin refs/heads/${VERSION_TAG})

docker-compose build --build-arg path=$(pwd) rocky8docker

# build docker image
docker-compose run --rm \
    -v $(pwd)/ingress-gce/bin/amd64:$(pwd)/ingress-gce/bin/amd64 \
    -v ~/.docker/config.json:/root/.docker/config.json rocky8docker

docker-compose run --rm -v $(pwd):$(pwd) -w $(pwd) \
    -v ~/.config/gcloud:/root/.config/gcloud \
    -v ~/.kube/config:/root/.kube/config \
    rocky8docker ./gcloud-gce-conf.sh

docker-compose run --rm -v $(pwd):$(pwd) -w $(pwd) \
    -v ~/.config/gcloud:/root/.config/gcloud \
    -v ~/.kube/config:/root/.kube/config \
    rocky8docker ./gcloud-iam.sh