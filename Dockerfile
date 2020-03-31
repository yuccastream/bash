FROM bash:5
WORKDIR /app

ARG DOCTL_VERSION=1.39.0
ARG ANSIBLE_VERSION=2.9.6
ARG KUBECTL_VERSION=v1.17.2
ARG KUSTOMIZE_VERSION=3.5.4
ARG HELM_VERSION=3.1.2

# Install tools
RUN set -xe \
  && apk add --no-cache --progress \
  bind-tools \
  ca-certificates \
  curl \
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
  docker-cli \
  tar \
  unzip \
  zip \
  && curl https://rclone.org/install.sh | bash \
  && pip3 install yq awscli --upgrade

# Install DigitalOcean cli tool
RUN set -xe \
  && mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
  && curl -L https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz  | tar xz \
  && mv ./doctl /usr/local/bin/

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

# Install KUBECTL KUSTOMIZE HELM
LABEL io.kubectl.version="${KUBECTL_VERSION}"
LABEL io.kustomize.version="${KUSTOMIZE_VERSION}"
LABEL io.helm.version="${HELM_VERSION}"

RUN set -xe \
  && curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && curl -sL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz  | tar -zx \
  && curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -zx --strip-components=1 \
  && cp helm  /usr/local/bin/helm \
  && cp kustomize  /usr/local/bin/kustomize \
  && rm -f * \
  && chmod +x /usr/local/bin/kubectl /usr/local/bin/kustomize /usr/local/bin/helm

RUN rm -f /var/cache/apk/*
