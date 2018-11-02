# Deployment Strategies

## List
- Blue/Green 
- Canary 
- A/B Test

## Keyword
Test, Deploy, Rollback

## Cares
API and schema changes, API versioning

## Deployment
- 역할
  - ReplicaSet, Pod
- Strategy

Recreate
  - old pod을 삭제한 후 new pod을 생성 

Ramped Deployment
  - 하나 이상의 pod replicas가 실행되는 상태에서 pod 하나를 죽이고 새로운 pod을 생성해서 트래픽을 받을 준비가 되면 두번째 old pod을 죽이고 반복..
  - readiness Probe 정의 필요, health check
  - fail 이면 새로운 pod이 죽고 다시 old pod이 replicas 수만큼 생성된다. 

Blue-Green Deployment
- 새로운 버전이 준비된 상태에서 한번에 트래픽을 전환

Canary Deployment
- canary quality threchold: metrics 수집
- test basec on real-user in production
- fail-fast
- 새로운 버전을 준비해놓고 트래픽의 일부분을 전환해서 테스트하고 점점 트래픽 비율을 늘려가는 방식

A/B Testing
- load balancing과 traffic을 나누는 기술이 필요함


## Reference
- https://codefresh.io/kubernetes-tutorial/continuous-deployment-strategies-kubernetes-2/
- Docker Container 오케스트레이션과 스케쥴링 워크플로우 https://blog.dockbit.com/kubernetes-canary-deployments-for-mere-mortals-6696910a52b2
- https://container-solutions.com/kubernetes-deployment-strategies/