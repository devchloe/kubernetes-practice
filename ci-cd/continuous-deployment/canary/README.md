# Deployment Strategy - Canary Deployment

Why Canary Deployment important?
- fail-fast
- feature, performace, etc. verification
- 빅이슈가 예상되는 경우, 새로운 피쳐를 일정 유저를 대상으로 테스트해보고 싶은 경우
- 트래픽을 새로운 버전으로 점차 늘려가면서 배포하는 방법

- 대체재: Istio/ Helm을 사용할 수도 있다.
- Istio를 이용하면 클러스터 안에서 traffic을 규칙에 따라 원하는대로 분배할 수 있다. Istio는 canary 배포를 위한 완벽한 기능을 제공하는데 그 이유는 pod 수와 관계없이 들어오는 트래픽을 비율로 나눌 수 있기 때문이다. 그럼 traffic 비율을 조정하기 위해서 pod을 추가 생성할 필요없기 때문에 자원도 효율적으로 쓸 수 있겠지..

## vs Blue/Green deployments
- 여러 버전이 함께 트래픽을 받을 수 있다.
- 그렇기 때문에 sticky session mechanism을 이용하지 않는다면 하나의 session이 여러 request를 보낼 때 어떤 것은 stable server에서 어떤 것은 canary server에서 처리될 수 있다.

이 두가지가 보장될 수 없다면 Blue/Geren 배포가 훨씬 더 안전한 배포 방법이다.

## Canary Deployement Scenario

- 이미 운영 중인 Pod/Application: Stable
- 새로 릴리즈할 Pod/Application: Canary

1. 트래픽을 Stable과 Canary 버전으로 어느 비율로 나눌지 결정하고 그에 따라 Stable 버전의 replicas 수를 줄인다. 
예를 들어 stable:canary = 90%:10% traffic을 원한다면 최소 stable version pod이 9개 존재해야 한다.

2. 즐인 replicas 수만큼 Canary 버전의 Deployment를 생성한다.

! 이 때 주의할 것은 Service는 변경하지 않기 때문에 Service에 지정한 selector에 Canary 버전이 포함될 수 있도록 Canary Pod의 label을 작성해야 한다.

3. Canary 버전이 안정적이라고 생각되면 점차 Canary 버전의 replicas 수를 늘리고 Stable 버전의 replicas 수를 줄인다.

! 이 때 Stable을 Canary로 완전히 대체하는 방법은 Stable Deployment의 image만 바꿔서 배포하는 것이다. 이 때 Pod label이 바껴서는 안된다. 왜냐하면 Stable Deployment에 의해 생성된 Stable ReplicaSet Controller는 관리할 Pod을 선택할 때 label 기준으로 선택하고 Pod의 label을 감시하다가 달라지면 관리 대상에서 제외시켜 버리기 때문이다.

그리고 다른 방법으로 완전히 Stable을 삭제하고 Canary를 재생성할수도 있는데 이것은 downtime이 발생하며 기존에 배포하던 방식, 프로세스를 모두 종료하고 재배포하는 것과 동일하다.

4. 완전히 Canary 버전으로 대체 가능하다면 Canary 버전의 Deployment만 유지한다. 

## Canary Deployment's yaml file

1. kubectl create -f canary-namespace.yaml
2. kubectl create -f step0/stable-nginx-deployment.yaml
3. kubectl create -f nginx-service.yaml (selector label: nginx)
4. EXTERNAL_IP=$(kubectl get svc nginx -n canary -o jsonpath="{.status.loadBalancer.ingress[*].ip}")
curl -s http://$EXTERNAL_IP/version | grep nginx

or curl -s http://$(minikube ip):$(kubectl get svc nginx -n canary -o jsonpath="{.spec.ports[*].nodePort"})/version | grep nginx

결과: nginx/1.10.3

5. 
a. kubectl create -f step1/canary-nginx-deployment.yaml

b. kubectl patch deployment nginx-stable -n canary -p '{"spec":{"replicas":2}}'
or kubectl apply -f step1/stable-nginx-deployment.yaml

6. stable/canary 개수 확인
echo $(kubectl get deployment nginx-stable -n canary -o jsonpath='{.spec.replicas}')

echo $(kubectl get deployment nginx-canary -n canary -o jsonpath='{.spec.replicas}')

7. 4번 재실행
결과: nginx/1.10.3 >> nginx/1.11.13

8. 5-7 반복
결과: nginx/1.10.3 << nginx/1.11.13

9. kubectl apply -f step3/canary-nginx-deployment.yaml
결과: ngnginx/1.11.13

10. kubectl delete deployment nginx-canary -n canary



======================

## 다른 방법
단순히 v1 deployment를 생성하고 운영하다가 v2 deployment replicas를 1로 운영하고 지켜본다.
v2 deployment replicas를 `kubectl scale --replicas=10 deploy app-v2`로 replicas를 올린 후 v1을 delete한다.

## log
결과 분석:
마지막 9를 실행하면 nginx-stable Deployment의 RollingUpdate가 일어나면서 마지막 남은 nginx:1.10 버전이 자연스럽게 종료된다. 그리고 이미지 버전을 1.11로 바꿨기 때문에 자연스럽게 replicas 수만큼 nginx:1.11 pod이 생성된다. 




## 5~7 과정 자동화
1. sh blue-green-deployment.sh <namespace> <service-name> <new-version> <new-deployment-file-path>

sh canary-deployment.sh <namespace> <service-name> <canary-deployment-file-path> <stable-deployment-name> <stable-replicas>
optional: stable-deployment-name, stable-replicas






Example:
sh blue-green-deployement.sh blue-green nginx 1.11 green-nginx-deployment.yaml

`nginx` Service를 `1.11` 버전으로 `blue-green` 네임스페이스에 새롭게 배포함

배포되는 어플리케이션은 `green-nginx-deployment.yaml`에 Deployment로 정의되어 있음



## Rolling update??


## Reference 
- https://hackernoon.com/canary-release-with-kubernetes-1b732f2832ac

## TODO
- AWS에서 Canary deployment or A/B test 환경 꾸리기
