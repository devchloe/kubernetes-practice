# Nginx ingress controller 배포

## 파일 생성
- default-backend-service deployment, service(nodeport)
- nginx-ingress-controller deployment, service(loadbalancer)
- serviceaccount, clusterrole, role, rolebinding, clusterrolebinding

## 파일 실행
- kubectl create namespace canary
- kubectl create -f default-http-backend.yaml -n canary
- minikue addons enable ingress
- kubectl create -f nginx-ingress-controller.yaml -n canary
- minikube service nginx-ingress --url
- curl http://<nginx-ingress-service-ip>:<nginx-service-nodeport>

# Refernece
- https://hackernoon.com/setting-up-nginx-ingress-on-kubernetes-2b733d8d2f45