#!/bin/bash

# canary-deployment.sh <namespace> <canary-deployment-file-path> <stable-deployment-name> <stable-pod-replicas>
# Deployment name should be <service>-<release>

#CONTEXT=$1
NAMESPACE=$1
CANARY_DEPLOYMENT_FILE_PATH=$2
STABLE_DEPLOYMENT_NAME=$3
STABLE_POD_REPLICAS=$4

kubectl apply -f ${CANARY_DEPLOYMENT_FILE_PATH}
kubectl scale deployment/${STABLE_DEPLOYMENT_NAME} -n ${NAMESPACE} --replicas=${STABLE_POD_REPLICAS}

kubectl get pod -n ${NAMESPACE}