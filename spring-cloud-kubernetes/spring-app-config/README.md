# Spring Boot application.yml externalized to Kuberenetes ConfigMap

## Spring Boot Application 생성 

### dependencies
- spring-cloud-kubernetes-config
- spring-boot-starter-web
- pring-boot-starter-actuator

### bootstrap.yml
```yaml
spring:
  application:
    name: spring-app-config
  cloud.kubernetes.config:
        name: ${spring.application.name}
        namespace: default
```

### Dockerfile
```
FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE=build/libs/demo-config-test-1.0.0.jar
COPY ${JAR_FILE} sample.jar
ENTRYPOINT ["java","-jar","/sample.jar"]
```
```bash
$ docker build -t devchloe/demo-config-test .
$ docker push devchloe/demo-config-test
```

## Kubernetes ConfigMap 생성

### application.yml
```yaml
greeting:
  message: Say Hello to the World
hi: Say Hi
```

## ClusterRole 생성
### ClusterRole Object
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: service-discovery-client
rules:
- apiGroups: [""]
  resources: ["services", "pods", "configmaps", "endpoints"]
  verbs: ["get", "watch", "list"]
```
```bash
$ kubectl create -f ./k8s-resources/cluster-role.yml
```

### ConfigMap
```bash
$ kubectl create configmap spring-app-config --from-file=application.yml
```

## Kubernetes Pod 생성

### ReplicaSet
```yaml
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: demo-config-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-config-test
  template:
    metadata:
      labels:
        app: demo-config-test
    spec:
      containers:
      - image: devchloe/demo-config-test
        name: demo-config-test
```

## 테스트를 위한 서비스 노출
### NodePort Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-config-test-nodeport
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30123
  selector:
    app: demo-config-test
```

## 테스트 실행
```bash
$ kubectl create -f ./k8s-resources/demo-config-test-replicaset.yml
$ kubectl create -f ./k8s-resources/demo-config-test-nodeport.yml
$ kubectl get pod
$ kubectl logs -f <<demo-config-test pod name>>
$ curl -i http://$(minikube ip):30123
```
