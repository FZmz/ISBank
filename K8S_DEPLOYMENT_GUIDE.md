# ISBank 微服务系统 - Kubernetes 部署指南

## 📋 目录

1. [系统架构](#系统架构)
2. [前置要求](#前置要求)
3. [数据库架构调整](#数据库架构调整)
4. [Docker镜像构建](#docker镜像构建)
5. [Kubernetes部署](#kubernetes部署)
6. [一键部署](#一键部署)
7. [验证部署](#验证部署)
8. [故障排查](#故障排查)

---

## 🏗️ 系统架构

### 微服务列表

| 服务名称 | 端口 | 数据库 | 说明 |
|---------|------|--------|------|
| eureka-server | 8761 | - | 服务注册中心 |
| gateway-service | 8080 | - | API网关 |
| account-service | 8081 | greenbank_account | 账户服务 |
| risk-service | 8082 | greenbank_risk | 风控服务 |
| ledger-service | 8083 | greenbank_ledger | 总账服务 |
| notification-service | 8084 | greenbank_notification | 通知服务 |
| transfer-service | 8085 | greenbank_transfer | 转账服务 |
| frontend | 80 | - | 前端应用 |

### 数据库架构

每个微服务使用独立的数据库，遵循微服务最佳实践：

- `greenbank_account` - 账户服务数据库
- `greenbank_risk` - 风控服务数据库
- `greenbank_ledger` - 总账服务数据库
- `greenbank_notification` - 通知服务数据库
- `greenbank_transfer` - 转账服务数据库

### 服务发现方案

- **K8s环境**: 使用Kubernetes Service进行服务发现
- **Eureka**: 保留作为服务注册中心，提供可视化监控
- **服务间调用**: 使用K8s Service名称（如 `http://account-service.isbank.svc.cluster.local:8081`）

---

## 📦 前置要求

### 1. 软件要求

- Docker 20.10+
- Kubernetes 1.20+
- kubectl 1.20+
- Maven 3.6+
- 访问镜像仓库 `1.94.151.57:85`

### 2. 镜像仓库配置

```bash
# 登录镜像仓库
docker login 1.94.151.57:85

# 配置Docker信任该仓库（如果是HTTP）
# 编辑 /etc/docker/daemon.json
{
  "insecure-registries": ["1.94.151.57:85"]
}

# 重启Docker
sudo systemctl restart docker
```

### 3. Kubernetes集群

确保有可用的Kubernetes集群：

```bash
# 检查集群连接
kubectl cluster-info

# 检查节点状态
kubectl get nodes
```

---

## 🗄️ 数据库架构调整

### 变更说明

**修改前**: 所有服务共用 `greenbank` 数据库  
**修改后**: 每个服务使用独立数据库

### 配置文件

为每个服务创建了 `application-k8s.yml` 配置文件：

- `account-service/src/main/resources/application-k8s.yml`
- `risk-service/src/main/resources/application-k8s.yml`
- `ledger-service/src/main/resources/application-k8s.yml`
- `notification-service/src/main/resources/application-k8s.yml`
- `transfer-service/src/main/resources/application-k8s.yml`

### 关键配置

```yaml
spring:
  datasource:
    url: jdbc:mysql://mysql.isbank.svc.cluster.local:3306/greenbank_account
    password: ${MYSQL_PASSWORD}

eureka:
  client:
    service-url:
      defaultZone: http://eureka-server.isbank.svc.cluster.local:8761/eureka/
```

---

## 🐳 Docker镜像构建

### 目录结构

```
docker/
├── eureka-server/Dockerfile
├── gateway-service/Dockerfile
├── account-service/Dockerfile
├── risk-service/Dockerfile
├── ledger-service/Dockerfile
├── notification-service/Dockerfile
├── transfer-service/Dockerfile
└── frontend/
    ├── Dockerfile
    └── nginx.conf
```

### 镜像特点

- **多阶段构建**: 减小镜像体积
- **基础镜像**: 
  - 后端: `openjdk:8-jre-alpine`
  - 前端: `nginx:alpine`
- **JVM优化**: 配置合理的内存参数
- **时区设置**: Asia/Shanghai

### 手动构建

```bash
# 构建所有镜像
./scripts/build-images.sh

# 构建单个服务
docker build -f docker/account-service/Dockerfile \
  -t 1.94.151.57:85/test/isbank-account-service:latest .
```

### 推送镜像

```bash
# 推送所有镜像
./scripts/push-images.sh

# 推送单个镜像
docker push 1.94.151.57:85/test/isbank-account-service:latest
```

---

## ☸️ Kubernetes部署

### 目录结构

```
k8s/
├── namespace/
│   └── namespace.yaml
├── mysql/
│   ├── mysql-deployment.yaml
│   └── init-databases.sql
├── eureka-server/
│   └── deployment.yaml
├── gateway-service/
│   └── deployment.yaml
├── account-service/
│   └── deployment.yaml
├── risk-service/
│   └── deployment.yaml
├── ledger-service/
│   └── deployment.yaml
├── notification-service/
│   └── deployment.yaml
├── transfer-service/
│   └── deployment.yaml
└── frontend/
    └── deployment.yaml
```

### 资源配置

每个服务包含：

- **Deployment**: Pod副本、镜像、环境变量、健康检查
- **Service**: ClusterIP或NodePort
- **Secret**: 数据库密码等敏感信息
- **InitContainer**: 等待依赖服务就绪

### 手动部署

```bash
# 1. 创建命名空间
kubectl apply -f k8s/namespace/namespace.yaml

# 2. 部署MySQL
kubectl apply -f k8s/mysql/mysql-deployment.yaml

# 3. 部署Eureka
kubectl apply -f k8s/eureka-server/deployment.yaml

# 4. 部署Gateway
kubectl apply -f k8s/gateway-service/deployment.yaml

# 5. 部署业务服务
kubectl apply -f k8s/account-service/deployment.yaml
kubectl apply -f k8s/risk-service/deployment.yaml
kubectl apply -f k8s/ledger-service/deployment.yaml
kubectl apply -f k8s/notification-service/deployment.yaml
kubectl apply -f k8s/transfer-service/deployment.yaml

# 6. 部署前端
kubectl apply -f k8s/frontend/deployment.yaml
```

---

## 🚀 一键部署

### 完整流程

```bash
# 一键构建、推送、部署
./scripts/deploy-all.sh
```

### 分步执行

```bash
# 步骤1: 构建镜像
./scripts/build-images.sh

# 步骤2: 推送镜像
./scripts/push-images.sh

# 步骤3: 部署到K8s
./scripts/deploy-k8s.sh
```

### 清理资源

```bash
# 删除所有ISBank资源
./scripts/undeploy-k8s.sh
```

---

## ✅ 验证部署

### 1. 检查Pod状态

```bash
# 查看所有Pod
kubectl get pods -n isbank

# 预期输出: 所有Pod状态为Running
NAME                                    READY   STATUS    RESTARTS   AGE
mysql-xxx                               1/1     Running   0          5m
eureka-server-xxx                       1/1     Running   0          4m
gateway-service-xxx                     1/1     Running   0          3m
account-service-xxx                     1/1     Running   0          2m
risk-service-xxx                        1/1     Running   0          2m
ledger-service-xxx                      1/1     Running   0          2m
notification-service-xxx                1/1     Running   0          2m
transfer-service-xxx                    1/1     Running   0          2m
frontend-xxx                            1/1     Running   0          1m
```

### 2. 检查Service

```bash
# 查看所有Service
kubectl get svc -n isbank

# 获取NodePort
kubectl get svc gateway-service -n isbank
kubectl get svc frontend -n isbank
```

### 3. 访问应用

```bash
# 获取节点IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# 访问地址
echo "Frontend:  http://${NODE_IP}:30000"
echo "Gateway:   http://${NODE_IP}:30080"
echo "Eureka:    http://${NODE_IP}:8761"
```

### 4. 测试API

```bash
# 通过Gateway访问账户服务
curl http://${NODE_IP}:30080/api/account/accounts

# 预期返回账户列表
```

---

## 🔧 故障排查

### 查看日志

```bash
# 查看Pod日志
kubectl logs -f deployment/account-service -n isbank

# 查看最近的事件
kubectl get events -n isbank --sort-by='.lastTimestamp'
```

### 常见问题

#### 1. Pod一直处于Pending状态

**原因**: 资源不足或PVC未绑定

```bash
# 检查Pod详情
kubectl describe pod <pod-name> -n isbank

# 检查PVC状态
kubectl get pvc -n isbank
```

#### 2. Pod启动失败 (CrashLoopBackOff)

**原因**: 应用启动错误或健康检查失败

```bash
# 查看日志
kubectl logs <pod-name> -n isbank

# 查看上一次运行的日志
kubectl logs <pod-name> -n isbank --previous
```

#### 3. 服务无法访问

**原因**: Service配置错误或网络问题

```bash
# 检查Service
kubectl get svc -n isbank
kubectl describe svc <service-name> -n isbank

# 检查Endpoints
kubectl get endpoints -n isbank
```

#### 4. 数据库连接失败

**原因**: MySQL未就绪或密码错误

```bash
# 检查MySQL状态
kubectl get pod -l app=mysql -n isbank

# 进入MySQL容器测试
kubectl exec -it deployment/mysql -n isbank -- mysql -uroot -pZmzzmz010627!
```

---

## 📊 监控和管理

### 查看资源使用

```bash
# 查看Pod资源使用
kubectl top pods -n isbank

# 查看节点资源使用
kubectl top nodes
```

### 扩缩容

```bash
# 扩展副本数
kubectl scale deployment account-service --replicas=3 -n isbank

# 查看副本状态
kubectl get deployment account-service -n isbank
```

### 滚动更新

```bash
# 更新镜像
kubectl set image deployment/account-service \
  account-service=1.94.151.57:85/test/isbank-account-service:v2 \
  -n isbank

# 查看更新状态
kubectl rollout status deployment/account-service -n isbank

# 回滚
kubectl rollout undo deployment/account-service -n isbank
```

---

## 📝 总结

### 已完成的工作

✅ 数据库架构拆分 - 每个服务独立数据库  
✅ 创建K8s配置文件 - application-k8s.yml  
✅ Docker镜像构建 - 多阶段构建优化  
✅ Kubernetes部署文件 - Deployment、Service、Secret  
✅ 自动化脚本 - 构建、推送、部署一键完成  
✅ 服务发现方案 - K8s Service + Eureka  
✅ 健康检查配置 - Liveness和Readiness探针  
✅ 资源限制配置 - CPU和内存限制  

### 下一步建议

1. **配置Ingress**: 统一对外暴露服务
2. **配置持久化存储**: 使用StorageClass动态分配PV
3. **配置日志收集**: ELK或Loki
4. **配置监控告警**: Prometheus + Grafana
5. **配置CI/CD**: Jenkins或GitLab CI
6. **配置备份策略**: 数据库定期备份

---

**部署完成时间**: 2025-11-20  
**文档版本**: 1.0  
**维护者**: ISBank Team

