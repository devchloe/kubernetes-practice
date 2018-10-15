FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE=build/libs/demo-config-test-1.0.0.jar
COPY ${JAR_FILE} sample.jar
ENTRYPOINT ["java","-jar","/sample.jar"]