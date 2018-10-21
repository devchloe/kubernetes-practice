# 여러 클러스터에 있는 리소스에 접근하기 위한 설정

## Summary
여러 클러스터, 네임스페이스에 접근해야 한다면 kubeconfig 파일을 만들자.

### Syntax
```bash
$ kubectl config --kubeconfig=<kubecofnig-file-name> [sub-commands]
$ export KUBECONFIG=$KUBECONFIG[:<kubeconfig-file-path>]
$ export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config
```

### How to Work
여러 개의 cluster, namespace를 운영하고 서로 다른 user 인증정보를 이용하는 경우에 이러한 정보를 하나의 kubeconfig 파일로 생성해두면 context를 쉽게 전환할 수 있다.

클러스터들의 정보를 정의한 `kubeconfig` 파일을 만들고 clusters, users, contexts 정보를 작성한다.

`kubectl config use-context [CONTEXT_NAME]` 커맨드를 통해서 cluster를 스위칭한다. 그 전에 cluster에 접근하려면 인증을 받아야 한다.

+ 인증에 관한 이야기 추가 

## Expectations
```
WHO     어플리케이션 개발자가
WHERE   로컬 머신에서
WHEN    여러 클러스터에서 실행 중인 리소스를 접근해야 할 때
```

## Benefits

원하는 cluster, namespace, 적절한 인증방법을 context로 미리 정의해둠으로써 서로 다른 클러스터에 있는 리소스에 쉽고 빠르게 접근할 수 있다.

## Getting Started

### Execution Scenario
1. kubeconfig 파일 이름 정의
2. 접근할 clusters 설정
3. 사용자별 인증방법을 users로 설정
4. cluster, namespace, user를 매핑하는 contexts 설정
5. KUBECONFIG 환경변수에 kubeconfig 파일을 지정하여 `kubectl config view`로 모아보기
6. 기존에 통신하던 클러스터 설정파일도 KUBECONFIG 환경변수에 추가

실행 결과:
`kubectl config use-context`를 이용해서 접근하고자 하는 리소스가 있는 클러스터, 네임스페이스로 전환이 자유롭다.

### Prerequisites
- kubectl-cli
- kubernetes cluster (Minikube, ..)

## Running
- Create Kubeconfig file
- Configure Clusters, Users, Contexts
- Export KUBECONFIG environment variable
- Add $HOME/.kube/config to KUBECONFIG environment variable

### Create Kubeconfig file
kubeconfig 파일은 clusters, users, contexts 정보를 담고 있는 설정 파일이다.

#### kubeconfig 파일 생성

```bash
$ vi config-demo-framwork.yaml
```
config-demo-framework.yaml:
```yaml
apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
  name: development
- cluster:
  name: scratch

users:
- name: developer
- name: experimenter

contexts:
- context:
  name: dev-frontend
- context:
  name: dev-storage
- context:
  name: exp-scratch
```

위와 같은 기본 프레임워크를 먼저 만들고 `kubectl config --kubeconfig=[configuration file]`을 이용해서 clusters, users, contexts를 상세 설정할 수도 있다.

clusters, users, contexts 상세정보를 설정하기 위해서 `set-cluster`, `set-credentials`, `set-context` 서브커맨드와 추가 옵션들을 이용한다.

`config-demo` 라는 이름으로 kubeconfig 파일을 생성하고 clusters, users, contexts를 설정해보자.

### Configure Clusters, Users, Contexts

#### clusters 상세설정
cluster 주소와 접근권한을 설정한다.
```bash
$ kubectl config --kubeconfig=config-demo set-cluster develpment --server=https://$(minikube ip) --certificate-autority=fake-ca-file
$ kubectl config --kubeconfig=config-demo set-cluster scratch --server=https://$(minikube ip) --insecure-skip-tls-verify
```

#### users 상세설정
user별로 인증방법(credential)을 정의한다.
`developer` 라는 user는 `key/cert-file` 방식으로 인증한다.
`experimenter` 라는 user는 `username/password` 방식으로 인증한다.
```bash
$ kubectl config --kubeconfig=config-demo set-credentials developer --client-certificate=fake-cert-file --client-key=fake-key-seefile
$ kubectl config --kubeconfig=config-demo set-credentials experimenter --username=exp --password=some-password
```

#### contexts 상세설정
cluster 안에서 resource들을 서로 다른 namespace로 구분할 수 있는데 context 개념은 cluster + namespace 조합으로 cluster 안에 namespace를 가리키는 별칭이다.

`dev-frontend` context는 `development` cluster 안에 `frontend` namespace에 접근하려면 `developer`로 정의한 credential이 있어야 접근할 수 있다.

```bash
$ kubectl config --kubeconfig=config-demo set-context dev-frontend --cluster=development --namespace=frontend --user=developer
$ kubectl config --kubeconfig=config-demo set-context dev-storage --cluster=development --namespace=storage --user=developer
$ kubectl config --kubeconfig=config-demo set-context exp-scratch --cluster=scratch --namespace=default --user=experimenter
```

#### kubeconfig 파일 생성 결과 확인

```bash
$ kubectl config --kubeconfig=config-demo view
```

#### kubeconfig 파일에 current-context 설정 및 확인
아래와 같이 current-context를 설정하면 실행하는 `kubectl` command는 currnet-context가 바라보는 cluster와 namespace에 적용되고 user에 정의한 credential을 이용할 것이다.
```bash
$ kubectl config --kubeconfig=config-demo use-context dev-frontend
$ kubectl config --kubeconfig=config-demo current-context
$ kubectl config --kubeconfig=config-demo view --minify # current-context 정보만 출력한다, --minify는 subcommand view의 flag
```

다른 context로 스위칭하려면 위와 동일하게 `use-context` 서브커맨드를 이용하여 current-context를 바꿔주면 된다.

### Export KUBECONFIG environment variable

여러 개의 kubeconfig 파일이 있을 때 이것을 하나의 정보로 합칠 수 있다.

`dev-ramp-up` 이라는 context를 가진 config-demo-2 파일을 생성하고 `KUBECONFIG` 라는 환경변수에 `:`으로 kubeconfig 파일 경로를 지정해준다.

#### export KUBECONFIG 실행 

```bash
$ vi config-demo-2
$ export KUBECONFIG_SAVED=$KUBECONFIG
$ export KUBECONFIG=$KUBECONFIG:config-demo:config-demo-2
```
#### export KUBECONFIG 실행 결과 확인
```bash
$ kubectl config view
```

### Add $HOME/.kube/config to KUBECONFIG environment variable

#### $HOME/.kube 디렉토리 확인
kubectl이 어떤 클러스터와 통신하고 있다면 `$HOME/.kube` 디렉토리에 `config` 파일이 존재할 것이다.

이 파일을 열어보면 clusters, users, contexts 정보가 있는 것을 알 수 있다.

이 파일도 `KUBECONFIG` 환경변수에 추가해보자.

#### $HOME/.kube/config 파일 추가

```bash
$ export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config
```

#### 모든 kubeconfig 파일 설정 확인
```bash
$ kubectl config view
```

`KUBECONFIG` 환경변수를 초기화하자.

```bash
$ export KUBECONFIG=$KUBECONFIG_SAVED
```

## References
- https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
