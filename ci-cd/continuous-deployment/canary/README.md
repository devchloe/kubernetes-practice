# Deployment Strategy - Canary Deployment

Why Canary Deployment important?
- 빅이슈가 예상되는 경우, 새로운 피쳐를 일정 유저를 대상으로 테스트해보고 싶은 경우

## Canary Deployement Scenario

- 이미 운영 중인 Pod/Application: Stable
- 새로 릴리즈할 Pod/Application: Canary

1. Stable 버전의 replicas 수를 줄인다.
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

## Prerequisites
9번, 10번 과정을 하지 않고 step2/canary-nginx-deployment.yaml의 replicas:3으로 바꾸고 Canary Deployment의 name, selector의 release값도 stable로, pod label의 release로 stable로 편집하면 안되냐고 물을 수도 있다.

<!-- 삭제예정 


그런데 이렇게 하면 편집하기 전에 생성된 canary 버전의 pod은 고아가 된다. 왜냐하면 편집된 deployement가 생성한 ReplicaSet Controller가 달라지고 다른 Pod을 replicas 수만큼 생성해서 관리할 것이기 때문이다. 그러면 Pod을 한번에 싹 다 지우고 다시 생성하는 것과 동일하며 downtime이 발생한다.
-->

## log
결과 분석:
마지막 9를 실행하면 nginx-stable Deployment의 RollingUpdate가 일어나면서 마지막 남은 nginx:1.10 버전이 자연스럽게 종료된다. 그리고 이미지 버전을 1.11로 바꿨기 때문에 자연스럽게 replicas 수만큼 nginx:1.11 pod이 생성된다. 

만약 nginx-stable Deployment를 버리고 nginx-canary Deployment를 그대로 운영한다면 RollingUpdate가 일어나는 것이 아니라 아예 새로운 Deployment가 운영되는 것이다.







Required:
- **Pod labels 와 Service selector 값이 같고 version을 label로 포함해야 한다.** : Router/LoadBalancer가 upstream 목적지를 스위칭하는 기준이 되기 때문
- Deployment name은 `Service name-version` 이어야 한다. (Deployment가 잘 배포되었는지 확인하기 위한 기준으로 사용, Deployment의 각 버전을 구별할 수 있는 기준값이 있어야 함)

- Docker image를 Git hash로 태깅하고 spec에 version을 Git hash값으로 지정하는 것도 좋은 방법

## 5~7 과정 자동화
1. sh blue-green-deployement.sh <namespace> <service-name> <new-version> <new-deployment-file-path>

Example:
sh blue-green-deployement.sh blue-green nginx 1.11 green-nginx-deployment.yaml

`nginx` Service를 `1.11` 버전으로 `blue-green` 네임스페이스에 새롭게 배포함

배포되는 어플리케이션은 `green-nginx-deployment.yaml`에 Deployment로 정의되어 있음



## Rolling update??


## Reference 
- https://www.ianlewis.org/en/bluegreen-deployments-kubernetes
- https://codefresh.io/kubernetes-tutorial/fully-automated-blue-green-deployments-kubernetes-codefresh/

- More: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/