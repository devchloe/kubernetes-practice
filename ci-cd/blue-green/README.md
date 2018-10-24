# Blue-Green Deployment

## Blue-Green Deployement Scenario

- 이미 운영 중인 Pod: Blue
- 새로 릴리즈할 Pod: Green

1. Green을 통해 서비스할 준비를 마친 상태에서
2. Router를 Green으로 변경하한다
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

## 5~7 과정 자동화
1. sh blue-green-deployement.sh <namespace> <service-name> <new-version> <new-deployment-file-path>

<service-name> Service를 <new-version> 버전으로 <namespace> 네임스페이스에 새롭게 배포함

배포되는 어플리케이션은 <new-deployment-file-path>에 Deployment로 정의되어 있음

## Rolling update??


## Reference 
- https://www.ianlewis.org/en/bluegreen-deployments-kubernetes