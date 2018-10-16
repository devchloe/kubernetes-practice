FROM openjdk:8-jdk-alpine
                                                 VOLUME /tmp
                                                 ARG JAR_FILE=build/libs/order-service.jar
                                                 COPY ${JAR_FILE} order-service.jar

                                                 ENTRYPOINT ["java", "-jar", "/order-service.jar"]