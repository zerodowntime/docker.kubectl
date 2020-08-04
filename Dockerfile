##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

ARG BASE_IMAGE="centos:7"

FROM $BASE_IMAGE

RUN curl -s -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq && \
    chmod +x /usr/local/bin/jq

ARG KUBECTL_VERSION="latest"

RUN if [ "$KUBECTL_VERSION" = "latest" ]; then \
      KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt); \
    fi && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

ENTRYPOINT ["/usr/local/bin/kubectl"]
CMD ["help"]
