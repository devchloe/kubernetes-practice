# Configure Access to Multiple Clusters
[link](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)

여러 개의 cluster, namespace를 운영하고 서로 다른 user 인증정보를 이용하는 경우에 이러한 정보를 하나의 kubeconfig 파일로 생성해두면 context를 쉽게 전환할 수 있다.

클러스터들의 정보를 정의한 `kubeconfig` 파일을 만들고 clusters, users, contexts 정보를 작성한다.

`kubectl config use-context [CONTEXT_NAME]` 커맨드를 통해서 cluster를 스위칭한다. 그 전에 cluster에 접근하려면 인증을 받아야 한다.

## kubeconfig 파일 생성
kubeconfig 파일은 clusters, users, contexts 정보를 담고 있는 설정 파일이다.

`kubectl config --kubeconfig=[configuration file]` 옵션을 이용해서 kubeconfig 파일을 생성한다.

이 때 clusters, users, contexts 상세정보를 셋팅하기 위해서 `set-cluster`, `set-credentials`, `set-context` 서브커맨드와 추가 옵션들을 이용한다.

`config-demo` 라는 이름으로 kubeconfig 파일을 생성하고 clusters, users, contexts를 설정해보자.

### clusters, users, contexts 요구조건

### clusters 상세설정
cluster 주소와 접근권한을 설정한다.
```bash
$ kubectl config --kubeconfig=config-demo set-cluster develpment --server=https://$(minikube ip) --certificate-autority=fake-ca-file
$ kubectl config --kubeconfig=config-demo set-cluster scratch --server=https://$(minikube ip) --insecure-skip-tls-verify
```

### users 상세설정
user별로 인증방법(credential)을 정의한다.
`developer` 라는 user는 `key/cert-file` 방식으로 인증한다.
`experimenter` 라는 user는 `username/password` 방식으로 인증한다.
```bash
$ kubectl config --kubeconfig=config-demo set-credentials developer --client-certificate=fake-cert-file --client-key=fake-key-seefile
$ kubectl config --kubeconfig=config-demo set-credentials experimenter --username=exp --password=some-password
```

### contexts 상세설정
cluster 안에서 resource들을 서로 다른 namespace로 구분할 수 있는데 context 개념은 cluster + namespace 조합으로 cluster 안에 namespace를 가리키는 별칭이다.

`dev-frontend` context는 `development` cluster 안에 `frontend` namespace에 접근하려면 `developer`로 정의한 credential이 있어야 접근할 수 있다.

```bash
$ kubectl config --kubeconfig=config-demo set-context dev-frontend --cluster=development --namespace=frontend --user=developer
$ kubectl config --kubeconfig=config-demo set-context dev-storage --cluster=development --namespace=storage --user=developer
$ kubectl config --kubeconfig=config-demo set-context exp-scratch --cluster=scratch --namespace=default --user=experimenter
```

### kubeconfig 파일 확인
`kubectl config --kubeconfig=config-demo view`를 통해 설정된 clusters, users, contexts 정보를 확인할 수 있다.


### kubeconfig 파일에 current-context 설정 및 확인
아래와 같이 current-context를 설정하면 실행하는 `kubectl` command는 currnet-context가 바라보는 cluster와 namespace에 적용되고 user에 정의한 credential을 이용할 것이다.
```bash
$ kubectl config --kubeconfig=config-demo use-context dev-frontend
$ kubectl config --kubeconfig=config-demo current-context
$ kubectl config --kubeconfig=config-demo view --minify # current-context 정보만 출력한다, --minify는 subcommand view의 flag
```

다른 context로 스위칭하려면 위와 동일하게 `use-context` 서브커맨드를 이용하여 current-context를 바꿔주면 된다.

## KUBECONFIG 환경변수 사용하기
여러 개의 kubeconfig 파일이 있을 때 이것을 하나의 정보로 합칠 수 있다.

`dev-ramp-up` 이라는 context를 가진 config-demo-2 파일을 생성하고 `KUBECONFIG` 라는 환경변수에 `:`으로 kubeconfig 파일 경로를 지정해준다.

```bash
$ vi config-demo-2
$ export KUBECONFIG_SAVED=$KUBECONFIG
$ export KUBECONFIG=$KUBECONFIG:config-demo:config-demo-2
$ kubectl config view
```

## $HOME/.kube 디렉토리
kubectl이 어떤 클러스터와 통신하고 있다면 `$HOME/.kube` 디렉토리에 `config` 파일이 존재할 것이다.

이 파일을 열어보면 clusters, users, contexts 정보가 있는 것을 알 수 있다.

이 파일도 `KUBECONFIG` 환경변수에 추가해보자.

```bash
$ export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config
$ kubectl config view
```

`KUBECONFIG` 환경변수를 초기화하자.

```bash
$ export KUBECONFIG=$KUBECONFIG_SAVED
```

### 참고

### kubectl config의 다른 commands: `kubectl config current-context`
