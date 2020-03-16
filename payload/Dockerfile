##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

ARG KUBECTL_VERSION="latest"

FROM zerodowntime/kubectl:$KUBECTL_VERSION

ENV KUBECTL_NAMESPACE=
ENV KUBECTL_SELECTOR=
ENV KUBECTL_CONTAINER=

ENV KUBECTL_PAYLOAD_RUN_ONCE=
ENV KUBECTL_PAYLOAD_PARALLEL=

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/kubectl-payload.sh"]
