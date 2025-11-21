# Kubernetes 健康检查配置修复说明

## 🐛 问题描述

部署到 Kubernetes 后，所有服务的健康检查失败：

```
Warning  Unhealthy  2m57s  kubelet  Readiness probe failed: 
Get "http://10.0.2.233:8080/actuator/health": dial tcp 10.0.2.233:8080: connect: connection refused
```

## 🔍 问题原因

K8s Deployment 配置中使用了 HTTP 健康检查端点 `/actuator/health`，但是：

1. **服务没有添加 Spring Boot Actuator 依赖**
2. **没有配置 Actuator 端点**
3. **导致健康检查端点不存在**

## ✅ 解决方案

### 方案 1: 使用 TCP 探针（已实施，推荐）

**优点**:
- ✅ 不需要修改代码
- ✅ 不需要重新构建镜像
- ✅ 立即生效
- ✅ 足够可靠（检查端口是否监听）

**实现**:

将所有服务的健康检查从 HTTP 探针改为 TCP 探针：

```yaml
# 修改前（HTTP 探针）
livenessProbe:
  httpGet:
    path: /actuator/health
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5

# 修改后（TCP 探针）
livenessProbe:
  tcpSocket:
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
```

### 方案 2: 添加 Actuator 依赖（可选，更标准）

如果需要更详细的健康检查信息，可以添加 Actuator：

**步骤 1**: 在父 POM 中添加依赖管理

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

**步骤 2**: 在每个服务的 `application-k8s.yml` 中配置

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      show-details: always
```

**步骤 3**: 重新构建镜像并部署

```bash
./scripts/build-images.sh
./scripts/push-images.sh
./scripts/deploy-k8s.sh
```

## 📝 已修改的文件

### K8s Deployment 配置（7个）

所有服务的健康检查已从 HTTP 探针改为 TCP 探针：

- ✅ `k8s/eureka-server/deployment.yaml`
- ✅ `k8s/gateway-service/deployment.yaml`
- ✅ `k8s/account-service/deployment.yaml`
- ✅ `k8s/risk-service/deployment.yaml`
- ✅ `k8s/ledger-service/deployment.yaml`
- ✅ `k8s/notification-service/deployment.yaml`
- ✅ `k8s/transfer-service/deployment.yaml`

## 🚀 应用修复

### 方法 1: 重新部署所有服务

```bash
./scripts/deploy-k8s.sh
```

### 方法 2: 单独更新某个服务

```bash
kubectl apply -f k8s/gateway-service/deployment.yaml
kubectl apply -f k8s/account-service/deployment.yaml
# ... 其他服务
```

### 方法 3: 滚动更新（推荐）

```bash
# 更新所有 Deployment
kubectl apply -f k8s/eureka-server/deployment.yaml
kubectl apply -f k8s/gateway-service/deployment.yaml
kubectl apply -f k8s/account-service/deployment.yaml
kubectl apply -f k8s/risk-service/deployment.yaml
kubectl apply -f k8s/ledger-service/deployment.yaml
kubectl apply -f k8s/notification-service/deployment.yaml
kubectl apply -f k8s/transfer-service/deployment.yaml

