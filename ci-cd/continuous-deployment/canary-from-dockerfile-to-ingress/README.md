# Stable Deployment 배포

## 파일 생성
- server.js
- Dockerfile
- deployment.yaml

## 파일 실행
- export app_version=1.0
- docker build --build-arg version=$app_version -t devchloe/app:$app_version .
- docker push devchloe/app:$app_version
- kubectl create namespace
- kubectl apply -f
- kubectl rollout status deployment/<name>
- kubectl get pod -o wide
- kubectl get events -w

```
         +------------------+ 
         | devchloe/app:1.0 |                                                
    +---+|------------------|+---+ 
    |    +-------Pod1-------+    |
    |                            |
    |    +------------------+    |
    |    | devchloe/app:1.0 |    |    +--------------+     +--------------+
    +---+|------------------|+---+---+|  ReplicaSet  |+---+|  Deployment  |
    |    +-------Pod2-------+    |    +--------------+     +--------------+
    |                            |
    |    +------------------+    | 
    |    | devchloe/app:1.0 |    |                                                 
    +---+|------------------|+---+ 
        +-------Pod3-------+
```
# LoadBalancer 배포

## 파일 생성
- service.yaml

## 파일 실행
- kubectl apply -f
```
                                          +------------------+ 
                                          | devchloe/app:1.0 |     
                                     +---+|------------------| 
                                     |    +-------Pod1-------+
                                     |    
                                     |    +------------------+
                +---------------+    |    | devchloe/app:1.0 | 
Internet +--->  | Load Balancer |+---+---+|------------------|
                +---------------+    |    +-------Pod2-------+
                                     |
                                     |    +------------------+ 
                                     |    | devchloe/app:1.0 | 
                                     +---+|------------------| 
                                          +-------Pod3-------+
```

# Canary Deployment 배포

## 파일 생성
- server.js
- Dockerfile
- deployment.yaml

## 파일 실행
- export app_version=1.0
- docker build --build-arg version=$app_version -t devchloe/app:$app_version .
- docker push devchloe/app:$app_version
- kubectl apply -f
- kubectl get pod -o wide

```
                                          +------------------+ 
                                          | devchloe/app:1.0 |            
                                     +---+|------------------|+---+ 
                                     |    +-------Pod1-------+    |
                                     |                            |
                                     |    +------------------+    |
                                     |    | devchloe/app:1.0 |    |   +--------------+     +--------------+
                                     +---+|------------------|+---+---|  ReplicaSet  |+---+|  Deployment  |
                +---------------+    |    +-------Pod2-------+    |   +--------------+     +--------------+
Internet +--->  | Load Balancer |+---|                            |
                +---------------+    |    +------------------+    |
                                     |    | devchloe/app:1.0 |    |
                                     +---+|------------------|+---+
                                     |    +-------Pod3-------+
                                     | 
                                     |    +------------------+ 
                                     |    | devchloe/app:2.0 |        +--------------+     +--------------+ 
                                     +---+|------------------|+-------|  ReplicaSet  |+---+|  Deployment  | 
                                          +-------Pod4-------+        +--------------+     +--------------+                                     

```

# Ingress 배포

Why?
Canary 릴리즈 버전에 직접 접속하고 싶은 경우 호스트 네임을 Stable 버전과 나눈다.
특히 Canary 릴리즈 버전을 운영환경에서 테스트하려는 경우 실제 사용자가 접근하고 있는 Stable 버전에 영향을 주지 않도록 하는 방법이다.

## 파일 생성
- stable version deployment, service(nodeport)
- Ingress
- nginx ingress controller (자세한 내용은 ingress/nginx/README.md 참조)
- canary version deployment, service(nodeport)

## 파일 실행
- export app_version=1.0
- docker build --build-arg version=$app_version -t devchloe/app:$app_version .
- docker push devchloe/app:$app_version
- kubectl create namespace
- kubectl apply -f app-stable.yaml
- kubectl rollout status deployment/<name>
- kubectl get pod -o wide
- kubectl get events -w
- kubectl create -f app-ingress-production.yaml
- kubectl describe ingress
- sudo vi /etc/hosts
- kubectl create -f nginx-ingress-controller.yaml
- curl -v http://api.sample.com
- kubectl create -f app-canary.yaml
- kubectl create -f app-ingress-canary.yaml
   - host 추가 (name-based virtual hosting)
- sudo vi /etc/hosts
- curl -v http://api.sample.com
- curl -v http://canary.api.sample.com


```
                                                                                          +------------------+ 
                                                                                          | devchloe/app:1.0 |            
                            |                           |                       +--> +---+|------------------|+---+ 
                            |                           |                       |    |    +-------Pod1-------+    |
                            |                           |                       |    |                            |
                            |                           |                       |    |    +------------------+    |
                            |                           |                       |    |    | devchloe/app:1.0 |    |   +--------------+     +--------------+
       api.sample.com +---> |                           |---> stable-service 80 |--> +---+|------------------|+---+---|  ReplicaSet  |+---+|  Deployment  |
                            |     +---------------+     |                       |    |    +-------Pod2-------+    |   +--------------+     +--------------+
                            |     |   Ingress IP  |     |                       |    |                            |
                            |     +---------------+     |                       |    |    +------------------+    |
                            |                           |                       |    |    | devchloe/app:1.0 |    |
                            |                           |                       +--> +---+|------------------|+---+
                            |                           |                            |    +-------Pod3-------+
                            |                           |                            | 
                            |                           |                            |    +------------------+ 
                            |                           |                            |    | devchloe/app:2.0 |        +--------------+     +--------------+ 
canary.api.sample.com +---> |                           |---> canary-service 80 ---> +---+|------------------|+-------|  ReplicaSet  |+---+|  Deployment  | 
                            |                           |                                 +-------Pod4-------+        +--------------+     +--------------+                                     

```

# 모니터링


# 레퍼런스
- https://blog.dockbit.com/kubernetes-canary-deployments-for-mere-mortals-6696910a52b2