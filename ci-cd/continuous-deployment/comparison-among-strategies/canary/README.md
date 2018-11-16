## 결과
- 운영환경에서 트래픽을 한번에 A 버전에서 B 버전으로 점진적으로 넘기는 방법 
- traffic distribution을 할 수 있다.
- 새로운 피처나 버전을 릴리즈할 자신이 없다면 일부 사용자를 대상으로 테스트 해볼 수 있다 (릴리즈 버전의 안정성을 테스트)

### 장점
- 사용자 그룹을 나누어서 테스트해볼 수 있다. 
- 빠른 rollback 가능

### 단점
- rollout이 느라다 
- traffic distribution 비용이 비싸다

## 테스트 방법
- service 하나 배포
- deployment v1 : deployment v2 = n:m 으로 배포
- deployment v2의 scale up 
- deployment v1을 삭제

- pod수가 아니라 HAProxy나 Linkerd와 같은 걸로 트래픽 조정
- Istio와 Helm으로 가능

## logs
### v1 10, v2 1
lo version 2.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
### v1 10, v2 10
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
Hello version 2.0
Hello version 1.0
Hello version 2.0
Hello version 2.0
