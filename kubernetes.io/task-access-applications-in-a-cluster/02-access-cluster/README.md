클러스터 관리자나 개발자가 Kubernetes Cluster, 정확히 말하면 Master node에 작업을 요청하기 위한 방법은 크게 3가지가 있다.
- kubectl command-line tool
- REST API
- Kubernetes Dashboard

이 방법을 통해 작업자가 Master node에 작업을 요청하면 Master node 안에 있는 API-SERVER가 받는다.

API-SERVER는 이 요청이 유효(인증, 권한 등)한지 확인한 후 처리한다.

누가?? API-SERVER에게 작업을 요청하는 방법 중 위 두가지에 대해 알아본다.

### kubectl
먼저 어떤 방법을 사용하든 요청을 보낼 Master node 주소와 credential이 필요하다.

만약 Minikube를 설치했다면 Master node 주소와 credential은 자동으로 설정될 것이다.

`kubectl confing view --minify`를 통해 현재 사용중인 context를 확인할 수 있다.

kubectl을 통해 작업을 요청하면 current-context에 설정한 cluster의 Master node 내 API-SERVER가 받는다.

### REST API
Http Client(curl, wget, browers 등)를 이용해 API-SERVER의 REST API를 호출하여 작업을 요청할 수 있다.

이 때 Master node 주소와 credential을 알아내는 방법은 다음과 같다.

#### proxy 모드로 kubectl 실행 (권장)
`kubectl proxy`를 실행하면 localhost의 요청을 받아 Kubernetes Cluster 내의 API-SERVER로 요청을 전달하는 proxy server/gateway를 자동 생성한다.

```bash
$ kubectl proxy --port=8080 && 
```

localhost의 요청을 proxy server 8080 포트로 전달하고 proxy server를 백그라운드 모드로 실행시킨다.

proxy server 8080으로 전달된 요청은 원격지의 API-SERVER port로 포워딩될 것이다.

```bash
$ curl http://localhost:8080/api/
```


#### Http Client에 직접 Master node 주소와 credential을 지정하기
proxy server를 사용하지 않고 local에 저장된 Master node 주소와 credential 값을 가지고 REST API를 호출한다.

Master node 주소는 kubeconfig에 정의되어 있다.

현재 사용중인 context에 정의된 `cluster.server` 정보를 확인한다. 그리고 APISERVER 변수로 값을 저장한다.

```bash
$ kubectl config view --minify
$ echo $(kubectl config view --minify | grep server) # server: https://1.2.3.4:8443
$ APISERVER = $(kubectl config view --minify | grep server | cut -d ':' -f 2- ) # https://1.2.3.4:8443
```

credential 정보는 다음과 같이 가져올 수 있다.

전체 secret 목록 중 default로 시작되는 이름의 secket을 찾고 token을 key로 하는 값을 TOKEN 변수로 저장한다.

```bash
$ echo $(kubectl get secret | grep ^default | cut -d ' ' -f1) # default-token-xxxx
$ TOKEN = $(kubectl describe secret $(kubectl get secret | grep ^default | cut -d ' ' -f1) | grep ^token | cut -d ':' -f 2-)
```

저장한 APISERVER, TOKEN 값을 이용하여 REST API를 호출한다.

```bash
$ curl $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure
```

proxy를 이용할 때와 동일한 결과를 볼 수 있다.

```json
{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "1.2.3.4:8443"
    }
  ]
}
```
> 참고
> `cut -d [delimiter] -f [startIndex-endIndex]`는 delimiter로 문자열을 나누고 나눈 덩어리 중 몇번째부터 몇번째까지 가져올 지 결정
> Postman을 이용해서 REST API를 테스트할 때 Setting > Genereal 에서 SSL certificate verification을 끄고 한다.

위와 같이 --insecure 옵션을 사용하거나 SSL certificate verification을 끄면 MITM attack에 노출될 위험이 있다.

kubectl로 API-SERVER에 접근하는 경우에는 저장된 root certificate과 client certificate을 이용해서 인증한다.

이 인증서들은 ~/.kube 디렉토리 아래에 있다. Minikube는 ~/.minikube 디렉토리 아래에서 볼 수 있다.

- ~/miniube/ca.crt, ca.key, ca.pem 
- ~/.minikube/client.crt, client.key

cluster certificate는 일반적으로 self-signed(자체 서명) 되기 때문에 Http Client에 root certificate을 사용하도록 하는 추가 작업이 필요하다.

#### Go/Python Client Library 이용


### Worker node에 있는 Pod에서 Master node에 있는 API-SERVER 접근하기

Pod에서 API-SERVER의 위치를 찾고 인증하는 방법은 약간 다르다.

API-SERVER 주소를 찾으려면 `kubernetes.default.svc` DNS Name을 이용해서 호출한다. 그러면 이 DNS Name은 Service IP로 바껴서 apiserver로 라우팅된다.

인증받는 방법은 `service account` credential 을 이용하는 것이다.

다른 pod에 접근하려는 pod은 상대 pod에 대한 실행, 접근 권한인 service account을 가져야 한다. 이것은 kube-system에 의해 하나의 pod이 service account와 매핑된다. 그리고 service account에 대한 token도 발급된다.
이 token 정보는 pod 내에서 실행중인 container의 파일 시스템 /var/run/secrets/kubernetes.io/serviceaccount/token`으로 저장된다.

Pod 안에서 API-SERVER에 접근하는 방법 (추천)
- pod 안에 sidecar container로 `kubectl proxy`를 실행하거나 container 안에서 직접 kubectl proxy를 백그라운드 모드로 실행시킨다.
이렇게 설정하면 kubectl proxy가 localhost에서 실행되기 때문에 pod 안에서 실행중인 다른 컨테이너가 호출한 API도 proxy server를 통해서 API-SERVER에 포워딩된다.

각 케이스에서 pod의 자격증명(credential)은 API-SERVER와 안전하게 통신하는데 사용된다.

### cluster에서 실행중인 service에 접근하기

위에 내용들은 Kubernetes API-SERVER에 연결하는 방법이었다.

Cluster 안에 있는 nodes, pods, services는 자신만의 고유 IP를 가지고 있다. Cluster 안에 있는 machine 에서는 kubectl, kube prox, REST API 등을 통해 API-SERVER로 요청을 보내고 node, pod, service 에 대한 제어를 할 수 있다.

그런데 Cluster 밖에 있는 machine으로 node, pod, service를 제어할 수 없다. API-SERVER로부터 인증을 받을 수 없기 떄문에??

Public IP를 이용해서 Cluster 밖에서 Service에 접근하기 :
- NodePort나 LoadBalancer 타입의 Service를 만든다. Public IP인 NodeIP:<NodePort>로 요청을 보내면 ClusterIP로 라우팅된다. LoadBalancer Service의 <ExternalIP>로 요청을 보내면 ClusterIP:NodePort로 라우팅 된다.
- 그리고 Pod은 Service 뒤에 위치시켜서 외부에서 접근할 수 없게 한다. 만약 pod replicas 중에 pod 하나에 접근하고 싶다면 그 pod에 label을 달고 새로운 Service를 생성한다.
- 대부분의 경우 개발자가 NodeIP를 통해 직접 Node에 접근할 필요가 없어야 한다.

Cluster 안에 있는 Node와 Pod에서 접근하기:
- pod을 실행시키고 kubectl exec command를 사용하면 pod 안에서 shell을 사용할 수 있다. 그 shell에서 다른 nodes, pods, services에 연결한다.

TODO: 그림으로 표현해보자.

