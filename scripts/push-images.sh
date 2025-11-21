#!/bin/bash

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 镜像仓库地址
REGISTRY="1.94.151.57:85/test"

# 服务列表
SERVICES=("eureka-server" "gateway-service" "account-service" "risk-service" "ledger-service" "notification-service" "transfer-service" "frontend")

echo "========================================="
echo "ISBank 微服务系统 - 推送Docker镜像"
echo "========================================="
echo ""

# 检查是否已登录镜像仓库
echo -e "${YELLOW}检查镜像仓库连接...${NC}"
if ! docker info | grep -q "Registry: ${REGISTRY}"; then
    echo -e "${YELLOW}请先登录镜像仓库:${NC}"
    echo "  docker login ${REGISTRY}"
    read -p "是否现在登录? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login ${REGISTRY}
    else
        echo -e "${RED}取消推送${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}开始推送镜像...${NC}"
for service in "${SERVICES[@]}"; do
    echo "----------------------------------------"
    echo -e "${YELLOW}推送 ${service}...${NC}"
    
    docker push ${REGISTRY}/isbank-${service}:latest
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ${service} 推送成功${NC}"
    else
        echo -e "${RED}✗ ${service} 推送失败${NC}"
        exit 1
    fi
done

echo ""
echo "========================================="
echo -e "${GREEN}所有镜像推送完成！${NC}"
echo "========================================="
echo ""
echo "镜像列表:"
for service in "${SERVICES[@]}"; do
    echo "  ${REGISTRY}/isbank-${service}:latest"
done
echo ""
echo "下一步:"
echo "  部署到K8s集群: ./scripts/deploy-k8s.sh"
echo ""

