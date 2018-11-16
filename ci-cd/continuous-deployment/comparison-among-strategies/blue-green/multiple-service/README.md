# 테스트 과정
- service/deployment v1 배포, ingress v1 배포 (serviceName이 v1을 가리킴)
- service/deployment v2 배포, ingress v2 배포 (serviceName이 v2를 가리킴)
- single service 배포와 다른점: ingress 룰에서 serviceName을 바꾼다. 그리고 서비스 버전별로 Service 오브젝트가 있다. 
- single service일 때는 Service 오브젝트는 하나로 쓰고 selector의 버전 label을 변경했다.
- rollback 하려면 ingress v1 버전을 다시 배포 

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