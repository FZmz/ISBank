# ISBank 微服务系统 - Kubernetes 容器化部署

## 📖 概述

ISBank（韧性银行）是一个完整的微服务银行系统，现已完成Kubernetes容器化改造，支持一键部署到K8s集群。

## 🎯 容器化改造内容

### 1. 数据库架构调整 ✅

**改造前**: 所有服务共用一个 `greenbank` 数据库  
**改造后**: 每个微服务使用独立数据库

| 服务 | 数据库 |
|------|--------|
| account-service | greenbank_account |
| risk-service | greenbank_risk |
| ledger-service | greenbank_ledger |
| notification-service | greenbank_notification |
| transfer-service | greenbank_transfer |

**优点**:
- ✅ 符合微服务最佳实践
- ✅ 数据隔离，降低耦合
- ✅ 独立扩展和维护
- ✅ 故障隔离

### 2. 服务发现方案 ✅

**方案**: Kubernetes Service + Eureka 混合模式

- **K8s Service**: 用于服务间HTTP调用
  - 示例: `http://account-service.isbank.svc.cluster.local:8081`
- **Eureka**: 保留作为服务注册中心，提供可视化监控

**配置示例** (`transfer-service`):
```yaml
service:
  account: http://account-service.isbank.svc.cluster.local:8081
  risk: http://risk-service.isbank.svc.cluster.local:8082
  ledger: http://ledger-service.isbank.svc.cluster.local:8083
  notification: http://notification-service.isbank.svc.cluster.local:8084
```

### 3. Docker镜像 ✅

为所有8个服务创建了Dockerfile：

- **后端服务** (7个): 使用多阶段构建
  - 构建阶段: `maven:3.8.6-openjdk-8-slim`
  - 运行阶段: `openjdk:8-jre-alpine`
  - JVM优化: `-Xms256m -Xmx512m -XX:+UseG1GC`

- **前端应用**: 
  - 构建阶段: `node:18-alpine`
  - 运行阶段: `nginx:alpine`
  - 包含nginx反向代理配置

**镜像命名规范**:
```
1.94.151.57:85/test/isbank-<service-name>:latest
```

### 4. Kubernetes资源 ✅

为每个服务创建了完整的K8s资源：

#### Deployment
- Pod副本数配置
- 资源限制 (CPU/内存)
- 健康检查 (Liveness/Readiness)
- 环境变量配置
- InitContainer (等待依赖服务)

#### Service
- Gateway和Frontend: NodePort (对外暴露)
- 其他服务: ClusterIP (内部访问)

#### Secret
- 数据库密码
- 其他敏感信息

#### ConfigMap
- MySQL初始化脚本

### 5. 自动化脚本 ✅

| 脚本 | 功能 |
|------|------|
| `build-images.sh` | 构建所有Docker镜像 |
| `push-images.sh` | 推送镜像到仓库 |
| `deploy-k8s.sh` | 部署到Kubernetes |
| `undeploy-k8s.sh` | 清理K8s资源 |
| `deploy-all.sh` | 一键完整部署 |
| `generate-k8s-manifests.sh` | 生成K8s配置文件 |

## 🚀 快速开始

### 前置要求

- Docker 20.10+
- Kubernetes 1.20+
- kubectl 已配置
- 访问镜像仓库 `1.94.151.57:85`

### 一键部署

```bash
# 1. 登录镜像仓库
docker login 1.94.151.57:85

# 2. 执行一键部署
./scripts/deploy-all.sh
```

### 访问应用

```bash
# 获取节点IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# 访问地址
echo "前端应用: http://${NODE_IP}:30000"
echo "API网关:  http://${NODE_IP}:30080"
echo "Eureka:   http://${NODE_IP}:8761"
```

## 📁 项目结构

