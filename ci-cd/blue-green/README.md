# Deployment Strategy - Blue-Green Deployment

Why Blue-Green Deployment important?
- zero-downtime during deployment
- decrease risk for deploying new features

## Blue-Green Deployement Scenario

- 이미 운영 중인 Pod/Application: Blue
- 새로 릴리즈할 Pod/Application: Green

1. Green을 통해 서비스할 준비를 마친 상태에서
2. Router/LoadBalancer의 upstream 목적지를 Green으로 변경한다
3. Blue는 지우거나 남겨둔다. 남기는 이유는 나중에 Rollback 상황을 대비하여

## Blue-Green Deployment's yaml file

1. kubectl create namespace ci-cd
2. kubectl create -f blue-nginx-deployment.yaml
3. kubectl create -f nginx-service.yaml (selector label: nginx, 1.10)
4. EXTERNAL_IP=$(kubectl get svc nginx -o jsonpath="{.status.loadBalancer.ingress[*].ip}")
curl -s http://$EXTERNAL_IP/version | grep nginx

or curl -s http://$(minikube ip):$(kubectl get svc nginx -n ci-cd -o jsonpath="{.spec.ports[*].nodePort"})/version | grep nginx

결과: nginx/1.10.3

5. kubectl create -f green-nginx-deployment.yaml
6. change nginx-service.yaml 
```
spec:
  selector:
    name: nginx
    version: "1.11"
```

7. kubectl apply -f nginx-service.yaml

8. EXTERNAL_IP=$(kubectl get svc nginx -o jsonpath="{.status.loadBalancer.ingress[*].ip}")
curl -s http://$EXTERNAL_IP/version | grep nginx

or curl -s http://$(minikube ip):$(kubectl get svc nginx -n ci-cd -o jsonpath="{.spec.ports[*].nodePort"})/version | grep nginx

결과: nginx/1.11.13

## Prerequisites

Required:
- **Pod labels 와 Service selector 값이 같고 version을 label로 포함해야 한다.** : Router/LoadBalancer가 upstream 목적지를 스위칭하는 기준이 되기 때문
- Deployment name은 `Service name-version` 이어야 한다. (Deployment가 잘 배포되었는지 확인하기 위한 기준으로 사용, Deployment의 각 버전을 구별할 수 있는 기준값이 있어야 함)

- Docker image를 Git hash로 태깅하고 spec에 version을 Git hash값으로 지정하는 것도 좋은 방법

## 5~7 과정 자동화
1. sh blue-green-deployement.sh <namespace> <service-name> <new-version> <new-deployment-file-path>

Example:
sh blue-green-deployement.sh ci-cd nginx 1.11 green-nginx-deployment.yaml

`nginx` Service를 `1.11` 버전으로 `ci-cd` 네임스페이스에 새롭게 배포함

배포되는 어플리케이션은 `green-nginx-deployment.yaml`에 Deployment로 정의되어 있음



## Rolling update??


## Reference 
- https://www.ianlewis.org/en/bluegreen-deployments-kubernetes
- https://codefresh.io/kubernetes-tutorial/fully-automated-blue-green-deployments-kubernetes-codefresh/