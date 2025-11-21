#!/bin/bash

echo "========================================="
echo "ISBank 微服务银行系统 - 启动脚本"
echo "========================================="

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java,请先安装JDK 8"
    exit 1
fi

# 检查Maven环境
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven,请先安装Maven 3.6+"
    exit 1
fi

echo ""
echo "步骤1: 编译项目..."
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
    echo "编译失败,请检查错误信息"
    exit 1
fi

echo ""
echo "步骤2: 启动Eureka服务注册中心..."
cd eureka-server
nohup mvn spring-boot:run > ../logs/eureka.log 2>&1 &
echo "Eureka Server启动中... (端口: 8761)"
cd ..
sleep 10

echo ""
echo "步骤3: 启动业务微服务..."

cd account-service
nohup mvn spring-boot:run > ../logs/account.log 2>&1 &
echo "Account Service启动中... (端口: 8081)"
cd ..
sleep 5

cd risk-service
nohup mvn spring-boot:run > ../logs/risk.log 2>&1 &
echo "Risk Service启动中... (端口: 8082)"
cd ..
sleep 5

cd ledger-service
nohup mvn spring-boot:run > ../logs/ledger.log 2>&1 &
echo "Ledger Service启动中... (端口: 8083)"
cd ..
sleep 5

cd notification-service
nohup mvn spring-boot:run > ../logs/notification.log 2>&1 &
echo "Notification Service启动中... (端口: 8084)"
cd ..
sleep 5

cd transfer-service
nohup mvn spring-boot:run > ../logs/transfer.log 2>&1 &
echo "Transfer Service启动中... (端口: 8085)"
cd ..
sleep 5

echo ""
echo "步骤4: 启动API网关..."
cd gateway-service
nohup mvn spring-boot:run > ../logs/gateway.log 2>&1 &
echo "Gateway Service启动中... (端口: 8080)"
cd ..
sleep 10

echo ""
echo "========================================="
echo "所有服务启动完成!"
echo "========================================="
echo ""
echo "访问地址:"
echo "  - Eureka控制台: http://localhost:8761"
echo "  - API网关文档: http://localhost:8080/doc.html"
echo "  - 前端应用: http://localhost:3000 (需单独启动)"
echo ""
echo "日志文件位置: ./logs/"
echo ""
echo "停止所有服务: ./stop-all.sh"
echo "========================================="

