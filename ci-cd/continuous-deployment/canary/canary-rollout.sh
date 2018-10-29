#!/bin/bash

# canary-rollout.sh <namespace> <stable-deployment-name> <container-name> <image> <stable-pod-replicas> <canary-deployment-name-to-be-deleted>
# Deployment name should be <service>-<release>

#CONTEXT=$1
NAMESPACE=$1
STABLE_DEPLOYMENT_NAME=$2
CONTAINER_NAME=$3
IMAGE=$4
STABLE_POD_REPLICAS=$5
CANARY_DEPLOYMENT_NAME=$6

STABLE_VERSION=$(kubectl get deployment ${STABLE_DEPLOYMENT_NAME} -n ${NAMESPACE} -o json | jq '.spec.template.spec.containers[] | select(.name == "nginx") | .image' | tr -d '"')
echo "Before RollingUpdate, stable version: ${STABLE_VERSION}"

kubectl set image deployment ${STABLE_DEPLOYMENT_NAME} -n ${NAMESPACE} ${CONTAINER_NAME}=${IMAGE} --record
kubectl scale deployment ${STABLE_DEPLOYMENT_NAME} -n ${NAMESPACE} --replicas=${STABLE_POD_REPLICAS}
kubectl delete deployment ${CANARY_DEPLOYMENT_NAME} -n ${NAMESPACE}

kubectl get pod -n ${NAMESPACE}

STABLE_VERSION=$(kubectl get deployment ${STABLE_DEPLOYMENT_NAME} -n ${NAMESPACE} -o json | jq '.spec.template.spec.containers[] | select(.name == "nginx") | .image' | tr -d '"')
echo "After RollingUpdate, stable version: $STABLE_VERSION"