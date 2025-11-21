# ISBank 集成测试指南

## 测试目标

验证ISBank微服务银行系统的完整业务流程,确保前后端集成正常,所有服务协同工作。

## 测试环境准备

### 1. 启动所有后端服务

```bash
# 方式1: 使用启动脚本
chmod +x start-all.sh
./start-all.sh

# 方式2: 手动启动
# 按顺序启动: Eureka -> 业务服务 -> Gateway
```

### 2. 验证服务注册

访问 http://localhost:8761 确认以下服务已注册:
- ACCOUNT-SERVICE
- RISK-SERVICE
- LEDGER-SERVICE
- NOTIFICATION-SERVICE
- TRANSFER-SERVICE
- GATEWAY-SERVICE

### 3. 启动前端应用

```bash
cd frontend
npm install
npm run dev
```

访问 http://localhost:3000 确认前端应用正常启动

## 测试用例

### 测试用例1: 账户管理功能

#### 1.1 查询账户列表
**步骤:**
1. 访问前端应用 http://localhost:3000
2. 点击"账户管理"菜单
3. 查看账户列表

**预期结果:**
- 显示3个测试账户(ID: 1, 2, 3)
- 账户状态为ACTIVE
- 余额正确显示

#### 1.2 查看账户详情
**步骤:**
1. 在账户列表中点击"查看"按钮
2. 查看账户详情和分户账明细

**预期结果:**
- 显示账户基本信息
- 显示分户账交易明细(如有)

#### 1.3 冻结/解冻账户
**步骤:**
1. 点击"冻结"按钮冻结账户
2. 确认账户状态变为FROZEN
3. 点击"解冻"按钮解冻账户
4. 确认账户状态变为ACTIVE

**预期结果:**
- 冻结操作成功,状态更新
- 解冻操作成功,状态恢复

### 测试用例2: 转账功能(核心流程)

#### 2.1 正常转账流程
**步骤:**
1. 访问"交易中心"
2. 填写转账信息:
   - 源账户ID: 1
   - 目标账户ID: 2
   - 转账金额: 100
   - 币种: CNY
   - 转账类型: INTERNAL
3. 点击"提交转账"

**预期结果:**
- 转账提交成功
- 右侧显示转账结果,状态为SUCCESS
- 转账流程步骤显示完整流程:
  - INIT → RISK_CHECKING → RISK_PASSED → DEBIT_DONE → CREDIT_DONE → LEDGER_POSTED → SUCCESS

#### 2.2 验证账户余额变化
**步骤:**
1. 转账完成后,返回"账户管理"
2. 查看账户1和账户2的余额

**预期结果:**
- 账户1余额减少100
- 账户2余额增加100

#### 2.3 验证分户账记录
**步骤:**
1. 查看账户1的分户账明细
2. 查看账户2的分户账明细

**预期结果:**
- 账户1有一条DEBIT(借方)记录,金额100
- 账户2有一条CREDIT(贷方)记录,金额100
- 记录包含交易ID和交易后余额

#### 2.4 大额转账风控拦截
**步骤:**
1. 填写转账信息:
   - 源账户ID: 1
   - 目标账户ID: 2
   - 转账金额: 60000 (超过限额50000)
   - 币种: CNY
   - 转账类型: INTERNAL
2. 点击"提交转账"

**预期结果:**
- 转账失败
- 状态显示为FAILED
- 错误信息提示"风控检查未通过"

#### 2.5 余额不足转账失败
**步骤:**
1. 填写转账信息:
   - 源账户ID: 2
   - 目标账户ID: 1
   - 转账金额: 100000 (超过账户余额)
   - 币种: CNY
   - 转账类型: INTERNAL
2. 点击"提交转账"

**预期结果:**
- 转账失败
- 状态显示为FAILED
- 错误信息提示"余额不足"

### 测试用例3: API文档访问

#### 3.1 访问网关聚合文档
**步骤:**
1. 访问 http://localhost:8080/doc.html

**预期结果:**
- 显示Knife4j文档界面
- 左侧显示所有微服务的API分组
- 可以选择不同服务查看API

#### 3.2 测试API接口
**步骤:**
1. 在Knife4j界面选择"账户管理"
2. 找到"查询账户"接口
3. 输入accountId=1
4. 点击"发送"

