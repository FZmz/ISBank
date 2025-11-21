# ISBank - Kubernetes 快速部署指南

## 🚀 一键部署

```bash
# 1. 登录镜像仓库
docker login 1.94.151.57:85

# 2. 一键部署
./scripts/deploy-all.sh
```

## 📋 分步部署

### 步骤1: 构建镜像

```bash
./scripts/build-images.sh
```

### 步骤2: 推送镜像

```bash
./scripts/push-images.sh
```

### 步骤3: 部署到K8s

```bash
./scripts/deploy-k8s.sh
```

## 🔍 验证部署

```bash
# 查看所有Pod
kubectl get pods -n isbank

# 查看服务
kubectl get svc -n isbank

# 获取访问地址
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Frontend:  http://${NODE_IP}:30000"
echo "Gateway:   http://${NODE_IP}:30080"
echo "Eureka:    http://${NODE_IP}:8761"
```

## 🧹 清理资源

```bash
./scripts/undeploy-k8s.sh
```

## 📊 常用命令

```bash
# 查看日志
kubectl logs -f deployment/account-service -n isbank

# 进入容器
kubectl exec -it deployment/account-service -n isbank -- sh

# 扩缩容
kubectl scale deployment account-service --replicas=3 -n isbank

# 重启服务
kubectl rollout restart deployment/account-service -n isbank
```

## 🔧 故障排查

```bash
# 查看Pod详情
kubectl describe pod <pod-name> -n isbank

# 查看事件
kubectl get events -n isbank --sort-by='.lastTimestamp'

# 查看资源使用
kubectl top pods -n isbank
```

## 📁 文件结构

```
ISBank/
├── docker/                    # Docker镜像文件
│   ├── eureka-server/
│   ├── gateway-service/
│   ├── account-service/
│   ├── risk-service/
│   ├── ledger-service/
│   ├── notification-service/
│   ├── transfer-service/
│   └── frontend/
├── k8s/                       # Kubernetes部署文件
│   ├── namespace/
│   ├── mysql/
│   ├── eureka-server/
│   ├── gateway-service/
│   ├── account-service/
│   ├── risk-service/
│   ├── ledger-service/
│   ├── notification-service/
│   ├── transfer-service/
│   └── frontend/
├── scripts/                   # 自动化脚本
│   ├── build-images.sh       # 构建镜像
│   ├── push-images.sh        # 推送镜像
│   ├── deploy-k8s.sh         # 部署到K8s
│   ├── undeploy-k8s.sh       # 清理资源
│   ├── deploy-all.sh         # 一键部署
│   └── generate-k8s-manifests.sh
└── K8S_DEPLOYMENT_GUIDE.md   # 详细部署文档
```

## 🌐 服务端口

| 服务 | 内部端口 | NodePort | 说明 |
|------|---------|----------|------|
| Frontend | 80 | 30000 | 前端应用 |
| Gateway | 8080 | 30080 | API网关 |
| Eureka | 8761 | - | 服务注册中心 |
| Account | 8081 | - | 账户服务 |
| Risk | 8082 | - | 风控服务 |
| Ledger | 8083 | - | 总账服务 |
| Notification | 8084 | - | 通知服务 |
| Transfer | 8085 | - | 转账服务 |
| MySQL | 3306 | - | 数据库 |

## 🗄️ 数据库

每个服务使用独立数据库：

- `greenbank_account` - 账户服务
- `greenbank_risk` - 风控服务
- `greenbank_ledger` - 总账服务
- `greenbank_notification` - 通知服务
- `greenbank_transfer` - 转账服务

## 📝 注意事项

1. **镜像仓库**: 确保可以访问 `1.94.151.57:85`
2. **资源要求**: 至少4核CPU、8GB内存
3. **存储**: MySQL需要10GB持久化存储
4. **网络**: 确保K8s集群网络正常
5. **启动顺序**: MySQL → Eureka → Gateway → 业务服务

## 🆘 获取帮助

详细文档请参考: [K8S_DEPLOYMENT_GUIDE.md](K8S_DEPLOYMENT_GUIDE.md)

