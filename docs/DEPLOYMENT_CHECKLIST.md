# ISBank Kubernetes 部署检查清单

## 📋 部署前检查

### 1. 环境准备

- [ ] Docker已安装 (版本 >= 20.10)
  ```bash
  docker --version
  ```

- [ ] Kubernetes集群可用 (版本 >= 1.20)
  ```bash
  kubectl version
  kubectl cluster-info
  ```

- [ ] kubectl已配置并可连接集群
  ```bash
  kubectl get nodes
  ```

- [ ] 镜像仓库可访问 (1.94.151.57:85)
  ```bash
  docker login 1.94.151.57:85
  ```

- [ ] 集群资源充足
  - 至少 4核 CPU
  - 至少 8GB 内存
  - 至少 20GB 存储空间

### 2. 文件完整性检查

#### Docker文件
- [ ] docker/eureka-server/Dockerfile
- [ ] docker/gateway-service/Dockerfile
- [ ] docker/account-service/Dockerfile
- [ ] docker/risk-service/Dockerfile
- [ ] docker/ledger-service/Dockerfile
- [ ] docker/notification-service/Dockerfile
- [ ] docker/transfer-service/Dockerfile
- [ ] docker/frontend/Dockerfile
- [ ] docker/frontend/nginx.conf

#### Kubernetes配置文件
- [ ] k8s/namespace/namespace.yaml
- [ ] k8s/mysql/mysql-deployment.yaml
- [ ] k8s/mysql/init-databases.sql
- [ ] k8s/eureka-server/deployment.yaml
- [ ] k8s/gateway-service/deployment.yaml
- [ ] k8s/account-service/deployment.yaml
- [ ] k8s/risk-service/deployment.yaml
- [ ] k8s/ledger-service/deployment.yaml
- [ ] k8s/notification-service/deployment.yaml
- [ ] k8s/transfer-service/deployment.yaml
- [ ] k8s/frontend/deployment.yaml

#### 应用配置文件
- [ ] eureka-server/src/main/resources/application-k8s.yml
- [ ] gateway-service/src/main/resources/application-k8s.yml
- [ ] account-service/src/main/resources/application-k8s.yml
- [ ] risk-service/src/main/resources/application-k8s.yml
- [ ] ledger-service/src/main/resources/application-k8s.yml
- [ ] notification-service/src/main/resources/application-k8s.yml
- [ ] transfer-service/src/main/resources/application-k8s.yml

#### 自动化脚本
- [ ] scripts/build-images.sh (可执行)
- [ ] scripts/push-images.sh (可执行)
- [ ] scripts/deploy-k8s.sh (可执行)
- [ ] scripts/undeploy-k8s.sh (可执行)
- [ ] scripts/deploy-all.sh (可执行)

---

## 🚀 部署步骤

### 步骤1: 构建镜像

```bash
./scripts/build-images.sh
```

**检查点**:
- [ ] 所有8个镜像构建成功
- [ ] 无构建错误
- [ ] 镜像已正确标记

**验证**:
```bash
docker images | grep isbank
```

### 步骤2: 推送镜像

```bash
./scripts/push-images.sh
```

**检查点**:
- [ ] 已登录镜像仓库
- [ ] 所有镜像推送成功
- [ ] 无网络错误

**验证**:
```bash
# 在镜像仓库中验证镜像存在
```

### 步骤3: 部署到Kubernetes

```bash
./scripts/deploy-k8s.sh
```

**检查点**:
- [ ] 命名空间创建成功
- [ ] MySQL部署成功
- [ ] Eureka Server部署成功
- [ ] Gateway部署成功
- [ ] 所有业务服务部署成功
- [ ] 前端部署成功

**验证**:
```bash
kubectl get pods -n isbank
kubectl get svc -n isbank
```

---

## ✅ 部署后验证

### 1. Pod状态检查

```bash
kubectl get pods -n isbank
```

**预期结果**: 所有Pod状态为 `Running`，READY为 `1/1` 或 `2/2`

