#!/bin/bash

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 镜像仓库地址
REGISTRY="1.94.151.57:85/test"

# 失败的服务列表
SERVICES=("account-service" "risk-service" "ledger-service" "notification-service" "transfer-service")

echo "========================================="
echo "重新构建失败的服务镜像"
echo "========================================="
echo ""

# 代理配置（已禁用）
HTTP_PROXY=""
HTTPS_PROXY=""
NO_PROXY="localhost,127.0.0.1,.aliyun.com,.aliyuncs.com"

# Docker 构建参数
BUILD_ARGS="--build-arg HTTP_PROXY=${HTTP_PROXY} --build-arg HTTPS_PROXY=${HTTPS_PROXY} --build-arg NO_PROXY=${NO_PROXY}"

# 构建每个服务
for SERVICE in "${SERVICES[@]}"; do
    echo -e "${YELLOW}正在构建 ${SERVICE}...${NC}"
    
    docker build ${BUILD_ARGS} \
        -f docker/${SERVICE}/Dockerfile \
        -t ${REGISTRY}/isbank-${SERVICE}:latest \
        .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ${SERVICE} 构建成功${NC}"
    else
        echo -e "${RED}✗ ${SERVICE} 构建失败${NC}"
        exit 1
    fi
    echo ""
done

echo "========================================="
echo -e "${GREEN}所有服务构建完成！${NC}"
echo "========================================="
echo ""
echo "下一步："
echo "  1. 推送镜像: ./scripts/push-images.sh"
echo "  2. 重新部署: kubectl delete pods -n isbank -l 'app in (account-service,risk-service,ledger-service,notification-service,transfer-service)'"
echo ""