**预期结果:**
- 返回账户1的详细信息
- 响应码200
- 数据格式正确

### 测试用例4: 服务监控

#### 4.1 查看监控仪表盘
**步骤:**
1. 访问前端"监控中心"
2. 查看KPI指标卡片

**预期结果:**
- 显示今日交易笔数
- 显示今日交易金额
- 显示交易成功率
- 显示平均响应时延

#### 4.2 查看服务状态
**步骤:**
1. 在监控中心查看"系统服务状态"

**预期结果:**
- 所有服务状态显示为UP(绿色)

## 性能测试

### 并发转账测试
使用JMeter或Postman进行并发转账测试:

```bash
# 使用curl进行简单测试
for i in {1..10}; do
  curl -X POST http://localhost:8080/api/transfer/transfers \
    -H "Content-Type: application/json" \
    -d '{
      "fromAccountId": 1,
      "toAccountId": 2,
      "amount": 10,
      "currency": "CNY",
      "type": "INTERNAL"
    }' &
done
wait
```

**预期结果:**
- 所有请求成功处理
- 账户余额正确更新
- 无数据不一致问题

## 数据一致性验证

### 验证复式记账
**步骤:**
1. 执行多笔转账
2. 查询数据库验证总账平衡

```sql
-- 查询总账借贷平衡
SELECT 
  SUM(CASE WHEN direction = 'DEBIT' THEN amount ELSE 0 END) as total_debit,
  SUM(CASE WHEN direction = 'CREDIT' THEN amount ELSE 0 END) as total_credit
FROM ledger_entries;
```

**预期结果:**
- total_debit = total_credit (借贷平衡)

### 验证账户余额
**步骤:**
1. 查询账户表余额
2. 查询分户账计算余额

```sql
-- 账户表余额
SELECT id, balance FROM accounts WHERE id = 1;

-- 分户账计算余额
SELECT 
  account_id,
  SUM(CASE WHEN direction = 'CREDIT' THEN amount ELSE -amount END) as calculated_balance
FROM account_ledger
WHERE account_id = 1
GROUP BY account_id;
```

**预期结果:**
- 两个余额一致

## 故障恢复测试

### 测试服务降级
**步骤:**
1. 停止notification-service
2. 执行转账操作

**预期结果:**
- 转账仍然成功(通知失败不影响主流程)
- 或转账失败但有明确错误提示

### 测试数据库连接失败
**步骤:**
1. 停止MySQL服务
2. 尝试执行转账

**预期结果:**
- 返回明确的错误信息
- 服务不崩溃

## 测试报告模板

```
测试日期: YYYY-MM-DD
测试人员: XXX
测试环境: 本地开发环境

测试结果汇总:
- 总测试用例数: XX
- 通过用例数: XX
- 失败用例数: XX
- 通过率: XX%

详细测试结果:
1. 账户管理功能: ✓ 通过
2. 转账功能: ✓ 通过
3. API文档访问: ✓ 通过
4. 服务监控: ✓ 通过
5. 性能测试: ✓ 通过
6. 数据一致性: ✓ 通过
7. 故障恢复: ✓ 通过

发现的问题:
1. [问题描述]
2. [问题描述]

建议:
1. [改进建议]
2. [改进建议]
```

## 常见问题排查

### 问题1: 转账失败
**排查步骤:**
1. 检查所有服务是否启动
2. 查看transfer-service日志
3. 检查账户状态是否为ACTIVE
4. 检查账户余额是否充足

### 问题2: 前端无法访问后端
**排查步骤:**
1. 检查gateway-service是否启动
2. 检查浏览器控制台网络请求
3. 验证CORS配置
4. 检查路由配置

### 问题3: 数据库表未创建
**排查步骤:**
1. 检查application.yml中的数据库配置
2. 确认spring.sql.init.mode=always
3. 检查schema.sql文件是否存在
4. 查看服务启动日志

## 总结

完成以上所有测试用例后,确认:
- ✓ 所有微服务正常启动并注册
- ✓ API网关路由配置正确
- ✓ 前端可以正常访问后端API
- ✓ 完整转账流程端到端可用
- ✓ 数据一致性得到保证
- ✓ Knife4j API文档可访问
- ✓ 数据库表自动初始化成功
- ✓ 单元测试全部通过

