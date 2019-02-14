FROM bash:5

RUN set -xe \
    && apk add --no-cache py3-pip jq curl \
    && pip3 install yq
