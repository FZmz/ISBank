#!/bin/bash

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================="
echo "ISBank 微服务系统 - 部署到Kubernetes"
echo "========================================="
echo ""

# 切换到项目根目录
cd "$(dirname "$0")/.."

# 检查kubectl是否可用
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}错误: kubectl 未安装${NC}"
    exit 1
fi

# 检查集群连接
echo -e "${YELLOW}检查Kubernetes集群连接...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}错误: 无法连接到Kubernetes集群${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 集群连接正常${NC}"
echo ""

# 步骤1: 创建命名空间
echo -e "${YELLOW}步骤 1/3: 创建命名空间${NC}"
kubectl apply -f k8s/namespace/namespace.yaml
echo -e "${GREEN}✓ 命名空间创建完成${NC}"
echo ""

# 步骤2: 部署所有服务
echo -e "${YELLOW}步骤 2/3: 部署所有服务${NC}"
echo "部署 MySQL..."
kubectl apply -f k8s/mysql/mysql-deployment.yaml

echo "部署 Eureka Server..."
kubectl apply -f k8s/eureka-server/deployment.yaml

echo "部署 Gateway Service..."
kubectl apply -f k8s/gateway-service/deployment.yaml

echo "部署业务微服务..."
kubectl apply -f k8s/account-service/deployment.yaml
kubectl apply -f k8s/risk-service/deployment.yaml
kubectl apply -f k8s/ledger-service/deployment.yaml
kubectl apply -f k8s/notification-service/deployment.yaml
kubectl apply -f k8s/transfer-service/deployment.yaml

echo "部署前端应用..."
kubectl apply -f k8s/frontend/deployment.yaml

echo -e "${GREEN}✓ 所有服务已提交部署${NC}"
echo ""

# 步骤3: 查看部署状态
echo -e "${YELLOW}步骤 3/3: 查看部署状态${NC}"
echo "等待 Pod 启动中..."
sleep 5
kubectl get pods -n isbank
echo ""

echo "========================================="
echo -e "${GREEN}部署提交完成！${NC}"
echo "========================================="
echo ""
echo -e "${YELLOW}提示:${NC}"
echo "  所有服务已提交到 Kubernetes，正在后台启动中"
echo "  服务启动需要一定时间，请耐心等待"
echo ""
echo "服务访问地址:"
echo "  Eureka Server:  http://<NODE_IP>:8761"
echo "  Gateway:        http://<NODE_IP>:30889"
echo "  Frontend:       http://<NODE_IP>:30000"
echo ""
echo "常用命令:"
echo "  # 查看所有 Pod 状态"
echo "  kubectl get pods -n isbank"
echo ""
echo "  # 查看所有服务"
echo "  kubectl get svc -n isbank"
echo ""
echo "  # 查看某个服务的日志"
echo "  kubectl logs -f deployment/<service-name> -n isbank"
echo ""
echo "  # 查看某个 Pod 的详细信息"
echo "  kubectl describe pod <pod-name> -n isbank"
echo ""
echo "  # 等待所有 Pod 就绪（可选）"
echo "  kubectl wait --for=condition=ready pod --all -n isbank --timeout=300s"
echo ""

