#!/bin/bash

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 镜像仓库地址
REGISTRY="1.94.151.57:85/test"

# 代理配置（如果需要）
HTTP_PROXY="${HTTP_PROXY:-http://127.0.0.1:7890}"
HTTPS_PROXY="${HTTPS_PROXY:-http://127.0.0.1:7890}"
NO_PROXY="${NO_PROXY:-localhost,127.0.0.1,.aliyun.com,.aliyuncs.com}"

# Docker 构建参数
BUILD_ARGS="--build-arg HTTP_PROXY=${HTTP_PROXY} --build-arg HTTPS_PROXY=${HTTPS_PROXY} --build-arg NO_PROXY=${NO_PROXY}"

# 服务列表
SERVICES=("eureka-server" "gateway-service" "account-service" "risk-service" "ledger-service" "notification-service" "transfer-service" "frontend")

echo "========================================="
echo "ISBank 微服务系统 - 构建Docker镜像"
echo "========================================="
echo ""
echo -e "${YELLOW}代理配置:${NC}"
echo "  HTTP_PROXY:  ${HTTP_PROXY}"
echo "  HTTPS_PROXY: ${HTTPS_PROXY}"
echo "  NO_PROXY:    ${NO_PROXY}"
echo ""

# 切换到项目根目录
cd "$(dirname "$0")/.."

echo -e "${YELLOW}步骤 1/3: 清理旧的构建产物${NC}"
mvn clean -q
echo -e "${GREEN}✓ 清理完成${NC}"
echo ""

echo -e "${YELLOW}步骤 2/3: 构建Docker镜像${NC}"
for service in "${SERVICES[@]}"; do
    echo "----------------------------------------"
    echo -e "${YELLOW}构建 ${service}...${NC}"

    if [ "$service" = "frontend" ]; then
        # 前端使用单独的Dockerfile
        docker build ${BUILD_ARGS} -f docker/${service}/Dockerfile -t ${REGISTRY}/isbank-${service}:latest .
    else
        # 后端服务使用统一的构建方式
        docker build ${BUILD_ARGS} -f docker/${service}/Dockerfile -t ${REGISTRY}/isbank-${service}:latest .
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ${service} 构建成功${NC}"
    else
        echo -e "${RED}✗ ${service} 构建失败${NC}"
        exit 1
    fi
done

HTTP_PROXY=""
HTTPS_PROXY=""

echo ""
echo -e "${YELLOW}步骤 3/3: 查看构建的镜像${NC}"
echo "----------------------------------------"
docker images | grep "isbank-"

echo ""
echo "========================================="
echo -e "${GREEN}所有镜像构建完成！${NC}"
echo "========================================="
echo ""
echo "下一步:"
echo "  1. 推送镜像到仓库: ./scripts/push-images.sh"
echo "  2. 部署到K8s集群: ./scripts/deploy-k8s.sh"
echo "  3. 或一键部署: ./scripts/deploy-all.sh"
echo ""

