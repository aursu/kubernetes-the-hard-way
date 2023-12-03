ARG rocky=8.8.20230518
ARG image=docker-cli
FROM aursu/rockylinux:${rocky}-${image}

ARG path=/project

RUN set -ex \
	&& microdnf -y install \
	    make \
	&& microdnf clean all && rm -rf /var/cache/dnf /var/lib/rpm/__db*

COPY ingress-gce $path/ingress-gce
WORKDIR $path/ingress-gce
