# ISBank 项目结构说明

## 📁 项目目录树

```
ISBank/
│
├── 📄 pom.xml                              # Maven父POM,管理所有子模块
├── 📄 README.md                            # 项目主文档
├── 📄 QUICK_START.md                       # 5分钟快速启动指南
├── 📄 README_DEPLOYMENT.md                 # 详细部署指南
├── 📄 INTEGRATION_TEST_GUIDE.md            # 集成测试指南
├── 📄 PROJECT_SUMMARY.md                   # 项目总结
├── 📄 DELIVERY_CHECKLIST.md                # 交付清单
├── 📄 PROJECT_COMPLETION_REPORT.md         # 项目完成报告
├── 📄 PROJECT_STRUCTURE.md                 # 项目结构说明(本文件)
├── 🔧 start-all.sh                         # 一键启动脚本
├── 🔧 stop-all.sh                          # 一键停止脚本
├── 🔧 test-api.sh                          # API测试脚本
│
├── 📦 common/                              # 公共模块
│   ├── pom.xml
│   └── src/main/java/com/isbank/common/
│       ├── response/
│       │   └── Result.java                 # 统一响应封装
│       ├── exception/
│       │   └── BusinessException.java      # 业务异常
│       └── enums/
│           ├── AccountStatus.java          # 账户状态枚举
│           ├── TransferStatus.java         # 转账状态枚举
│           ├── TransferType.java           # 转账类型枚举
│           └── Direction.java              # 借贷方向枚举
│
├── 📦 eureka-server/                       # 服务注册中心 (端口:8761)
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/isbank/eureka/
│       │   └── EurekaServerApplication.java
│       └── resources/
│           └── application.yml
│
├── 📦 gateway-service/                     # API网关 (端口:8080)
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/isbank/gateway/
│       │   └── GatewayServiceApplication.java
│       └── resources/
│           └── application.yml             # 路由配置、CORS配置
│
├── 📦 account-service/                     # 账户服务 (端口:8081)
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/isbank/account/
│       │   │   ├── AccountServiceApplication.java
│       │   │   ├── config/
│       │   │   │   └── Knife4jConfig.java
│       │   │   ├── entity/
│       │   │   │   ├── Account.java
│       │   │   │   └── AccountLedger.java
│       │   │   ├── mapper/
│       │   │   │   ├── AccountMapper.java
│       │   │   │   └── AccountLedgerMapper.java
│       │   │   ├── service/
│       │   │   │   └── AccountService.java
│       │   │   ├── controller/
│       │   │   │   ├── AccountController.java
│       │   │   │   └── InternalAccountController.java
│       │   │   └── dto/
│       │   │       ├── CreateAccountRequest.java
│       │   │       ├── DebitRequest.java
│       │   │       └── CreditRequest.java
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── schema.sql              # 数据表结构
│       │       └── data.sql                # 测试数据
│       └── test/java/com/isbank/account/
│           └── service/
│               └── AccountServiceTest.java
│
├── 📦 risk-service/                        # 风控服务 (端口:8082)
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/isbank/risk/
│       │   │   ├── RiskServiceApplication.java
│       │   │   ├── config/Knife4jConfig.java
│       │   │   ├── entity/RiskDecision.java
│       │   │   ├── mapper/RiskDecisionMapper.java
│       │   │   ├── service/RiskService.java
│       │   │   ├── controller/RiskController.java
│       │   │   └── dto/
│       │   │       ├── RiskCheckRequest.java
│       │   │       └── RiskCheckResponse.java
│       │   └── resources/
│       │       ├── application.yml
│       │       └── schema.sql
│       └── test/java/com/isbank/risk/
│           └── service/RiskServiceTest.java
│
├── 📦 ledger-service/                      # 总账服务 (端口:8083)
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/isbank/ledger/
│       │   │   ├── LedgerServiceApplication.java
│       │   │   ├── config/Knife4jConfig.java
│       │   │   ├── entity/
│       │   │   │   ├── LedgerAccount.java
│       │   │   │   └── LedgerEntry.java
│       │   │   ├── mapper/
│       │   │   │   ├── LedgerAccountMapper.java
│       │   │   │   └── LedgerEntryMapper.java
│       │   │   ├── service/LedgerService.java
│       │   │   ├── controller/LedgerController.java
│       │   │   └── dto/
│       │   │       ├── PostEntriesRequest.java
│       │   │       └── LedgerEntryDto.java
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── schema.sql
│       │       └── data.sql
│       └── test/java/com/isbank/ledger/
│           └── service/LedgerServiceTest.java
│
├── 📦 notification-service/                # 通知服务 (端口:8084)
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/isbank/notification/
│       │   │   ├── NotificationServiceApplication.java
│       │   │   ├── config/Knife4jConfig.java
│       │   │   ├── entity/Notification.java
│       │   │   ├── mapper/NotificationMapper.java
│       │   │   ├── service/NotificationService.java
│       │   │   ├── controller/NotificationController.java
│       │   │   └── dto/SendNotificationRequest.java
│       │   └── resources/
│       │       ├── application.yml
│       │       └── schema.sql
│       └── test/java/com/isbank/notification/
│           └── service/NotificationServiceTest.java
│
├── 📦 transfer-service/                    # 转账服务 (端口:8085)
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/isbank/transfer/
│       │   │   ├── TransferServiceApplication.java
│       │   │   ├── config/
│       │   │   │   ├── Knife4jConfig.java
│       │   │   │   └── RestTemplateConfig.java
│       │   │   ├── entity/Transfer.java
│       │   │   ├── mapper/TransferMapper.java
│       │   │   ├── service/TransferService.java
│       │   │   ├── controller/TransferController.java
│       │   │   └── dto/CreateTransferRequest.java
│       │   └── resources/
│       │       ├── application.yml
│       │       └── schema.sql
│       └── test/java/com/isbank/transfer/
│           └── service/TransferServiceTest.java
│
└── 📦 frontend/                            # 前端应用 (端口:3000)
    ├── package.json                        # NPM依赖配置
    ├── vite.config.ts                      # Vite构建配置
    ├── tsconfig.json                       # TypeScript配置
    ├── tsconfig.node.json
    ├── index.html                          # HTML入口
    └── src/
        ├── main.ts                         # 应用入口
        ├── App.vue                         # 根组件
        ├── router/
        │   └── index.ts                    # 路由配置
        ├── api/
        │   ├── request.ts                  # Axios封装
        │   ├── account.ts                  # 账户API
        │   └── transfer.ts                 # 转账API
        └── views/
            ├── Layout.vue                  # 布局组件
            ├── Dashboard.vue               # 监控中心
            ├── Account.vue                 # 账户管理
            └── Transfer.vue                # 交易中心
```

