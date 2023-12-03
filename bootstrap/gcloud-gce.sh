#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export VERSION_TAG=v1.26.0

git clone https://github.com/aursu/ingress-gce.git
(cd ingress-gce && git checkout ${VERSION_TAG} -b ${VERSION_TAG})

docker-compose build  --build-arg path=$(pwd) rocky8docker

# docker run --rm --sig-proxy=true -u $(id -u):$(id -g) -v $(pwd)/.go:/go \
#     -v $(pwd):/go/src/k8s.io/ingress-gce \
#     -v $(pwd)/bin/amd64:/go/bin/linux_amd64 \
#     -v $(pwd)/.go/std/amd64:/usr/local/go/pkg/linux_amd64_static \
#     -v $(pwd)/.go/cache:/.cache/go-build \
#     -w /go/src/k8s.io/ingress-gce golang:1.20.10 \
#     /bin/sh -c "ARCH=amd64 OS=linux VERSION=v1.26.0 PKG=k8s.io/ingress-gce \
#         TARGET=bin/amd64/glbc GIT_COMMIT=bdbf2d0c054f49cc78e299b45c01b28281d64e85 ./build/build.sh"
