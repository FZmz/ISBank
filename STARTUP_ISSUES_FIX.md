# 启动问题修复说明

## 🔍 问题汇总

### 问题1: Risk Service YAML 配置格式错误

**错误信息**:
```
org.yaml.snakeyaml.parser.ParserException: expected '<document start>', but found '<block mapping start>'
 in 'reader', line 4, column 1:
    spring:
    ^
```

**原因**: `risk-service/src/main/resources/application.yml` 第1行缺少 `server:` 标签

**修复前**:
```yaml
 
  port: 8082

spring:
```

**修复后**:
```yaml
server:
  port: 8082

spring:
```

**状态**: ✅ 已修复

---

### 问题2: Gateway 无法连接 Eureka Server

**错误信息**:
```
com.netflix.discovery.shared.transport.TransportException: Cannot execute request on any known server
```

**原因**: Eureka Server 未启动或启动失败

**解决方案**: 
1. 确保 Eureka Server 先启动
2. 等待 Eureka Server 完全启动后再启动其他服务
3. 检查 Eureka Server 是否在 8761 端口正常运行

**状态**: ⚠️ 需要按正确顺序启动服务

---

## ✅ 正确的启动顺序

### 方式1: 手动逐个启动 (推荐用于调试)

#### 步骤1: 启动 Eureka Server

```bash
cd eureka-server
mvn clean compile
mvn spring-boot:run
```

**等待看到以下日志**:
```
Started EurekaServerApplication in X seconds
```

**验证**: 访问 http://localhost:8761，应该看到 Eureka 控制台

#### 步骤2: 启动 Gateway Service

```bash
# 新开一个终端
cd gateway-service
mvn clean compile
mvn spring-boot:run
```

**等待看到**:
```
Netty started on port(s): 8080
DiscoveryClient_GATEWAY-SERVICE - registration status: 204
```

#### 步骤3: 启动其他微服务

```bash
# Account Service
cd account-service
mvn clean compile
mvn spring-boot:run

# Risk Service
cd risk-service
mvn clean compile
mvn spring-boot:run

# Ledger Service
cd ledger-service
mvn clean compile
mvn spring-boot:run

# Notification Service
cd notification-service
mvn clean compile
mvn spring-boot:run

# Transfer Service
cd transfer-service
mvn clean compile
mvn spring-boot:run
```

**每个服务启动后，检查 Eureka 控制台**: http://localhost:8761

应该看到服务逐个注册成功。

---

### 方式2: 使用改进的启动脚本

我已经创建了一个改进的启动脚本 `start-all-safe.sh`，它会：
1. 先启动 Eureka Server
2. 等待 Eureka 完全启动
3. 再启动其他服务

```bash
chmod +x start-all-safe.sh
./start-all-safe.sh
```

---

## 🔧 常见问题排查

### Q1: 如何确认 Eureka Server 启动成功?

**A**: 
```bash
# 方法1: 访问 Eureka 控制台
curl http://localhost:8761

# 方法2: 检查端口
netstat -tuln | grep 8761

# 方法3: 查看日志
tail -f eureka-server/logs/eureka.log
```

### Q2: 服务注册失败怎么办?

**A**: 检查以下几点:
1. Eureka Server 是否启动成功
2. 服务的 `application.yml` 中 Eureka 地址是否正确
3. 网络连接是否正常
4. 防火墙是否阻止了连接

### Q3: 如何停止所有服务?

**A**:
```bash
# 使用停止脚本
./stop-all.sh

# 或手动停止
pkill -f eureka-server
pkill -f gateway-service
pkill -f account-service
pkill -f risk-service
pkill -f ledger-service
pkill -f notification-service
pkill -f transfer-service
```

### Q4: 数据库连接失败怎么办?

**A**:
```bash
# 1. 检查 MySQL 是否运行
systemctl status mysql

# 2. 检查数据库是否存在
mysql -u root -p
USE greenbank;
SHOW TABLES;

# 3. 如果表不存在，重新初始化
./init-db.sh
```

---

## 📊 服务启动检查清单

启动每个服务后，使用此清单验证:

### Eureka Server (8761)
- [ ] 端口 8761 已监听
- [ ] 访问 http://localhost:8761 显示控制台
- [ ] 日志无错误

### Gateway Service (8080)
- [ ] 端口 8080 已监听
- [ ] 在 Eureka 控制台看到 GATEWAY-SERVICE
- [ ] 日志显示 "registration status: 204"

### Account Service (8081)
- [ ] 端口 8081 已监听
- [ ] 在 Eureka 控制台看到 ACCOUNT-SERVICE
- [ ] 数据库表已创建
- [ ] 访问 http://localhost:8081/doc.html 显示 API 文档

### Risk Service (8082)
- [ ] 端口 8082 已监听
- [ ] 在 Eureka 控制台看到 RISK-SERVICE
- [ ] 数据库表已创建
- [ ] YAML 配置格式正确

### Ledger Service (8083)
- [ ] 端口 8083 已监听
- [ ] 在 Eureka 控制台看到 LEDGER-SERVICE
- [ ] 数据库表已创建

### Notification Service (8084)
- [ ] 端口 8084 已监听
- [ ] 在 Eureka 控制台看到 NOTIFICATION-SERVICE
- [ ] 数据库表已创建

### Transfer Service (8085)
- [ ] 端口 8085 已监听
- [ ] 在 Eureka 控制台看到 TRANSFER-SERVICE
- [ ] 数据库表已创建

---

## 🚀 快速验证

所有服务启动后，执行以下测试:

```bash
# 1. 检查 Eureka
curl http://localhost:8761/eureka/apps

# 2. 通过 Gateway 访问 Account Service
curl http://localhost:8080/api/account/accounts

# 3. 访问 API 文档
curl http://localhost:8080/doc.html

# 4. 创建转账测试
curl -X POST http://localhost:8080/api/transfer/transfers \
  -H "Content-Type: application/json" \
  -d '{
    "fromAccountId": 1,
    "toAccountId": 2,
    "amount": 100,
    "currency": "CNY",
    "remark": "测试转账"
  }'
```

---

## 📝 已修复的文件

| 文件 | 问题 | 状态 |
|------|------|------|
| `risk-service/src/main/resources/application.yml` | YAML 格式错误 | ✅ 已修复 |

---

## 💡 最佳实践

### 1. 启动顺序很重要

```
Eureka Server → Gateway → 其他微服务
```

### 2. 等待服务完全启动

不要在服务还在启动时就启动下一个服务，等待看到:
```
Started XxxApplication in X seconds
```

### 3. 使用健康检查

```bash
# 检查服务健康状态
curl http://localhost:8081/actuator/health
```

### 4. 查看日志

每个服务的日志在 `logs/` 目录下:
```bash
tail -f logs/account.log
tail -f logs/risk.log
```

---

## ✅ 总结

**已修复**:
- ✅ Risk Service YAML 配置格式错误

**需要注意**:
- ⚠️ 必须先启动 Eureka Server
- ⚠️ 等待每个服务完全启动后再启动下一个
- ⚠️ 检查 Eureka 控制台确认服务注册成功

**现在可以按正确顺序启动所有服务了！** 🎉

---

**修复完成时间**: 2025-11-20  
**影响范围**: Risk Service, 启动流程  
**向后兼容**: 是