```
ISBank/
├── docker/                           # Docker镜像文件
│   ├── eureka-server/Dockerfile
│   ├── gateway-service/Dockerfile
│   ├── account-service/Dockerfile
│   ├── risk-service/Dockerfile
│   ├── ledger-service/Dockerfile
│   ├── notification-service/Dockerfile
│   ├── transfer-service/Dockerfile
│   └── frontend/
│       ├── Dockerfile
│       └── nginx.conf
├── k8s/                              # Kubernetes部署文件
│   ├── namespace/namespace.yaml
│   ├── mysql/
│   │   ├── mysql-deployment.yaml
│   │   └── init-databases.sql
│   ├── eureka-server/deployment.yaml
│   ├── gateway-service/deployment.yaml
│   ├── account-service/deployment.yaml
│   ├── risk-service/deployment.yaml
│   ├── ledger-service/deployment.yaml
│   ├── notification-service/deployment.yaml
│   ├── transfer-service/deployment.yaml
│   └── frontend/deployment.yaml
├── scripts/                          # 自动化脚本
│   ├── build-images.sh
│   ├── push-images.sh
│   ├── deploy-k8s.sh
│   ├── undeploy-k8s.sh
│   ├── deploy-all.sh
│   └── generate-k8s-manifests.sh
├── */src/main/resources/
│   └── application-k8s.yml          # K8s专用配置
├── K8S_DEPLOYMENT_GUIDE.md          # 详细部署文档
├── QUICK_DEPLOY.md                  # 快速部署指南
└── K8S_README.md                    # 本文件
```

## 🔧 配置说明

### 环境配置

每个服务都有两套配置：

1. **application.yml** - 本地开发环境
   - 数据库: `localhost:3306/greenbank`
   - Eureka: `http://localhost:8761/eureka/`

2. **application-k8s.yml** - Kubernetes环境
   - 数据库: `mysql.isbank.svc.cluster.local:3306/greenbank_<service>`
   - Eureka: `http://eureka-server.isbank.svc.cluster.local:8761/eureka/`

### 启动参数

Docker容器启动时自动使用K8s配置：

```bash
java -Dspring.profiles.active=k8s -jar app.jar
```

## 📊 资源配置

### Pod资源限制

| 服务类型 | Requests | Limits |
|---------|----------|--------|
| 后端服务 | 250m CPU, 512Mi 内存 | 1000m CPU, 1Gi 内存 |
| 前端应用 | 100m CPU, 128Mi 内存 | 500m CPU, 256Mi 内存 |
| MySQL | 500m CPU, 512Mi 内存 | 2000m CPU, 2Gi 内存 |

### 副本数

- Gateway: 2副本 (负载均衡)
- 业务服务: 2副本 (高可用)
- Eureka: 1副本 (单点)
- MySQL: 1副本 (StatefulSet)

## 🔍 监控和健康检查

### Liveness Probe (存活探针)

```yaml
livenessProbe:
  httpGet:
    path: /actuator/health
    port: 8081
  initialDelaySeconds: 90
  periodSeconds: 10
```

### Readiness Probe (就绪探针)

```yaml
readinessProbe:
  httpGet:
    path: /actuator/health
    port: 8081
  initialDelaySeconds: 60
  periodSeconds: 5
```

## 🛡️ 安全配置

### Secret管理

数据库密码等敏感信息存储在Kubernetes Secret中：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: account-service-secret
type: Opaque
stringData:
  mysql-password: Zmzzmz010627!
```

### 环境变量注入

```yaml
env:
- name: MYSQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: account-service-secret
      key: mysql-password
```

## 📚 文档

- **[K8S_DEPLOYMENT_GUIDE.md](K8S_DEPLOYMENT_GUIDE.md)** - 完整部署指南
- **[QUICK_DEPLOY.md](QUICK_DEPLOY.md)** - 快速部署参考
- **[K8S_README.md](K8S_README.md)** - 本文件

## ✅ 已完成的工作

- [x] 数据库架构拆分
- [x] 创建K8s配置文件 (application-k8s.yml)
- [x] Docker镜像构建 (多阶段构建)
- [x] Kubernetes部署文件 (Deployment/Service/Secret)
- [x] 自动化脚本 (构建/推送/部署)
- [x] 服务发现方案 (K8s Service + Eureka)
- [x] 健康检查配置
- [x] 资源限制配置
- [x] 完整文档

## 🎯 下一步建议

1. **Ingress配置** - 统一入口和域名管理
2. **持久化存储** - 使用StorageClass动态分配
3. **日志收集** - ELK或Loki
4. **监控告警** - Prometheus + Grafana
5. **CI/CD** - Jenkins或GitLab CI
6. **备份策略** - 数据库定期备份
7. **HPA** - 水平自动扩缩容

## 🆘 获取帮助

- 快速部署: 查看 [QUICK_DEPLOY.md](QUICK_DEPLOY.md)
- 详细文档: 查看 [K8S_DEPLOYMENT_GUIDE.md](K8S_DEPLOYMENT_GUIDE.md)
- 故障排查: 查看部署指南中的"故障排查"章节

---

**容器化完成时间**: 2025-11-20  
**版本**: 1.0  
**维护者**: ISBank Team

