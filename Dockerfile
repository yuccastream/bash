FROM bash:5
WORKDIR /app

ARG ANSIBLE_VERSION=2.9.12
ARG DOCTL_VERSION=1.56.0
ARG HCLOUD_VERSION=v1.20.0
ARG HELM_VERSION=3.5.0
ARG KUBECTL_VERSION=v1.19.6
ARG KUSTOMIZE_VERSION=3.9.1
ARG NOMAD_VERSION=1.0.3
ARG VAULT_VERSION=1.6.1

LABEL io.ansible.version="${ANSIBLE_VERSION}"
LABEL io.doctl.version="${DOCTL_VERSION}"
LABEL io.hcloud.version="${HCLOUD_VERSION}"
LABEL io.helm.version="${HELM_VERSION}"
LABEL io.kubectl.version="${KUBECTL_VERSION}"
LABEL io.kustomize.version="${KUSTOMIZE_VERSION}"
LABEL io.nomad.version="${NOMAD_VERSION}"
LABEL io.vault.version="${VAULT_VERSION}"

# Install tools
RUN set -xe \
  && apk add --no-cache --progress \
  bind-tools \
  ca-certificates \
  curl \
  docker-cli \
  ffmpeg \
  git \
  gnupg \
  jq \
  make \
  nmap \
  openssh \
  openssl \
  py3-pip \
  python3 \
  sshpass \
  tar \
  tree \
  unzip \
  zip \
  && curl https://rclone.org/install.sh | bash \
  && pip3 install --upgrade pip setuptools \
  && pip3 install yq j2cli j2cli[yaml]

# Install DigitalOcean cli tool
RUN set -xe \
  && mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
  && curl -L https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz  | tar -xz \
  && mv ./doctl /usr/local/bin/


# Install hetzner cloud cli tool
RUN set -xe \
  && curl -L https://github.com/hetznercloud/cli/releases/download/${HCLOUD_VERSION}/hcloud-linux-amd64.tar.gz | tar -xz \
  && mv ./hcloud /usr/local/bin/

# Install Ansible
RUN set -xe \
  && echo "****** Install system dependencies ******" \
  && apk --update add --virtual build-dependencies \
  python3-dev libffi-dev openssl-dev build-base \
  \
  && echo "****** Install ansible and python dependencies ******" \
  && pip3 install --upgrade pip \
  && pip3 install ansible==${ANSIBLE_VERSION} boto3 \
  \
  && echo "****** Remove unused system librabies ******" \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /etc/ansible \
  && echo -e "[local]\nlocalhost ansible_connection=local" > \
  /etc/ansible/hosts

# Install Vault
RUN set -xe \
  && curl -sSL -O https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
  && unzip vault_${VAULT_VERSION}_linux_amd64.zip \
  && mv ./vault /usr/local/bin/ \
  && rm -f vault_${VAULT_VERSION}_linux_amd64.zip

# Install Nomad
RUN set -xe \
  && curl -sSL -O https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip \
  && unzip nomad_${NOMAD_VERSION}_linux_amd64.zip \
  && mv ./nomad /usr/local/bin/ \
  && rm -f nomad_${NOMAD_VERSION}_linux_amd64.zip

# Install KUBECTL KUSTOMIZE HELM
RUN set -xe \
  && curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && curl -sL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz  | tar -zx \
  && curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -zx --strip-components=1 \
  && cp helm  /usr/local/bin/helm \
  && cp kustomize  /usr/local/bin/kustomize \
  && rm -f * \
  && chmod +x /usr/local/bin/kubectl /usr/local/bin/kustomize /usr/local/bin/helm

RUN rm -f /var/cache/apk/*
