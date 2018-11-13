## 결과
- 개발환경에서 사용하기에 적합, 어플리케이션 상태(state)가 완전히 새로 바뀌기 때문
- 선 삭제 후 재배포, 컨테이너가 시작되기 까지 서비스하지 못함

## 테스트 방법
- Deployment strategy를 Recreate로 my-app:1.0 pod 생성
- kubectl get events -w로 발생하는 이벤트를 모니터링 해놓은 후 
- kubectl apply를 통해 my-app:2.0을 배포 
- 재빨리 while sleep 0.1; do curl $(minikube service my-app --url); done (0.1초마다 요청 실행)
- kubectl delete --all -l app=my-app으로 정리 (all = service, deployment, replicaset, pod)

replicas 3
pod 수 변경 과정: 3 -> 0 -> 3
## log
### kubectl get events -w 결과
0s    Normal   ScalingReplicaSet   Deployment   Scaled down replica set my-app-66c8788c9 to 0
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-n42dk
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-d9mr4
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-hljkj
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod

0s    Normal   ScalingReplicaSet   Deployment   Scaled up replica set my-app-86c96476f5 to 3
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-86c96476f5-lqb2s
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-86c96476f5-d4lh8
0s    Normal   Scheduled   Pod   Successfully assigned my-app-86c96476f5-gvxxl tominikube
0s    Normal   Scheduled   Pod   Successfully assigned my-app-86c96476f5-lqb2s tominikube
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-86c96476f5-gvxxl
0s    Normal   Scheduled   Pod   Successfully assigned my-app-86c96476f5-d4lh8 tominikube
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Pulling   Pod   pulling image "devchloe/my-app:2.0"
0s    Normal   Pulling   Pod   pulling image "devchloe/my-app:2.0"
0s    Normal   Pulling   Pod   pulling image "devchloe/my-app:2.0"
0s    Normal   Pulled   Pod   Successfully pulled image "devchloe/my-app:2.0"
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   Pulled   Pod   Successfully pulled image "devchloe/my-app:2.0"
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   Pulled   Pod   Successfully pulled image "devchloe/my-app:2.0"
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container

### while shell script 실행 결과
while sleep 0.1; do curl "$service"; done
curl: (7) Failed to connect to 192.168.99.100 port 30144: Codeploynnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused                                            deploycurl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused                                            b24cd9curl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused                                            deploycurl: (7) Failed to connect to 192.168.99.100 port 30144: Co
nnection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Connection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Connection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Connection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Connection refused
curl: (7) Failed to connect to 192.168.99.100 port 30144: Connection refused
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0

reference
https://container-solutions.com/kubernetes-deployment-strategies/
https://nodejs.org/ko/docs/guides/nodejs-docker-webapp/
