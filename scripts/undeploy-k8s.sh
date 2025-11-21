#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================="
echo "ISBank 微服务系统 - 清理Kubernetes资源"
echo "========================================="
echo ""

read -p "确认要删除所有ISBank资源吗? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消清理"
    exit 0
fi

echo -e "${YELLOW}开始清理资源...${NC}"
echo ""

# 删除所有部署
echo -e "${YELLOW}删除所有部署...${NC}"
kubectl delete namespace isbank --ignore-not-found=true

echo ""
echo -e "${YELLOW}等待资源清理完成...${NC}"
kubectl wait --for=delete namespace/isbank --timeout=120s || true

echo ""
echo "========================================="
echo -e "${GREEN}清理完成！${NC}"
echo "========================================="
echo ""
echo "所有ISBank资源已删除"
echo ""

