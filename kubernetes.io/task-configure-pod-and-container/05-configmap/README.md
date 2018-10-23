## Pod이 왜 ConfigMap을 써야할까?

Pod 실행에 필요한 application configuration 데이터를 ConfigMap에 저장해놓기 위해서 사용한다.

application configuration 데이터나 파일은 docker image를 빌드할 때 소스로 같이 포함할 수도 있다.

하지만 configuration 내용이 바뀌면 docker image를 다시 빌드해야하기 때문에 이식성이 떨어진다.

그리고 application configuration 데이터를 Kubernetes Pod에서 분리할 수 있다는 장점이 있다.

Pod은 언제든 사라지고 새로 만들어질 수 있기 때문에 Pod 안에 configuration 데이터를 포함하고 있다면 재사용성이 떨어진다.

그래서 Pod을 정의할 때 Application 실행에 필요한 데이터를 ConfigMap에 저장된 데이터를 참조해서 환경변수 등으로 정의하고 Container에 노출시킨다.

Pod에서 ConfigMap을 참조하도록 설정하는 방법은 두가지가 있다.

- configMap + env
- configMap + volume

## ConfigMap 데이터를 어떻게 Pod이 쓸 수 있을까? - 1

### 먼저 ConfigMap에 Application 데이터를 저장해놓아야 한다

- ConfigMap을 생성하고 데이터를 저장하는 방법

생성 Syntax: kubectl create configmap <configmap-name> <application-configuration-data-source>
조회 Syntax: kubectl get configmap <configmap-name> -o yaml or kubectl describe configmap <configmap-name>

- application-configuration-datasource를 정의하는 방법은 세가지가 있다.
저장할 데이터를 어디서 가져올지 정의한다.

Syntax: kubectl create configmap <configmap-name> --from-literal=key1=value1
kubectl create configmap <configmap-name> --from-file=dir/file1.yaml --from-file=dir/file2.yaml (파일 여러개를 하나의 configmap으로 저장하는 경우 예시)
kubectl create configmap <configmap-name> --from-file=dir/
kubectl create configmap <configmap-name> --from-env-file=dir/file.yaml

--from-literal: 문자열을 이용해서 데이터를 저장
--from-file: 파일 안에 담긴 내용을 저장, 파일명이 key가 된다, 이때 파일명이 아닌 다른 key로 저장하려면 <key>=<path-to-file>로 작성
--from-file: directory 안에 있는 파일들의 내용을 저장, 파일명이 key가 된다, 이때 파일명이 아닌 다른 key로 저장하려면 <key>=<path-to-file>로 작성
--from-env-file: 파일 안에 담긴 내용만 가지고 key=value로 직접 저장, 여러 --from-env-file을 사용하는 경우 가장 마지막에 작성한 file의 내용만 남는다.

configmap에 데이터는 항상 key:value로 저장된다.

key: 문자열, 파일명
value: 문자열, 파일 내용

### Container에서 사용할 환경변수를 Pod spec에 정의한다.
환경변수 값은 생성한 ConfigMap을 참조한다.
Pod spec에서 정의하는 내용은 환경변수를 ConfigMap으로부터 어떻게 로드할지를 결정한다.

다음을 실행해보고 Pod log를 확인한다.

Syntax: ConfigMap에서 하나의 entry를 가져오는 경우
```yaml
env:
- name: <Container에서 사용하는 환경변수 이름>
  valueFrom:
    configMapKeyRef:
      name: <참조할 configmap-name>
      key: <참조할 entry-key>
```
데이터 형태:
```
data:
  allowed: '"true"'
  enemies: aliens
  lives: "3"
```

Syntax: ConfigMap에 있는 여러 entry를 한번에 가져오는 경우, configmaMap 자체를 참조한다.
이 경우 환경변수 이름은 별도로 지정하지 않기 때문에 entry key가 환경변수 이름이 된다.
```yaml
envFrom:
- configMapRef:
    name: <참조할 configmap-name1>
- configMapRef:
    name: <참조할 configmap-name2> 
```
데이터 형태:
```
data:
  allowed: '"true"'
  enemies: aliens
  lives: "3"
```


### Pod spec에 정의한, Container에게 노출시킨 환경변수를 Container 안에서 사용해보자

Syntax:       command: [ "/bin/sh", "-c", "echo $(SPECIAL_LEVEL_KEY) $(SPECIAL_TYPE_KEY)" ]

or kubectl exec -it <pod-name> -c <container-name> bash

데이터 형태:
```
data:
  allowed: '"true"'
  enemies: aliens
  lives: "3"
```


## ConfigMap 데이터를 어떻게 Pod이 쓸 수 있을까? - 2
ConfigMap에 저장한 데이터를 Volume으로 만들어서 Pod이 마운트한 경로에 ConfigMap 데이터를 추가하도록 한다.

과정은
- ConfigMap 생성
- Pod spec 작성

containers:
- name: test-container
  volumeMounts:
  - name: config-volume
    mountPath: /etc/config
volumes:
- name: <volume-name>
  configMap:
    name: <configmap-name>

entry 수만큼 마운트 경로에 텍스트 파일이 생성된다.
entry key를 파일명으로 마운트 경로에 텍스트 파일이 생성된다.

entry 마다 생성되는 파일의 위치를 특정한 마운트 경로의 서브 경로로 지정할 수 있다.

items에 선언한 entry만 마운트경로/서브경로에 생성된다.

Syntax:

containers:
- name: test-container
  volumeMounts:
  - name: config-volume
    mountPath: /etc/config
volumes:
- name: config-volume
  configMap:
    name: special-config
    items:
    - key: special.level
      path: keys
      
실행:    
cat /etc/config/keys 

환경변수로 정하면 컨테이너가 생성된 후 변경할 수 없다.
볼륨을 사용하면 컨테이너 실행 중에도 언제든지 configuration 데이터를 수정할 수 있다.

kubelet이 주기적으로 마운트한 ConfigMap을 감시하고 변경사항을 체크하기 때문에 ConfigMap 데이터를 변경하면 마운트 패스에서 심볼릭링크를 변경한다.
갱신되기까지는 일정한 시간이 소요(kubelet sync period + ttl of ConfigMaps cache) 된다.

### 기타
ConfigMap은 namespace level에 만들어지기 때문에 Pod이 참조하는 ConfigMap은 같은 namespace에 있어야 한다.

Tutorial: https://kubernetes.io/docs/tutorials/configuration/configure-redis-using-configmap/

Concept:
https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod