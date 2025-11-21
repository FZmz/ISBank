# ISBank - 韧性银行微服务系统

<div align="center">

![Java](https://img.shields.io/badge/Java-8-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.3.12-brightgreen)
![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-Hoxton.SR12-blue)
![Vue](https://img.shields.io/badge/Vue-3.3.4-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

一个完整的微服务银行系统,用于支持混沌工程、故障注入和CI/CD实验研究

The private small bank of Zhou Green from the University of Chinese Academy of Sciences

</div>

## 📋 项目简介

ISBank是一个面向云原生环境构建的简化银行业务系统,实现了"账户管理—行内/跨行转账—总账记账—风控—通知"完整资金闭环。

### 核心特性

- 🏦 **完整业务闭环**: 账户、转账、风控、总账、通知
- 🔧 **微服务架构**: Spring Cloud + Eureka + Gateway
- 🎨 **现代化前端**: Vue3 + TypeScript + Element Plus
- 📊 **可视化监控**: 业务仪表盘 + 服务状态监控
- 📝 **API文档**: Knife4j自动生成交互式文档
- ✅ **完整测试**: 单元测试 + 集成测试
- 🚀 **快速部署**: 一键启动脚本

## 🏗️ 系统架构

```
┌─────────────┐
│   前端应用   │ (Vue3 + TypeScript)
│   :3000     │
└──────┬──────┘
       │
┌──────▼──────┐
│  API网关    │ (Spring Cloud Gateway)
│   :8080     │
└──────┬──────┘
       │
   ┌───┴───┬───────┬────────┬──────────┬────────┐
   │       │       │        │          │        │
┌──▼──┐ ┌─▼──┐ ┌──▼───┐ ┌──▼────┐ ┌───▼───┐ ┌─▼────┐
│账户 │ │转账│ │风控  │ │总账   │ │通知   │ │Eureka│
│:8081│ │:8085│ │:8082 │ │:8083  │ │:8084  │ │:8761 │
└──┬──┘ └─┬──┘ └──┬───┘ └──┬────┘ └───┬───┘ └──────┘
   └───────┴───────┴────────┴──────────┘
                   │
            ┌──────▼──────┐
            │   MySQL     │
            │  greenbank  │
            └─────────────┘
```

## 🚀 快速开始

### 环境要求

- JDK 8+
- Maven 3.6+
- Node.js 16+
- MySQL 8.0

### 1. 克隆项目

```bash
git clone <repository-url>
cd ISBank
```

### 2. 数据库准备

```sql
CREATE DATABASE greenbank CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. 启动后端服务

```bash
# 方式1: 使用启动脚本(推荐)
chmod +x start-all.sh
./start-all.sh

# 方式2: 手动启动
mvn clean package -DskipTests
# 然后按顺序启动各服务...
```

### 4. 启动前端应用

```bash
cd frontend
npm install
npm run dev
```

### 5. 访问系统

| 服务 | 地址 | 说明 |
|------|------|------|
| 前端应用 | http://localhost:3000 | 主界面 |
| Eureka控制台 | http://localhost:8761 | 服务注册中心 |
| API文档 | http://localhost:8080/doc.html | Knife4j文档 |

## 📦 微服务列表

| 服务名称 | 端口 | 职责 |
|---------|------|------|
| eureka-server | 8761 | 服务注册与发现 |
| gateway-service | 8080 | API网关,统一入口 |
| account-service | 8081 | 账户管理,余额操作 |
| transfer-service | 8085 | 转账编排,流程控制 |
| risk-service | 8082 | 风险控制,交易审核 |
| ledger-service | 8083 | 总账管理,复式记账 |
| notification-service | 8084 | 消息通知 |

## 💼 核心业务功能

### 账户管理
- 账户开立与销户
- 账户状态管理(激活/冻结)
- 余额查询
- 分户账明细查询

### 转账服务
- 行内转账
- 跨行转账
- 转账状态跟踪
- 完整的Saga编排流程

### 风控管理
- 交易金额限额检查
- 风控决策记录
- 实时风险评估

### 总账管理
- 复式记账
- 借贷平衡校验
- 总账科目管理

### 通知服务
- 多渠道通知(SMS/EMAIL/PUSH)
- 通知记录持久化

## 🧪 测试

### 推荐测试方式

```bash
# 1. API集成测试(推荐)
chmod +x test-api.sh
./test-api.sh

# 2. Knife4j交互测试
# 访问: http://localhost:8080/doc.html

# 3. 前端界面测试
# 访问: http://localhost:3000
```

详细测试指南请参考: [TESTING_GUIDE.md](TESTING_GUIDE.md)

## 📚 文档

- [快速启动指南](QUICK_START.md) - 5分钟快速上手
- [部署指南](README_DEPLOYMENT.md) - 详细的部署步骤
- [集成测试指南](INTEGRATION_TEST_GUIDE.md) - 完整的测试用例
- [测试策略指南](TESTING_GUIDE.md) - 测试方法和建议
- [项目结构说明](PROJECT_STRUCTURE.md) - 项目目录结构
- [项目总结](PROJECT_SUMMARY.md) - 项目完成情况总结

## 🛠️ 技术栈

### 后端
- Spring Boot 2.3.12
- Spring Cloud Hoxton.SR12
- MyBatis Plus 3.4.3
- MySQL 8.0
- Knife4j 2.0.9

### 前端
- Vue 3.3.4
- TypeScript 5.2.2
- Element Plus 2.3.14
- ECharts 5.4.3
- Vite 4.4.9

## 📖 使用示例

### 创建账户

```bash
curl -X POST http://localhost:8080/api/account/accounts \
  -H "Content-Type: application/json" \
  -d '{"customerId":"CUST001","currency":"CNY"}'
```

### 执行转账

```bash
curl -X POST http://localhost:8080/api/transfer/transfers \
  -H "Content-Type: application/json" \
  -d '{
    "fromAccountId": 1,
    "toAccountId": 2,
    "amount": 100,
    "currency": "CNY",
    "type": "INTERNAL"
  }'
```

## 🔧 停止服务

```bash
chmod +x stop-all.sh
./stop-all.sh
```

## 📊 监控与管理

- **Eureka Dashboard**: 查看服务注册状态
- **Knife4j API文档**: 测试和调试API
- **前端监控中心**: 查看业务KPI和服务状态

## 🤝 贡献

欢迎提交Issue和Pull Request!

## 📄 许可证

MIT License

## 👥 联系方式

如有问题,请提交Issue或联系项目维护者。

---

<div align="center">
Made with ❤️ by ISBank Team
</div>