## 📊 模块说明

### 后端模块

| 模块 | 职责 | 关键技术 |
|------|------|---------|
| common | 公共组件、枚举、异常 | - |
| eureka-server | 服务注册与发现 | Eureka |
| gateway-service | API网关、路由转发 | Spring Cloud Gateway |
| account-service | 账户管理、余额操作 | MyBatis Plus |
| risk-service | 风险控制、交易审核 | - |
| ledger-service | 总账管理、复式记账 | - |
| notification-service | 消息通知 | - |
| transfer-service | 转账编排、流程控制 | RestTemplate |

### 前端模块

| 目录 | 职责 |
|------|------|
| api/ | API接口封装 |
| router/ | 路由配置 |
| views/ | 页面组件 |

## 🗄️ 数据库表

| 表名 | 所属服务 | 用途 |
|------|---------|------|
| accounts | account-service | 账户信息 |
| account_ledger | account-service | 账户分户账 |
| transfers | transfer-service | 转账记录 |
| risk_decisions | risk-service | 风控决策 |
| ledger_accounts | ledger-service | 总账科目 |
| ledger_entries | ledger-service | 总账分录 |
| notifications | notification-service | 通知记录 |

## 🔗 服务依赖关系

```
transfer-service (编排者)
    ├── → risk-service (风控检查)
    ├── → account-service (扣款/入账)
    ├── → ledger-service (记总账)
    └── → notification-service (发送通知)
```

## 📝 配置文件说明

### application.yml 核心配置项

```yaml
server:
  port: 808X                    # 服务端口

spring:
  application:
    name: xxx-service           # 服务名称
  datasource:
    url: jdbc:mysql://localhost:3306/greenbank
    username: root
    password: Zmzzmz010627!
  sql:
    init:
      mode: always              # 自动执行SQL脚本

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

## 🚀 启动顺序

1. **Eureka Server** (8761) - 必须第一个启动
2. **业务服务** (8081-8085) - 可并行启动
   - Account Service
   - Risk Service
   - Ledger Service
   - Notification Service
   - Transfer Service
3. **Gateway Service** (8080) - 最后启动
4. **Frontend** (3000) - 独立启动

## 📚 文档索引

- **快速开始**: [QUICK_START.md](QUICK_START.md)
- **部署指南**: [README_DEPLOYMENT.md](README_DEPLOYMENT.md)
- **测试指南**: [INTEGRATION_TEST_GUIDE.md](INTEGRATION_TEST_GUIDE.md)
- **项目总结**: [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
- **交付清单**: [DELIVERY_CHECKLIST.md](DELIVERY_CHECKLIST.md)
- **完成报告**: [PROJECT_COMPLETION_REPORT.md](PROJECT_COMPLETION_REPORT.md)

