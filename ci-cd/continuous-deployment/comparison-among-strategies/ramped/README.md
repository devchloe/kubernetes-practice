## 결과
- slow rollout 천천히 릴리즈한다
- 오래된 버전을 삭제하기 전에 새로운 버전을 생성하고 트래픽을 받을 준비를 마치면 풀에 등록된다.
- 그 다음 그 풀에서 오래된 버전을 삭제한다. 이 과정에서 오래된 버전과 새로운 버전의 pod 수는 replicas만큼 유지된다. 1 만들고, 9로 줄이고, 2번째 만들고 8로 줄이고, ..
- 모든 오래된 pod이 새로운 pod으로 변경될 때까지 반복한다.

## 테스트 방법
- kubectl apply -f ramped-app-v1.yaml
- kubectl get events -w
- kubectl apply -f ramped-app-v2.yaml
- kubectl delete all -l app=my-app
- (kubectl rollout undo/pause/resume deploy my-app)

      replicas 10
service  --- 1 
         --- 1
         --- 1
         --- 1
         --- 1
         --- 1
         --- 1
         --- 1
         --- 2
         --- 2

## logs
###
0s    Normal   ScalingReplicaSet   Deployment   Scaled up replica set my-app-787c7cd849 to 1
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-k9spn to minikube
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-k9spn
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   ScalingReplicaSet   Deployment   Scaled down replica set my-app-66c8788c9 to 9
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-snbln
0s    Normal   ScalingReplicaSet   Deployment   Scaled up replica set my-app-787c7cd849 to 2
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-p7nb8 to minikube
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-p7nb8
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   ScalingReplicaSet   Deployment   Scaled down replica set my-app-66c8788c9 to 8
0s    Normal   ScalingReplicaSet   Deployment   Scaled up replica set my-app-787c7cd849 to 3
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-jhrkz
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-wnsjb
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-wnsjb to minikube
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Warning   Unhealthy   Pod   Readiness probe failed: Get http://172.17.0.16:8080/ready: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
0s    Warning   Unhealthy   Pod   Liveness probe failed: Get http://172.17.0.14:8080/health: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
0s    Normal   ScalingReplicaSet   Deployment   Scaled down replica set my-app-66c8788c9 to 7
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-cf6lz
0s    Normal   ScalingReplicaSet   Deployment   Scaled up replica set my-app-787c7cd849 to 4
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-8w48b
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-8w48b to minikube
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   ScalingReplicaSet   Deployment   Scaled down replica set my-app-66c8788c9 to 6
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-hhj29
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled up replica set my-app-787c7cd849 to 5
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-rwnsb
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-rwnsb to minikube
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-rt5sg
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled down replica set my-app-66c8788c9 to 5
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-rmqts
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-rmqts to minikube
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled up replica set my-app-787c7cd849 to 6
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled down replica set my-app-66c8788c9 to 4
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-zhchk
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled up replica set my-app-787c7cd849 to 7
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-lnx8v
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-lnx8v to minikube
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-sc68t
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled down replica set my-app-66c8788c9 to 3
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled up replica set my-app-787c7cd849 to 8
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-fjsvr
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-fjsvr to minikube
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled down replica set my-app-66c8788c9 to 2
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled up replica set my-app-787c7cd849 to 9
0s    Normal   SuccessfulCreate   ReplicaSet   Created pod: my-app-787c7cd849-t57g5
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-t57g5 to minikube
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-t4mxs
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled down replica set my-app-66c8788c9 to 1
0s    Normal   SuccessfulDelete   ReplicaSet   Deleted pod: my-app-66c8788c9-4qjkh
0s    Normal   SuccessfulCreate   ReplicaSet   (combined from similar events): Created pod: my-app-787c7cd849-9ccs8
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled up replica set my-app-787c7cd849 to 10
0s    Normal   Scheduled   Pod   Successfully assigned my-app-787c7cd849-9ccs8 to minikube
0s    Normal   SuccessfulMountVolume   Pod   MountVolume.SetUp succeeded for volume "default-token-g7r7x"
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod
0s    Normal   Pulled   Pod   Container image "devchloe/my-app:2.0" already present on machine
0s    Normal   Created   Pod   Created container
0s    Normal   Started   Pod   Started container
0s    Normal   ScalingReplicaSet   Deployment   (combined from similar events): Scaled down replica set my-app-66c8788c9 to 0
0s    Normal   SuccessfulDelete   ReplicaSet   (combined from similar events): Deleted pod: my-app-66c8788c9-zndfl
0s    Normal   Killing   Pod   Killing container with id docker://my-app:Need to kill Pod

### 호출 실행 결과
ello version 2.0
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
Hello version 2.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
Hello version 1.0
Hello version 1.0
Hello version 1.0
Hello version 2.0
Hello version 1.0

reference:
https://github.com/ContainerSolutions/k8s-deployment-strategies/tree/master/ramped