FROM maven:3.8.6-openjdk-11-slim AS build
WORKDIR /app
COPY ./app .
RUN mvn package

FROM openjdk:11
WORKDIR /app
COPY --from=build /app/target/letscodebyada-0.0.1-SNAPSHOT.jar .
ENV MYSQL_DB_HOST jdbc:mysql//
ENV MYSQL_DB_USER user
ENV MYSQL_DB_PASS pass
EXPOSE 8080
EXPOSE 443
ENTRYPOINT ["java","-jar","./letscodebyada-0.0.1-SNAPSHOT.jar"]
