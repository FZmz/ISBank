#!/bin/bash

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================="
echo "ISBank 微服务系统 - 一键部署"
echo "========================================="
echo ""
echo "此脚本将执行以下操作:"
echo "  1. 构建所有Docker镜像"
echo "  2. 推送镜像到仓库"
echo "  3. 部署到Kubernetes集群"
echo ""

read -p "是否继续? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消部署"
    exit 0
fi

# 切换到项目根目录
cd "$(dirname "$0")/.."

# 步骤1: 构建镜像
echo ""
echo "========================================="
echo "步骤 1/3: 构建Docker镜像"
echo "========================================="
./scripts/build-images.sh

# 步骤2: 推送镜像
echo ""
echo "========================================="
echo "步骤 2/3: 推送镜像到仓库"
echo "========================================="
./scripts/push-images.sh

# 步骤3: 部署到K8s
echo ""
echo "========================================="
echo "步骤 3/3: 部署到Kubernetes"
echo "========================================="
./scripts/deploy-k8s.sh

echo ""
echo "========================================="
echo -e "${GREEN}一键部署完成！${NC}"
echo "========================================="
echo ""
echo "访问应用:"
echo "  前端:    http://<NODE_IP>:30000"
echo "  Gateway: http://<NODE_IP>:30080"
echo "  Eureka:  http://<NODE_IP>:8761"
echo ""
echo "获取NODE_IP:"
echo "  kubectl get nodes -o wide"
echo ""

