# 数据库初始化问题修复

## ❌ 问题描述

服务启动时报错:
```
java.sql.SQLSyntaxErrorException: Table 'greenbank.accounts' doesn't exist
```

## 🔍 问题原因

1. **数据库表未创建**: greenbank 数据库中缺少必要的表
2. **自动初始化未生效**: Spring Boot 的 SQL 初始化配置可能未正确执行

## ✅ 解决方案

### 方案1: 使用初始化脚本 (推荐)

#### 步骤1: 执行数据库初始化脚本

```bash
# 方式A: 使用自动化脚本
chmod +x init-db.sh
./init-db.sh

# 方式B: 手动执行SQL
mysql -u root -p < init-database.sql
```

#### 步骤2: 验证表是否创建成功

```bash
mysql -u root -p
```

```sql
USE greenbank;
SHOW TABLES;

-- 应该看到以下7张表:
-- accounts
-- account_ledger
-- transfers
-- risk_decisions
-- ledger_accounts
-- ledger_entries
-- notifications
```

#### 步骤3: 启动服务

```bash
./start-all.sh
```

### 方案2: 修复 Spring Boot 自动初始化

我已经修改了所有服务的 `application.yml` 配置:

**修改内容**:
```yaml
spring:
  datasource:
    # Spring Boot 2.3.x 使用这种方式初始化数据库
    initialization-mode: always
    schema: classpath:schema.sql
    data: classpath:data.sql  # 如果有测试数据
    continue-on-error: false
```

**影响的服务**:
- ✅ account-service
- ✅ risk-service
- ✅ ledger-service
- ✅ notification-service
- ✅ transfer-service

**注意**: Spring Boot 2.5+ 使用 `spring.sql.init.mode`，但 2.3.x 使用 `initialization-mode`

## 📊 数据库表结构

### 1. Account Service (账户服务)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| accounts | 账户表 | id, customer_id, account_no, balance, status |
| account_ledger | 分户账表 | id, account_id, transaction_id, amount |

### 2. Transfer Service (转账服务)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| transfers | 转账表 | id, transfer_id, from_account_id, to_account_id, amount, status |

### 3. Risk Service (风控服务)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| risk_decisions | 风控决策表 | id, decision_id, customer_id, amount, decision |

### 4. Ledger Service (总账服务)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| ledger_accounts | 总账科目表 | id, account_code, account_name, balance |
| ledger_entries | 总账分录表 | id, entry_id, transaction_id, account_code, amount |

### 5. Notification Service (通知服务)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| notifications | 通知表 | id, notification_id, transfer_id, channel, status |

## 🔧 常见问题

### Q1: 为什么 Spring Boot 自动初始化没有生效?

**A**: 可能的原因:
1. **版本差异**: Spring Boot 2.3.x 使用 `initialization-mode`，2.5+ 使用 `spring.sql.init.mode`
2. **执行时机**: 如果使用连接池,可能在初始化之前就尝试访问数据库
3. **配置位置**: 确保 schema.sql 在 `src/main/resources` 目录下

### Q2: 如何确认数据库密码正确?

**A**: 测试连接:
```bash
mysql -u root -p -h localhost
# 输入密码: Zmzzmz010627!
```

如果连接失败,请修改各服务的 `application.yml` 中的密码。

### Q3: 表已存在,如何重新初始化?

**A**: 
```sql
-- 删除所有表
DROP DATABASE greenbank;

-- 重新执行初始化脚本
mysql -u root -p < init-database.sql
```

### Q4: 如何只创建表而不插入测试数据?

**A**: 编辑 `init-database.sql`,删除最后的 INSERT 语句,或者设置:
```yaml
spring:
  datasource:
    initialization-mode: always
    schema: classpath:schema.sql
    # 不配置 data 属性
```

## ✅ 验证步骤

### 1. 检查数据库

```bash
mysql -u root -p
```

```sql
USE greenbank;

-- 检查表
SHOW TABLES;

-- 检查账户表
SELECT * FROM accounts;

-- 检查表结构
DESC accounts;
```

### 2. 检查服务日志

```bash
# 查看 account-service 日志
tail -f logs/account.log

# 成功标志:
# - 没有 "Table doesn't exist" 错误
# - 看到 "Started AccountServiceApplication"
```

### 3. 测试 API

```bash
# 测试账户查询
curl http://localhost:8080/api/account/accounts/1

# 预期返回账户信息
```

## 🚀 完整启动流程

### 首次启动

```bash
# 1. 初始化数据库
chmod +x init-db.sh
./init-db.sh

# 2. 启动 Eureka
cd eureka-server
mvn spring-boot:run &
sleep 10

# 3. 启动所有服务
cd ..
./start-all.sh
```

### 后续启动

```bash
# 直接启动所有服务
./start-all.sh
```

## 📝 已创建的文件

| 文件 | 用途 |
|------|------|
| `init-database.sql` | 数据库初始化SQL脚本 |
| `init-db.sh` | 自动化初始化脚本 |
| `DATABASE_INIT_FIX.md` | 本文档 |

## 🎯 总结

**问题**: 数据库表不存在  
**原因**: 未执行初始化脚本  
**解决**: 
1. ✅ 执行 `./init-db.sh` 创建所有表
2. ✅ 修改 `application.yml` 使用正确的初始化配置
3. ✅ 重新启动服务

**现在可以正常启动所有服务了!** 🎉

---

**修复完成时间**: 2025-11-20  
**影响范围**: 所有使用数据库的微服务  
**向后兼容**: 是