- [ ] mysql-xxx: Running
- [ ] eureka-server-xxx: Running
- [ ] gateway-service-xxx: Running (2个副本)
- [ ] account-service-xxx: Running (2个副本)
- [ ] risk-service-xxx: Running (2个副本)
- [ ] ledger-service-xxx: Running (2个副本)
- [ ] notification-service-xxx: Running (2个副本)
- [ ] transfer-service-xxx: Running (2个副本)
- [ ] frontend-xxx: Running (2个副本)

### 2. Service状态检查

```bash
kubectl get svc -n isbank
```

**检查点**:
- [ ] mysql: ClusterIP
- [ ] eureka-server: ClusterIP
- [ ] gateway-service: NodePort (30080)
- [ ] account-service: ClusterIP
- [ ] risk-service: ClusterIP
- [ ] ledger-service: ClusterIP
- [ ] notification-service: ClusterIP
- [ ] transfer-service: ClusterIP
- [ ] frontend: NodePort (30000)

### 3. 日志检查

```bash
# 检查各服务日志
kubectl logs deployment/eureka-server -n isbank
kubectl logs deployment/gateway-service -n isbank
kubectl logs deployment/account-service -n isbank
```

**检查点**:
- [ ] 无ERROR级别日志
- [ ] 服务成功注册到Eureka
- [ ] 数据库连接成功
- [ ] 应用启动完成

### 4. 访问测试

#### 获取访问地址

```bash
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Frontend:  http://${NODE_IP}:30000"
echo "Gateway:   http://${NODE_IP}:30080"
echo "Eureka:    http://${NODE_IP}:8761"
```

#### 测试Eureka

- [ ] 访问 Eureka 控制台
- [ ] 确认所有服务已注册
- [ ] 服务状态为 UP

#### 测试Gateway

```bash
curl http://${NODE_IP}:30080/api/account/accounts
```

- [ ] API响应正常
- [ ] 返回账户列表

#### 测试前端

- [ ] 访问前端页面
- [ ] 页面加载正常
- [ ] 可以查看账户列表
- [ ] 可以创建账户
- [ ] 可以发起转账

### 5. 功能测试

#### 账户管理
- [ ] 创建新账户
- [ ] 查询账户列表
- [ ] 查询账户详情

#### 转账功能
- [ ] 发起转账
- [ ] 转账成功
- [ ] 余额正确扣减和增加
- [ ] 生成总账记录
- [ ] 发送通知

#### 风控检查
- [ ] 余额不足时转账失败
- [ ] 风控规则生效

---

## 🔧 故障排查

### Pod无法启动

```bash
# 查看Pod详情
kubectl describe pod <pod-name> -n isbank

# 查看Pod日志
kubectl logs <pod-name> -n isbank

# 查看事件
kubectl get events -n isbank --sort-by='.lastTimestamp'
```

### 服务无法访问

```bash
# 检查Service
kubectl get svc -n isbank
kubectl describe svc <service-name> -n isbank

# 检查Endpoints
kubectl get endpoints -n isbank
```

### 数据库连接失败

```bash
# 检查MySQL状态
kubectl get pod -l app=mysql -n isbank
kubectl logs deployment/mysql -n isbank

# 进入MySQL容器测试
kubectl exec -it deployment/mysql -n isbank -- mysql -uroot -pZmzzmz010627!
```

---

## 🧹 清理资源

如果需要重新部署或清理环境:

```bash
./scripts/undeploy-k8s.sh
```

**确认**:
- [ ] 所有Pod已删除
- [ ] 所有Service已删除
- [ ] 命名空间已删除

---

## 📊 性能监控

### 资源使用

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

# 验证
kubectl get deployment account-service -n isbank
```

---

## ✅ 部署完成确认

- [ ] 所有Pod运行正常
- [ ] 所有Service可访问
- [ ] Eureka显示所有服务
- [ ] API测试通过
- [ ] 前端功能正常
- [ ] 转账流程完整
- [ ] 无错误日志

**恭喜！ISBank微服务系统已成功部署到Kubernetes集群！** 🎉

---

**检查清单版本**: 1.0  
**最后更新**: 2025-11-20