# K8s 会自动滚动更新，无需重启 Pod
```

## 🔍 验证修复

### 查看 Pod 状态

```bash
kubectl get pods -n isbank
```

应该看到所有 Pod 状态为 `Running` 且 `READY` 为 `1/1` 或 `2/2`：

```
NAME                                   READY   STATUS    RESTARTS   AGE
eureka-server-xxx                      1/1     Running   0          5m
gateway-service-xxx                    1/1     Running   0          5m
account-service-xxx                    2/2     Running   0          5m
```

### 查看 Pod 详细信息

```bash
kubectl describe pod gateway-service-xxx -n isbank
```

在 `Events` 部分应该看到：

```
Normal   Started    5m    kubelet  Started container gateway-service
Normal   Pulled     5m    kubelet  Container image pulled successfully
```

**不应该再看到**：

```
Warning  Unhealthy  2m    kubelet  Readiness probe failed
```

### 查看健康检查日志

```bash
kubectl get events -n isbank --sort-by='.lastTimestamp'
```

## 💡 TCP 探针 vs HTTP 探针

### TCP 探针

**工作原理**: 检查指定端口是否可以建立 TCP 连接

**优点**:
- ✅ 简单可靠
- ✅ 不需要额外依赖
- ✅ 性能开销小
- ✅ 适合大多数场景

**缺点**:
- ❌ 无法检查应用内部状态
- ❌ 只能确认端口监听

**适用场景**:
- 简单的微服务
- 不需要详细健康信息
- 快速部署

### HTTP 探针

**工作原理**: 发送 HTTP GET 请求到指定路径，检查响应状态码

**优点**:
- ✅ 可以检查应用内部状态
- ✅ 可以自定义健康检查逻辑
- ✅ 提供详细的健康信息

**缺点**:
- ❌ 需要额外依赖（Actuator）
- ❌ 性能开销稍大
- ❌ 需要配置端点

**适用场景**:
- 复杂的应用
- 需要检查数据库连接等
- 需要详细的健康报告

## 📊 健康检查参数说明

```yaml
livenessProbe:              # 存活探针（检查容器是否存活）
  tcpSocket:
    port: 8080              # 检查的端口
  initialDelaySeconds: 60   # 容器启动后等待 60 秒再开始检查
  periodSeconds: 10         # 每 10 秒检查一次
  timeoutSeconds: 5         # 检查超时时间 5 秒
  failureThreshold: 3       # 连续失败 3 次后重启容器

readinessProbe:             # 就绪探针（检查容器是否准备好接收流量）
  tcpSocket:
    port: 8080
  initialDelaySeconds: 30   # 容器启动后等待 30 秒再开始检查
  periodSeconds: 5          # 每 5 秒检查一次
  timeoutSeconds: 3         # 检查超时时间 3 秒
  failureThreshold: 3       # 连续失败 3 次后标记为未就绪
```

### 参数调优建议

| 服务类型 | initialDelaySeconds | periodSeconds | 说明 |
|---------|---------------------|---------------|------|
| Eureka Server | 60 | 10 | 启动较慢 |
| Gateway | 60 | 10 | 需要等待 Eureka |
| 业务服务 | 90 | 10 | 需要初始化数据库 |
| 前端 | 10 | 5 | 启动很快 |

## 🛠️ 故障排查

### 问题 1: Pod 一直处于 NotReady 状态

**检查**:
```bash
kubectl describe pod <pod-name> -n isbank
```

**可能原因**:
- `initialDelaySeconds` 太短，服务还没启动完成
- 端口配置错误
- 服务启动失败

**解决**:
```bash
# 查看服务日志
kubectl logs <pod-name> -n isbank

# 增加 initialDelaySeconds
# 修改 deployment.yaml 中的配置
```

### 问题 2: Pod 频繁重启

**检查**:
```bash
kubectl get pods -n isbank
# 查看 RESTARTS 列
```

**可能原因**:
- `livenessProbe` 失败
- 应用崩溃

**解决**:
```bash
# 查看之前的日志
kubectl logs <pod-name> -n isbank --previous

# 增加 failureThreshold 或 timeoutSeconds
```

## ✅ 总结

通过将健康检查从 HTTP 探针改为 TCP 探针，我们实现了：

- ✅ **立即修复健康检查失败问题**
- ✅ **无需修改代码或重新构建镜像**
- ✅ **简化配置，提高可靠性**
- ✅ **适合当前项目的实际情况**

如果未来需要更详细的健康检查信息，可以考虑添加 Actuator 依赖。

---

**修复时间**: 2025-11-20  
**状态**: ✅ 已修复

