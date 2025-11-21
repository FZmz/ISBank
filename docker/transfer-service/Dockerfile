# 多阶段构建 - 构建阶段
FROM maven:3.8.6-openjdk-8-slim AS builder

WORKDIR /build

# 复制 Maven 配置（使用阿里云镜像加速）
COPY docker/maven-settings.xml /usr/share/maven/conf/settings.xml

# 复制父POM
COPY pom.xml .

# 复制所有模块（Maven需要知道所有模块）
COPY common ./common
COPY eureka-server ./eureka-server
COPY gateway-service ./gateway-service
COPY account-service ./account-service
COPY transfer-service ./transfer-service
COPY ledger-service ./ledger-service
COPY risk-service ./risk-service
COPY notification-service ./notification-service

# 构建项目
RUN mvn clean package -pl transfer-service -am -DskipTests

# 运行阶段
FROM eclipse-temurin:8-jre-alpine

WORKDIR /app

# 复制构建产物
COPY --from=builder /build/transfer-service/target/*.jar app.jar

# 设置 Alpine 镜像源为阿里云并设置时区
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

# 暴露端口
EXPOSE 8085

# JVM参数优化
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令 - 使用k8s profile
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dspring.profiles.active=k8s -Djava.security.egd=file:/dev/./urandom -jar app.jar"]

