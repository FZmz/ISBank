#!/bin/bash

echo "========================================="
echo "ISBank 微服务系统 - 安全启动脚本"
echo "========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 创建日志目录
mkdir -p logs

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${RED}错误: 端口 $port 已被占用${NC}"
        echo "请先停止占用该端口的进程: lsof -ti:$port | xargs kill -9"
        return 1
    fi
    return 0
}

# 等待服务启动
wait_for_service() {
    local service_name=$1
    local port=$2
    local max_wait=60
    local count=0
    
    echo -e "${YELLOW}等待 $service_name 启动...${NC}"
    
    while [ $count -lt $max_wait ]; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
            echo -e "${GREEN}✓ $service_name 启动成功 (端口 $port)${NC}"
            return 0
        fi
        sleep 1
        count=$((count + 1))
        echo -n "."
    done
    
    echo ""
    echo -e "${RED}✗ $service_name 启动超时${NC}"
    return 1
}

# 检查 Eureka 是否就绪
check_eureka() {
    local max_wait=30
    local count=0
    
    echo -e "${YELLOW}检查 Eureka Server 是否就绪...${NC}"
    
    while [ $count -lt $max_wait ]; do
        if curl -s http://localhost:8761/eureka/apps > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Eureka Server 就绪${NC}"
            return 0
        fi
        sleep 1
        count=$((count + 1))
        echo -n "."
    done
    
    echo ""
    echo -e "${RED}✗ Eureka Server 未就绪${NC}"
    return 1
}

echo "步骤 1/4: 检查端口占用情况"
echo "-------------------------------------------"
check_port 8761 || exit 1
check_port 8080 || exit 1
check_port 8081 || exit 1
check_port 8082 || exit 1
check_port 8083 || exit 1
check_port 8084 || exit 1
check_port 8085 || exit 1
echo -e "${GREEN}✓ 所有端口可用${NC}"
echo ""

echo "步骤 2/4: 启动 Eureka Server"
echo "-------------------------------------------"
cd eureka-server
echo "编译 Eureka Server..."
mvn clean compile -q > ../logs/eureka-compile.log 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Eureka Server 编译失败，查看日志: logs/eureka-compile.log${NC}"
    exit 1
fi

echo "启动 Eureka Server..."
nohup mvn spring-boot:run > ../logs/eureka.log 2>&1 &
EUREKA_PID=$!
echo "Eureka Server PID: $EUREKA_PID"
cd ..

# 等待 Eureka 启动
if ! wait_for_service "Eureka Server" 8761; then
    echo -e "${RED}Eureka Server 启动失败，查看日志: logs/eureka.log${NC}"
    exit 1
fi

# 等待 Eureka 完全就绪
sleep 5
if ! check_eureka; then
    echo -e "${RED}Eureka Server 未就绪，查看日志: logs/eureka.log${NC}"
    exit 1
fi
echo ""

echo "步骤 3/4: 启动 Gateway Service"
echo "-------------------------------------------"
cd gateway-service
echo "编译 Gateway Service..."
mvn clean compile -q > ../logs/gateway-compile.log 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Gateway Service 编译失败，查看日志: logs/gateway-compile.log${NC}"
    exit 1
fi

echo "启动 Gateway Service..."
nohup mvn spring-boot:run > ../logs/gateway.log 2>&1 &
echo "Gateway Service PID: $!"
cd ..

if ! wait_for_service "Gateway Service" 8080; then
    echo -e "${RED}Gateway Service 启动失败，查看日志: logs/gateway.log${NC}"
    exit 1
fi
sleep 3
echo ""

echo "步骤 4/4: 启动业务微服务"
echo "-------------------------------------------"

# 定义服务列表
services=("account-service:8081" "risk-service:8082" "ledger-service:8083" "notification-service:8084" "transfer-service:8085")

for service_info in "${services[@]}"; do
    IFS=':' read -r service port <<< "$service_info"
    
    echo "启动 $service..."
    cd $service
    
    # 编译
    mvn clean compile -q > ../logs/${service}-compile.log 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ $service 编译失败，查看日志: logs/${service}-compile.log${NC}"
        cd ..
        continue
    fi
    
    # 启动
    nohup mvn spring-boot:run > ../logs/${service}.log 2>&1 &
    echo "$service PID: $!"
    cd ..
    
    # 等待启动
    if ! wait_for_service "$service" $port; then
        echo -e "${RED}$service 启动失败，查看日志: logs/${service}.log${NC}"
    fi
    
    # 给服务一点时间注册到 Eureka
    sleep 2
done

echo ""
echo "========================================="
echo "启动完成!"
echo "========================================="
echo ""
echo "服务状态:"
echo "  Eureka Server:        http://localhost:8761"
echo "  Gateway Service:      http://localhost:8080"
echo "  Account Service:      http://localhost:8081"
echo "  Risk Service:         http://localhost:8082"
echo "  Ledger Service:       http://localhost:8083"
echo "  Notification Service: http://localhost:8084"
echo "  Transfer Service:     http://localhost:8085"
echo ""
echo "API 文档: http://localhost:8080/doc.html"
echo ""
echo "查看日志:"
echo "  tail -f logs/eureka.log"
echo "  tail -f logs/gateway.log"
echo "  tail -f logs/account-service.log"
echo ""
echo "停止所有服务: ./stop-all.sh"
echo "========================================="

