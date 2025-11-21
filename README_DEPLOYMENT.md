# ISBank 微服务银行系统 - 部署指南

## 项目概述

ISBank是一个完整的微服务银行系统,包含7个后端微服务和1个Vue3前端应用。

### 技术栈
- **后端**: Java 8, Spring Boot 2.3.12, Spring Cloud Hoxton.SR12, MyBatis Plus
- **前端**: Vue 3, TypeScript, Element Plus, Vite
- **数据库**: MySQL 8.0
- **服务注册**: Eureka Server
- **API网关**: Spring Cloud Gateway
- **API文档**: Knife4j

## 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                      前端 Vue3 应用                          │
│                    http://localhost:3000                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  API Gateway (8080)                          │
│              Spring Cloud Gateway + Knife4j                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
┌───────▼────┐  ┌─────▼─────┐  ┌────▼──────┐
│ Account    │  │ Transfer  │  │ Risk      │
│ Service    │  │ Service   │  │ Service   │
│ (8081)     │  │ (8085)    │  │ (8082)    │
└────────────┘  └───────────┘  └───────────┘
        │              │              │
┌───────▼────┐  ┌─────▼─────┐  ┌────▼──────┐
│ Ledger     │  │Notification│  │ Eureka    │
│ Service    │  │ Service   │  │ Server    │
│ (8083)     │  │ (8084)    │  │ (8761)    │
└────────────┘  └───────────┘  └───────────┘
        │              │              │
        └──────────────┼──────────────┘
                       │
                ┌──────▼──────┐
                │   MySQL     │
                │  greenbank  │
                └─────────────┘
```

## 前置要求

1. **JDK 8** - 确保已安装并配置JAVA_HOME
2. **Maven 3.6+** - 用于构建Java项目
3. **Node.js 16+** - 用于运行前端应用
4. **MySQL 8.0** - 数据库服务

## 数据库准备

### 1. 创建数据库

```sql
CREATE DATABASE IF NOT EXISTS greenbank 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
```

### 2. 配置数据库连接

确保MySQL运行在 `localhost:3306`,用户名 `root`,密码 `root`。

如需修改,请更新各服务的 `application.yml` 文件中的数据库配置。

## 后端服务启动

### 方式一:使用Maven命令(推荐用于开发)

按以下顺序启动服务:

```bash
# 1. 启动Eureka服务注册中心
cd eureka-server
mvn spring-boot:run

# 2. 启动账户服务
cd ../account-service
mvn spring-boot:run

# 3. 启动风控服务
cd ../risk-service
mvn spring-boot:run

# 4. 启动总账服务
cd ../ledger-service
mvn spring-boot:run

# 5. 启动通知服务
cd ../notification-service
mvn spring-boot:run

# 6. 启动转账服务
cd ../transfer-service
mvn spring-boot:run

# 7. 启动API网关
cd ../gateway-service
mvn spring-boot:run
```

### 方式二:打包后运行

```bash
# 在项目根目录执行
mvn clean package -DskipTests

# 启动各服务
java -jar eureka-server/target/eureka-server-1.0.0-SNAPSHOT.jar
java -jar account-service/target/account-service-1.0.0-SNAPSHOT.jar
java -jar risk-service/target/risk-service-1.0.0-SNAPSHOT.jar
java -jar ledger-service/target/ledger-service-1.0.0-SNAPSHOT.jar
java -jar notification-service/target/notification-service-1.0.0-SNAPSHOT.jar
java -jar transfer-service/target/transfer-service-1.0.0-SNAPSHOT.jar
java -jar gateway-service/target/gateway-service-1.0.0-SNAPSHOT.jar
```

## 前端应用启动

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:3000
```

## 服务访问地址

| 服务名称 | 端口 | 访问地址 | 说明 |
|---------|------|---------|------|
| Eureka Server | 8761 | http://localhost:8761 | 服务注册中心 |
| Account Service | 8081 | http://localhost:8081/doc.html | 账户服务API文档 |
| Risk Service | 8082 | http://localhost:8082/doc.html | 风控服务API文档 |
| Ledger Service | 8083 | http://localhost:8083/doc.html | 总账服务API文档 |
| Notification Service | 8084 | http://localhost:8084/doc.html | 通知服务API文档 |
| Transfer Service | 8085 | http://localhost:8085/doc.html | 转账服务API文档 |
| API Gateway | 8080 | http://localhost:8080/doc.html | 网关聚合API文档 |
| Frontend | 3000 | http://localhost:3000 | 前端应用 |

## 功能测试

### 1. 查看服务注册状态
访问 http://localhost:8761 查看所有服务是否正常注册

### 2. 测试账户服务
访问 http://localhost:8081/doc.html 测试账户相关API

### 3. 测试转账流程
1. 访问前端应用 http://localhost:3000
2. 进入"交易中心"
3. 填写转账信息(默认从账户1转账到账户2)
4. 提交转账,观察转账流程状态

### 4. 查看账户明细
1. 进入"账户管理"
2. 点击"查看"按钮查看账户详情和分户账明细

## 常见问题

### 1. 端口被占用
如果端口被占用,可以修改各服务的 `application.yml` 中的 `server.port` 配置

### 2. 数据库连接失败
- 检查MySQL是否启动
- 检查数据库名、用户名、密码是否正确
- 检查防火墙设置

### 3. 服务启动失败
- 确保Eureka Server先启动
- 检查日志输出,查看具体错误信息
- 确保JDK版本为1.8

### 4. 前端无法访问后端
- 确保API网关(8080)已启动
- 检查浏览器控制台网络请求
- 确认代理配置正确

## 项目结构

```
ISBank/
├── common/                    # 公共模块
├── eureka-server/            # 服务注册中心
├── gateway-service/          # API网关
├── account-service/          # 账户服务
├── risk-service/             # 风控服务
├── ledger-service/           # 总账服务
├── notification-service/     # 通知服务
├── transfer-service/         # 转账服务
├── frontend/                 # 前端应用
├── pom.xml                   # 父POM
└── README_DEPLOYMENT.md      # 部署文档
```

## 下一步

- 编写单元测试
- 添加集成测试
- 完善错误处理
- 添加日志监控
- 实现分布式事务

