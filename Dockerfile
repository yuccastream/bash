FROM bash:5

RUN set -xe \
    && apk add --no-cache py-pip3 jq \
    && pip3 install yq
