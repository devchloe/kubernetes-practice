FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE=build/libs/order-service.jar
COPY ${JAR_FILE} order-service.jar

ADD spring-boot-app.sh /bin/spring-boot-app.sh
RUN ["chmod", "+x", "/bin/spring-boot-app.sh"]

ENTRYPOINT ["/bin/spring-boot-app.sh"]

