#!/bin/bash

##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

if [ $# -lt 1 ]; then
  >&2 echo "Usage: ${0##*/} payload [ARG1] [ARG2] ... [ARGN]"
  # >&2 echo "Usage: ${0##*/} payload-dir payload-bin [ARG1] [ARG2] ... [ARGN] #TODO"
  exit 1
fi

if [ -z ${KUBECTL_NAMESPACE} ]; then
  >&2 echo "KUBECTL_NAMESPACE is not defined!"
  exit 1
fi
if [ -z ${KUBECTL_SELECTOR} ]; then
  >&2 echo "KUBECTL_SELECTOR is not defined!"
  exit 1
fi
if [ -z ${KUBECTL_CONTAINER} ]; then
  >&2 echo "KUBECTL_CONTAINER is not defined! The first container in the pod will be chosen."
  # exit 1
fi

if [ ! -f $1 ]; then
  >&2 echo "PAYLOAD ($1) does not exists!"
  exit 1
fi
PAYLOAD_FILE=$(realpath "$1")
shift

debug() {
  echo "##" "$@" "##"
}

JOBID=$(uuidgen)
PODS_LIST=$(kubectl get pods --namespace "$KUBECTL_NAMESPACE" --selector "$KUBECTL_SELECTOR" -o=custom-columns=NAME:.metadata.name --no-headers)

## Here be dragons.
org=("$@"); set --
for var in "${org[@]}"; do
  if [[ "$var" == \$* ]]; then
    set -- "$@" "$(printenv "${var#$}")"
  else
    set -- "$@" "$var"
  fi
done

debug "Running job $JOBID"

if [ -n "$KUBECTL_PAYLOAD_RUN_ONCE" ]; then
  debug "Limit execution on the first host only."
  PODS_LIST=$(echo "$PODS_LIST" | head -n1)
fi

debug "1/3 Deploying payload to containers.."
for POD_NAME in $PODS_LIST; do
  debug "$POD_NAME"
  kubectl cp "$PAYLOAD_FILE" "$KUBECTL_NAMESPACE/$POD_NAME:/tmp/$JOBID" --container "$KUBECTL_CONTAINER" --no-preserve || exit 2
done
wait

debug "2/3 Running payload script.."
for POD_NAME in $PODS_LIST; do
  if [ -n "$KUBECTL_PAYLOAD_PARALLEL" ]; then
    kubectl exec --stdin --namespace "$KUBECTL_NAMESPACE" "$POD_NAME" --container "$KUBECTL_CONTAINER" -- "/tmp/$JOBID" "$@" 2>&1 | awk -v prefix="$POD_NAME" '{ print prefix, $0 }' &
  else
    debug "$POD_NAME"
    kubectl exec --stdin --namespace "$KUBECTL_NAMESPACE" "$POD_NAME" --container "$KUBECTL_CONTAINER" -- "/tmp/$JOBID" "$@" || exit 2
  fi
done
wait

debug "3/3 Cleaning up.."
for POD_NAME in $PODS_LIST; do
  debug "$POD_NAME"
  kubectl exec --stdin --namespace "$KUBECTL_NAMESPACE" "$POD_NAME" --container "$KUBECTL_CONTAINER" -- rm "/tmp/$JOBID"
done
wait

debug "DONE!"
