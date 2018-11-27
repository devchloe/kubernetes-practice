## RollingUpdate
- RollingUpdate 의미: 항상 트래픽을 받을 Pod이 존재하는 상태에서 어플리케이션 버전 갱신이 일어난다. (zero-downtime)
- Deployment의 image가 바뀌면 RollingUpdate가 일어난다.
- old pod을 지우고 new pod을 생성, readinessProbe가 성공이면 traffic을 이동
- 이 과정을 old pod이 모두 제거될 때까지 반복

### RollingUpdate 시 주의사항
- `session affinity` 로직이 잘 설계되지 않으면 문제가 있을 수 있다. 왜냐하면 old pod과 new pod이 함께 공존하는 시간이 존재하기 때문에 사용자는 new pod을 통해 서비스를 받다가 다음 요청은 old pod에서 처리될 수 있다. 
- `데이터와 API에 대한 forward and backward compatibility`를 잘 설계해야 한다. 이런 준비 작업이 오래 걸릴 수 있다. 그러면 충분한 트래픽을 감당할 pod보다 적은 수로 트래픽을 처리해야하는 window time이 생길 수 있다.


## 차이점
- RollingUpdate: 동시에 old, new에 트래픽이 라우팅된다. 
  - 방법: Deployment의 image만 변경
- Blue/Green: RollingUpdate와 비교하면, 트래픽이 old, new에 동시에 갈 일이 없고 한 번에 old -> new로 트래픽 라우팅이 변경된다.
  - 방법: Canary와 비교하면, Service LoadBalancer의 selector를 변경
  - rollback 방법: selector를 old pod label로 변경
- Canary: 동시에 old, new에 트래픽이 라우팅된다. 사용자 일부를 대상으로 테스팅하는 목적이 있다. 트래픽 비율은 old/new pod 수에 의해 결정됨, 3/2 pod, new pod으로 40% traffic이 감
  - 방법: Blue/Green과 비교하면, old/new Deployment의 replicas 수를 조정
  - rollback 방법: new replicas 수 조정, deployment 삭제

## Jenkins를 통한 zero-downtime deployment workflow and visualize deployment steps
### Jenkins Pipeline

## Reference
- RollingUpdate: https://kubernetes.io/blog/2018/04/30/zero-downtime-deployment-kubernetes-jenkins/