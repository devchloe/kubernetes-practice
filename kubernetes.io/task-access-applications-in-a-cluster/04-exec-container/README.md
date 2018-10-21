# 실행중인 컨테이너에서 쉘 명령어 수행

## Summary

### Syntax
```bash
$ kubectl exec -it <pod-name> -- <commands>
$ kubectl exec <pod-name> -- <command>
$ kubectl exec <pod-name> -c <container-name> -- <commands>
```

### How to Work

## Expectations
```
WHO     어플리케이션 개발자가
WHERE   -
WHEN    컨테이너에 쉘 명령어를 실행하거나 실행 로그를 보고자 할 때
```

## Getting Started

### Architecture
```
    internet   <--- $kubectl exec
  ------|------
     [ Pod ]
        |
 [ Container1 Shell, Container2 Shell, ... ]
```

### Execution Scenario
1. Pod 생성
2. Container가 정상적으로 실행중인지 확인 
3. 실행중인 Container Shell에 접속하거나 접속하지 않고 Shell command 실행
4. Pod에 여러 Container가 실행중인 경우 특정 Container에 Shell command 실행 

### Prerequisites
- kubectl-cli
- kubernetes cluster (Minikube, ..)

## Running

### Pod 생성

```bash
$ kubectl create -f shell-demo.yaml
$ kubectl get pods shell-demo
```

### Container Shell 접속
```bash
$ kubectl exec -it shell-demo -- /bin/bash
root@shell-demo:/# apt-get update
root@shell-demo:/# apt-get install -y lsof
root@shell-demo:/# lsof
root@shell-demo:/# apt-get install -y procps
root@shell-demo:/# ps aux
root@shell-demo:/# ps aux | grep nginx
root@shell-demo:/# apt-get install -y curl
root@shell-demo:/# curl localhost
root@shell-demo:/# echo Hello shell demo > /usr/share/nginx/html/index.html
root@shell-demo:/# curl localhost
Hello shell demo
```
### Container Shell에서 command 하나씩 실행
Container Shell에 들어가지 않고 Container Shell에 커맨드를 실행할 수 있다.

```bash
$ kubectl exec shell-demo env # 실행중인 컨테이너에 설정된 환경변수 조회
$ kubectl exec shell-demo ps aux
```

### Pod에 하나 이상의 Container가 실행 중일 때 Shell 접속
```bash
$ kubectl exec -it my-pod -c web-server -- /bin/bash
```

## References
- https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/