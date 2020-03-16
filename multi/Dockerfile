##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

ARG KUBECTL_VERSION="latest"

FROM zerodowntime/kubectl:$KUBECTL_VERSION

COPY kubectl-multi-exec.sh /usr/local/bin/kubectl-multi-exec
COPY kubectl-multi-push.sh /usr/local/bin/kubectl-multi-push

ENTRYPOINT ["/usr/local/bin/kubectl"]
CMD ["help"]
