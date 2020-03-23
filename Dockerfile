FROM bash:5
WORKDIR /app

ARG DOCTL_VERSION=1.39.0
ARG ANSIBLE_VERSION=2.9.6

# Install tools
RUN set -xe \
  && apk add --update --no-cache --progress \
  bind-tools \
  ca-certificates \
  curl \
  docker-cli \
  git \
  jq \
  make \
  nmap \
  openssh \
  openssl \
  py3-pip \
  python3 \
  sshpass \
  tar \
  unzip \
  zip \
  && pip3 install yq

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
