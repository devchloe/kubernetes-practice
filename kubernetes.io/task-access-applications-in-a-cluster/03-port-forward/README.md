# Use Port Forwarding to Access Applications in a Cluster

### Summary

#### Syntax

```bash
$ kubectl port-forward <service, pod, deployement name> <local-port>:<remote-port> <options>
```

#### Port Forwarding 동작
`kubectl port-forward`를 사용해서 local port를 Kubernetes service, pod, deployment에 매핑할 수 있다. 어디에 매핑하든 관계없이 local port로 들어온 요청(패킷)은 최종적으로 Pod으로 라우팅된다. 

```
                127.0.0.1
                  :6379
                    |
                internet
--------------------|-----------------------
                 1.2.3.4
                  :6379
       [ Service, Pod, Deployment ]
                    |
  Pod selected by Service, Pod, Deployment
```

##### ip 지정없이 어떻게 이름만으로 요청이 전달될까?
`kubectl port-forward`를 실행하면 다음과 같은 요청을 api-server에게 보낸다.
`POST /api/v1/namespaces/{namespace}/pods/{name}/portforward`

그리고 커맨드로 전달한 `<local-port>:<remote-port> `목록으로 local과 destination 간에 WebSocket을 생성한다.

https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#-strong-proxy-operations-pod-v1-core-strong-


### Expectations

**WHO**     어플케이션 개발자가
**WHERE**   로컬 개발 환경에서
**WHEN**    클러스터 외부로 노출되지 않은 database와 같은 백앤드 서비스를 테스트하거나 디버깅하고자 할 때

### Benefits

테스트, 디버깅할 때 로컬 머신에서 접속하기 위해 굳이 Service를 만들 필요가 없다.

로컬 머신에 설치된 어플리케이션을 사용하는 것처럼 리모트 Pod에서 실행 중인 어플리케이션을 로컬 머신에서 접속하고 조작, 테스트할 수 있다.

```bash
$ kubectl port-forward svc/redis-master 6379:6379
$ redis-cli set chloe kwon
```

데이터베이스를 예로 들자면, 아래처럼 굳이 컨테이너 안에 접속해서 데이터를 조회할 필요가 없다.

```bash
$ kubectl exec redis-master-xxx redis-cli get chloe
```

port-forward를 제대로 사용할 줄 모를 때에는 로컬 머신에서 ssh로 Kubernetes node에 직접 접속해서 작업하고 테스트 했었다. 로컬 머신에서 kubeconfig를 정의하고 current-context를 설정한 후 port-forward 했으면 되었을텐데..

### Getting Started

#### 아키텍처
```
    internet   <--- $kubectl port-forward, $redis-cli ping
  ------|------
  [ Services ]
        |
    [ Pods ]
        |
 [ ReplicaSet ]
        |
 [ Deployment ]
```

#### 실행 시나리오
먼저 Pod Replicas를 생성하고 Pod Replicas의 단일 지점 역할을 하는 Service를 만든다.

클러스터 밖에서 Redis Server Pod에 접속하고 작업을 실행할 수 있도록 여러 리소스 중 하나를 Port Forwarding 방식으로 노출시킨다. 

만약 노출시키지 않은 상태에서 로컬에서 redis-cli를 실행하면 기본으로 120.0.0.1:6379로 연결을 시도하기 때문에  pod 안에 들어가서 redis-cli를 통해 데이터를 조작하지 않고 로컬에서 redis-cli로 작업하려면 port forwarding이나 NodePort/Loabbalancer type Service를 만들어 노출시켜야 한다.

**Pod에 포트 포워딩을 해도 되는데..Service를 만들어야 하는 이유?**
여러 Pod replicas가 만들어지고 Service로 그룹화해서 관리할테니까..

결과적으로 local workstation에서 Pod에서 실행중인 Redis Server에 붙어서 디버깅을 수행할 수 있다.

pod, replicaset, service의 label을 모두 똑같이 설정 - 
**app: redis, role: master, tier: backend**

```bash
$ kubectl get pods --show-labels | grep redis 
$ kubectl get rs --show-labels | grep redis
$ kubectl get deployment --show-labels | grep redis
```

### Prerequisites
- kubectl-cli
- kubernetes cluster (Minikube, ..)
- redis-cli

```bash
$ brew install redis
$ redis-cli
```

### STEP1. Redis Deployment 생성
Deployment는 Pod을 직접 관리하지 않고 ReplicaSet을 추가로 생성하여 관리한다.

```bash
$ kubectl create -f redis-master-deployment.yaml
```

redis-master-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-master
  labels:
    app: redis
spec:                   # -- 이하는 Deployment의해 생성되는 ReplicaSet과 Pod 정의
  selector:
    matchLabels:
      app: redis
      role: master
      tier: backend
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
        role: master
        tier: backend
    spec:
      containers:
      - name: master
        image: k8s.gcr.io/redis:e2e
        ports:
        - containerPort: 6379
```

```bash
$ kubectl get pods
$ kubectl get deployment redis-master
$ kubectl get rs
$ echo 'Pod' $(kubectl describe pods $(kubectl get po | grep ^redis-master | cut -f1 -d ' ') | grep -E 'Controlled By' | cut -f1 -d '/') $(kubectl describe rs $(kubectl get rs | grep ^redis-master | cut -f1 -d ' ') | grep -E 'Controlled By' | cut -f1 -d '/') $(kubectl describe deployment $(kubectl get deployment | grep redis-master | cut -f1 -d ' ') | grep -E 'Controlled By' | cut -f1 -d '/')
```

### STEP2. Redis Service 생성

```bash
$ kubectl create -f redis-master-service.yaml
$ kubectl get svc | grep redis 
$ kubectl get pods <redis pod name> --template='{{(index (index .spec.containers 0).ports 0).containerPort}} {{"\n"}}' # Redis Server listening port 확인 
```

현재까지 만들어진 Redis 리소느는 다음과 같다. 
- Pod
- ReplicaSet
- Deployment
- Service

Deployment를 제외한 나머지 리소스는 동일한 label을 포함한다.

현재 클러스터 밖에 있는 머신에서 `redis-cli`를 수행하면 Connecion refused가 발생한다.

### STEP3. Port Forwarding

`kubectl port-forward <service name|pod name|..>`을 이용하면 이름과 매칭하는 Pod을 찾고 local port를 container port로 포워딩한다.

```bash
$ kubectl port-forward <redis pod name> 6379:6379
$ kubectl port-forward pods/<redis pod name> 6379:6379
$ kubectl port-forward deployment/redis-master 6379:6379
$ kubectl port-forward rs/<redis replicaset name> 6379:6379
$ kubectl port-forward svc/redis-master 6379:6379
```

Port Forwarding을 수행하면 local port로 클러스터 안에서 실행중인 Redis Server Pod에 접속할 수 있다.
위 5가지 command 중 어떤 것을 수행하더라도 label selector에 의해 Service, ReplicaSet -> Redis Server Pod, Deployment -> ReplicaSet -> Redis Server Pod으로 라우팅된다.

```bash
$ redis-cli # local port 6379와 Pod에서 실행중인 Redis Server port 6379로 TCP Connection을 맺는다.
> ping
Pong
> set chloe kwon
> get chloe
kwon
```

### 비교
kubectl proxy, kubectl port-forward is more generic as it can forward TCP traffic while kubectl proxy can only forward HTTP traffic.

### Ref
Kubernetes in action Part2. 9장