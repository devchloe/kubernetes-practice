#!/bin/bash

# blue-green-deployment.sh <namespace> <servicename> <new-version> <new-deployment-file-path>
# Deployment name should be <service>-<version> -- Green Deployment Pod 준비되어 있는지 확인

#CONTEXT=$1
NAMESPACE=$1
SERVICE_NAME=$2
NEW_VERSION=$3
NEW_DEPLOYMENT_FILE_PATH=$4

echo "Starting green deployement."

#kubectl config use-context $KUBE_CONTEXT
export OLD_VERSION=$(kubectl get svc ${SERVICE_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.selector.version}')
echo "Blue version is ${OLD_VERSION}."
#deploy new version? yes or no

kubectl apply -f $NEW_DEPLOYMENT_FILE_PATH

jq --version
if [ $? -eq 0 ];then
    echo "Jq alreay installed."
else
    echo "Start to install Jq."
    brew install jq
fi

READY=$(kubectl get deployment ${SERVICE_NAME}-${NEW_VERSION} -n ${NAMESPACE} -o json | jq '.status.conditions[] | select(.reason == "MinimumReplicasAvailable") | .status' | tr -d '"')

while [ "$READY" != "True" ]
do
    READY=$(kubectl get deployment ${SERVICE_NAME}-${NEW_VERSION} -n ${NAMESPACE} -o json | jq '.status.conditions[] | select(.reason == "MinimumReplicasAvailable") | .status' | tr -d '"')
    sleep 5
done

echo "Deployment has minimum availability."


kubectl patch svc $SERVICE_NAME -n $NAMESPACE -p "{\"spec\": {\"selector\": {\"name\": \"${SERVICE_NAME}\", \"version\": \"${NEW_VERSION}\"}}}"
#kubectl delete deployment $SERVICE_NAME-$OLD_VERSION -n $NAMESPACE
echo "Request Testing: "
echo $(curl -s http://$(minikube ip):$(kubectl get svc nginx -n ci-cd -o jsonpath="{.spec.ports[*].nodePort"})/version | grep nginx)
echo "Done."