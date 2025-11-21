# ISBank 快速启动指南

## 🚀 5分钟快速启动

本指南帮助您在5分钟内启动并运行ISBank微服务银行系统。

---

## 📋 前置检查

在开始之前,请确保已安装以下软件:

```bash
# 检查Java版本 (需要JDK 8+)
java -version

# 检查Maven版本 (需要3.6+)
mvn -version

# 检查Node.js版本 (需要16+)
node -v

# 检查MySQL是否运行
mysql --version
```

---

## 步骤1️⃣: 初始化数据库 (1分钟)

### 方式A: 使用自动化脚本 (推荐)

```bash
# 赋予执行权限
chmod +x init-db.sh

# 执行初始化
./init-db.sh
# 输入MySQL root密码
```

### 方式B: 手动执行SQL脚本

```bash
mysql -u root -p < init-database.sql
# 输入MySQL root密码
```

### 方式C: 手动创建

```bash
# 登录MySQL
mysql -u root -p

# 执行初始化脚本
SOURCE init-database.sql;

# 或者只创建数据库(表会自动创建)
CREATE DATABASE greenbank CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 退出MySQL
exit;
```

**注意**:
- 初始化脚本会创建数据库和所有必要的表
- 默认会插入2个测试账户和3个总账科目
- 如需修改数据库密码,请编辑各服务的 `application.yml`

---

## 步骤2️⃣: 启动后端服务 (2分钟)

### 方式A: 使用一键启动脚本 (推荐)

```bash
# 赋予执行权限
chmod +x start-all.sh

# 启动所有服务
./start-all.sh
```

脚本会自动:
1. 编译所有项目
2. 按顺序启动7个微服务
3. 输出启动日志到 `logs/` 目录

### 方式B: 手动启动 (用于调试)

```bash
# 1. 启动Eureka (必须第一个启动)
cd eureka-server
mvn spring-boot:run &

# 等待10秒让Eureka完全启动
sleep 10

# 2. 启动业务服务 (可并行)
cd ../account-service && mvn spring-boot:run &
cd ../risk-service && mvn spring-boot:run &
cd ../ledger-service && mvn spring-boot:run &
cd ../notification-service && mvn spring-boot:run &
cd ../transfer-service && mvn spring-boot:run &

# 等待5秒
sleep 5

# 3. 启动网关 (最后启动)
cd ../gateway-service && mvn spring-boot:run &
```

---

## 步骤3️⃣: 验证后端服务 (30秒)

### 检查服务注册状态

打开浏览器访问: http://localhost:8761

**预期结果**: 看到以下6个服务已注册
- ACCOUNT-SERVICE
- RISK-SERVICE
- LEDGER-SERVICE
- NOTIFICATION-SERVICE
- TRANSFER-SERVICE
- GATEWAY-SERVICE

### 检查API文档

访问: http://localhost:8080/doc.html

**预期结果**: 看到Knife4j文档界面,左侧显示所有微服务API

---

## 步骤4️⃣: 启动前端应用 (1分钟)

```bash
# 进入前端目录
cd frontend

# 安装依赖 (首次运行需要)
npm install

# 启动开发服务器
npm run dev
```

**预期输出**:
```
  VITE v4.4.9  ready in 500 ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: use --host to expose
```

---

## 步骤5️⃣: 访问系统 (30秒)

打开浏览器访问: http://localhost:3000

您将看到ISBank的主界面,包含三个主要模块:
- 📊 **监控中心**: 查看系统状态和KPI
- 👤 **账户管理**: 管理账户和查看明细
- 💸 **交易中心**: 执行转账操作

---

## 🎯 快速测试

### 测试1: 查看账户

1. 点击 "账户管理"
2. 查看预置的3个测试账户
3. 点击 "查看" 按钮查看账户详情

### 测试2: 执行转账

1. 点击 "交易中心"
2. 填写转账信息:
   - 源账户ID: `1`
   - 目标账户ID: `2`
   - 转账金额: `100`
   - 币种: `CNY`
   - 转账类型: `INTERNAL`
3. 点击 "提交转账"
4. 观察右侧转账结果和流程状态

### 测试3: 验证余额变化

1. 返回 "账户管理"
2. 查看账户1和账户2的余额
3. 确认余额已正确更新

---

## 🔧 常见问题

### Q1: 端口被占用怎么办?

**解决方案**: 修改对应服务的 `application.yml` 中的 `server.port`

### Q2: 服务启动失败?

**排查步骤**:
1. 检查Eureka是否先启动
2. 查看日志文件 `logs/*.log`
3. 确认MySQL已启动
4. 确认JDK版本为1.8

### Q3: 前端无法访问后端?

**排查步骤**:
1. 确认API网关(8080)已启动
2. 打开浏览器开发者工具查看网络请求
3. 检查控制台是否有CORS错误

### Q4: 数据库表未创建?

**解决方案**:
1. 确认 `application.yml` 中 `spring.sql.init.mode=always`
2. 检查 `schema.sql` 文件是否存在
3. 查看服务启动日志

---

## 🛑 停止服务

### 停止所有后端服务

```bash
chmod +x stop-all.sh
./stop-all.sh
```

### 停止前端服务

在前端终端按 `Ctrl + C`

---

## 📊 服务端口速查表

| 服务 | 端口 | 访问地址 |
|------|------|---------|
| 前端应用 | 3000 | http://localhost:3000 |
| Eureka | 8761 | http://localhost:8761 |
| Gateway | 8080 | http://localhost:8080/doc.html |
| Account | 8081 | http://localhost:8081/doc.html |
| Risk | 8082 | http://localhost:8082/doc.html |
| Ledger | 8083 | http://localhost:8083/doc.html |
| Notification | 8084 | http://localhost:8084/doc.html |
| Transfer | 8085 | http://localhost:8085/doc.html |

---

## 📚 下一步

- 📖 阅读 [部署指南](README_DEPLOYMENT.md) 了解详细配置
- 🧪 查看 [集成测试指南](INTEGRATION_TEST_GUIDE.md) 进行完整测试
- 📊 查看 [项目总结](PROJECT_SUMMARY.md) 了解系统架构

---

## ✅ 启动成功标志

当您看到以下内容时,说明系统已成功启动:

- ✅ Eureka控制台显示6个服务
- ✅ 前端界面正常显示
- ✅ 可以查看账户列表
- ✅ 可以执行转账操作
- ✅ API文档可以访问

**恭喜! 您已成功启动ISBank微服务银行系统! 🎉**

