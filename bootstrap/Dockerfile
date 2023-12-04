ARG rocky=8.8.20230518
ARG image=docker-cli
FROM aursu/rockylinux:${rocky}-${image}

ARG path=/project

COPY system/etc/yum.repos.d/google-cloud-sdk.repo /etc/yum.repos.d/google-cloud-sdk.repo
COPY system/etc/yum.repos.d/kubernetes.repo /etc/yum.repos.d/kubernetes.repo

RUN set -ex \
	&& microdnf -y install \
		google-cloud-cli \
		kubectl \
	    make \
	&& microdnf clean all && rm -rf /var/cache/dnf /var/lib/rpm/__db*

COPY ingress-gce $path/ingress-gce
WORKDIR $path/ingress-gce

CMD make only-push-glbc
