FROM  eclipse-temurin:17-jdk-alpine as build
WORKDIR /app
COPY . .
RUN chmod +x ./gradlew
RUN ./gradlew build -x test

FROM eclipse-temurin:17-jre-alpine as production
WORKDIR /app
COPY --from=build /app/build/libs/demo-0.0.1-SNAPSHOT.jar app.jar
RUN addgroup -g 1002 appgroup
RUN adduser -D -u 1002 appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser
ENTRYPOINT ["java","-jar","app.jar"]