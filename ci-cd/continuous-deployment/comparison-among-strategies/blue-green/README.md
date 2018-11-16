## 결과
- 서로 다른 API 버전을 배포하기에 최적이다. (traffic을 한번에 전환시키기 때문에, 동시에 오래된 버전과 새로운 버전이 traffic을 받을 일이 없다)
- 새로운 버전을 오래된 버전 수만큼 준비시켜 놓은 상태에서 Service의 selector를 변경시켜서 traffic이 한번에 넘어가도록 만든다 

### 장점
- rollout, rollback이 즉각적으로 일어난다
- versioning 이슈를 피할 수 있다. 한 번에 클러스터 내에 버전을 변경시키기 때문에
- production에 릴리즈하기 전에 새로운 버전을 테스트해볼 수 있다

### 단점
- 리소스가 두배로 필요하다.
- 운영에 릴리즈하기 전에 전체 플랫폼이 적절히 테스트되어야 한다.
- stateful(session등) application을 다루는게 어려울 수 있다. (오래된 버전이 트래픽을 받았다가 새로운 버전으로 바뀌고 난 뒤에 그 트래픽이 새로운 버전으로 넘어가기 때문에)

## 테스트 과정
- kubectl get events -w
- service 배포 (spec.selector.app & spec.selector.version)
- deployment v1 배포
- curl $(minikube service my-app --url) 테스트
- deployment v2 배포
- curl $(minikube service my-app --url) 테스트
- service=$(minikube service my-app --url), while sleep 0.1; do curl "$service"; done
- patch service spec.selector.version 실행

## logs

### service의 selector version을 바꾼 결과
일시에 순간적으로 바뀜
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
Hello version 2.0
Hello version 2.0
Hello version 2.0
Hello version 2.0
Hello version 2.0
Hello version 2.0
Hello version 2.0
Hello version 2.0

reference
https://github.com/ContainerSolutions/k8s-deployment-strategies/tree/master/blue-green