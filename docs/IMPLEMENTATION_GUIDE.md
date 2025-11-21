# ISBank 微服务银行系统实现指南

## 项目概述

本项目是一个完整的微服务银行系统,包含以下核心服务:

1. **eureka-server** (8761) - 服务注册中心
2. **account-service** (8081) - 账户服务
3. **risk-service** (8082) - 风控服务  
4. **ledger-service** (8083) - 总账服务
5. **notification-service** (8084) - 通知服务
6. **transfer-service** (8085) - 转账服务(核心编排服务)
7. **gateway-service** (8080) - API网关服务

## 已完成的服务

### 1. 公共模块 (common)
- ✅ Result 统一响应结果
- ✅ BusinessException 业务异常
- ✅ AccountStatus 账户状态枚举
- ✅ TransferStatus 转账状态枚举
- ✅ TransferType 转账类型枚举
- ✅ Direction 借贷方向枚举

### 2. Eureka Server (服务注册中心)
- ✅ 完整配置和启动类

### 3. Account Service (账户服务)
- ✅ Account 实体
- ✅ AccountLedger 分户账实体
- ✅ AccountService 业务逻辑
- ✅ AccountController 对外接口
- ✅ InternalAccountController 内部接口(扣款/入账)
- ✅ 数据库初始化脚本
- ✅ Knife4j API文档配置

### 4. Risk Service (风控服务)
- ✅ RiskDecision 实体
- ✅ RiskService 风控检查逻辑
- ✅ RiskController 对外接口
- ✅ 数据库初始化脚本
- ✅ Knife4j API文档配置

### 5. Ledger Service (总账服务) - 部分完成
- ✅ 基础配置和启动类
- ⏳ 需要补充实体、Service、Controller

### 6. Notification Service (通知服务) - 待实现
### 7. Transfer Service (转账服务) - 待实现
### 8. Gateway Service (网关服务) - 待实现

## 待补充的代码

由于代码量较大,以下服务需要继续补充完整代码:

### Ledger Service 需要补充:
1. LedgerEntry 实体类
2. LedgerAccount 实体类
3. LedgerService 业务逻辑
4. LedgerController 控制器
5. schema.sql 和 data.sql

### Notification Service 需要创建:
1. 完整的服务结构
2. Notification 实体
3. NotificationService 业务逻辑
4. NotificationController 控制器
5. 数据库脚本

### Transfer Service 需要创建:
1. 完整的服务结构
2. Transfer 实体
3. TransferService 核心编排逻辑
4. TransferController 控制器
5. 集成 RestTemplate 调用其他服务
6. 数据库脚本

### Gateway Service 需要创建:
1. Spring Cloud Gateway 配置
2. 路由规则配置
3. Knife4j 聚合文档配置

## 数据库配置

所有服务使用同一个MySQL数据库:
- 数据库名: `greenbank`
- 地址: `localhost:3306`
- 用户名: `root`
- 密码: `root`

## 启动顺序

1. 启动 MySQL 数据库
2. 启动 Eureka Server (8761)
3. 启动各个业务服务 (8081-8085)
4. 启动 Gateway Service (8080)

## API文档访问

- Account Service: http://localhost:8081/doc.html
- Risk Service: http://localhost:8082/doc.html
- Ledger Service: http://localhost:8083/doc.html
- Notification Service: http://localhost:8084/doc.html
- Transfer Service: http://localhost:8085/doc.html
- Gateway (聚合): http://localhost:8080/doc.html

## 下一步工作

1. 补充 Ledger Service 完整代码
2. 创建 Notification Service
3. 创建 Transfer Service (核心)
4. 创建 Gateway Service
5. 开发前端 Vue3 应用
6. 编写单元测试
7. 集成测试

## 技术栈

- Java 8
- Spring Boot 2.3.12
- Spring Cloud Hoxton.SR12
- MyBatis Plus 3.4.3
- MySQL 8.0
- Knife4j 2.0.9
- Vue3 + TypeScript (前端)

