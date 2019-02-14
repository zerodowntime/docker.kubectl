#!/bin/bash

##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

if [ $# -lt 1 ]; then
  >&2 echo "Usage: ${0##*/} COMMAND [ARG1] [ARG2] ... [ARGN]"
  exit 1
fi

if [ -z ${KUBECTL_NAMESPACE+ok} ]; then
  >&2 echo "KUBECTL_NAMESPACE is not defined!"
  exit 1
fi
if [ -z ${KUBECTL_SELECTOR+ok} ]; then
  >&2 echo "KUBECTL_SELECTOR is not defined!"
  exit 1
fi
if [ -z ${KUBECTL_CONTAINER+ok} ]; then
  >&2 echo "KUBECTL_CONTAINER is not defined! The first container in the pod will be chosen."
  # exit 1
fi

for POD_NAME in $(kubectl get pods --namespace "$KUBECTL_NAMESPACE" --selector "$KUBECTL_SELECTOR" --output=name); do
  echo "## ${POD_NAME#pod/}"
  kubectl exec --stdin --namespace "$KUBECTL_NAMESPACE" "${POD_NAME#pod/}" --container "$KUBECTL_CONTAINER" -- "$@" || exit 2
done
