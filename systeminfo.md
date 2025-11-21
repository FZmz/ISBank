## 1. 系统整体描述

**ISBank（韧性银行微服务系统）** 是一个面向云原生环境构建的简化银行业务系统，用于支持混沌工程、LDFI（谱系驱动故障注入）和 CI/CD 实验。系统围绕“账户管理—行内/跨行转账—总账记账—风控—通知”完整资金闭环进行建模，采用 Java 8 + Spring Boot 实现多微服务后端，Vue3 实现前端管理与客户门户，通过 Kubernetes + Helm 部署在 Ubuntu 环境，并接入 Coroot 进行全链路观测，为研究微服务韧性、故障注入和数据沿袭分析提供一个可控、可观测、可自动化构建与部署的被测系统。

---

## 2. 系统功能描述

1. **账户管理功能**  
   账户管理模块提供客户名下账户的全生命周期管理能力，包括账户开立、销户、账户状态维护（激活、冻结、关闭）以及账户余额和分户账明细查询。系统通过对每次资金变动记录分户账，实现账户维度的资金可追溯，为后续不变量检查和审计提供基础数据。
2. **行内/跨行转账功能**  
   转账模块负责发起并编排行内和跨行资金划转流程。用户可以在前端发起从源账户到目标账户的转账请求，系统按照预定义状态机依次完成风控校验、源账户扣款、目标账户入账、总账记账及通知发送。当为跨行转账时，通过模拟的清算网关服务异步接收外部清算结果，更新交易最终状态，形成典型的分布式交易场景。
3. **总账记账功能**  
   总账模块以复式记账的方式对每笔转账进行会计处理。系统为每笔交易生成成对的借贷分录，写入总账分录表，确保借方总额与贷方总额严格相等。通过总账科目的配置和试算平衡查询功能，可以对系统整体资金流进行核对，为“转账成功 ⇒ 总账借贷平衡”的关键业务不变量提供可靠依据。
4. **风控管理功能**  
   风控模块在转账前对交易进行同步风险校验，包括单笔限额检查、黑名单账户过滤以及简单的频度控制规则。风控结果作为转账流程的前置条件之一：若风控拒绝，则转账直接失败；若风控通过，则交易进入后续扣款与入账流程。风控决策与规则配置被持久化保存，便于审计和后续扩展更复杂的风险策略。
5. **通知与用户感知功能**  
   通知模块负责在交易完成后向客户发送转账结果通知（如短信/邮件/站内公告的模拟），并记录通知发送状态。它将“系统内部状态”与“用户感知结果”显式分离，使得可以构造“用户收到成功通知但资金未真正落地”的故障场景，从而支撑“用户感知与资金落地一致（INV2）”这一业务不变量的验证。
6. **监控与可视化观测功能**  
   系统通过接入 Coroot（以及其所依赖的 Prometheus、eBPF agent 等）实现对各微服务的拓扑关系、延迟、错误率、资源使用等关键指标的统一观测。前端还提供基础的业务指标展示和不变量检查结果视图，使运维与研究人员可以同时从“技术视角”和“业务视角”观察故障注入前后系统行为变化。

---

## 3. 微服务划分与接口 & 数据库设计

### 3.1 微服务总体划分

+ `customer-service`：客户信息管理（辅助，可选实现）
+ `account-service`：账户及分户账管理
+ `transfer-service`：转账业务编排（核心）
+ `ledger-service`：总账记账
+ `risk-service`：风控决策
+ `notification-service`：通知管理
+ `clearing-gateway-service`：跨行清算网关模拟（可选启用）

下面按服务分别给出**主要接口**和**数据库设计（关键表）**。

---

### 3.2 Account-Service

**职责**：维护账户基本信息、余额以及账户分户账，是账户资金状态的权威源。

#### 主要接口（REST）

+ `POST /accounts`  
  创建账户。请求：`{ customerId, currency }`；响应：`{ accountId }`。
+ `POST /accounts/{accountId}/freeze` / `/unfreeze`  
  冻结/解冻账户。
+ `GET /accounts/{accountId}`  
  查询账户基本信息和当前余额。
+ `GET /accounts/{accountId}/ledger`  
  查询账户分户账明细。

**内部接口（供 transfer-service 调用）：**

+ `POST /internal/accounts/debit`  
  请求：`{ accountId, amount, currency, transactionId }`。  
  含义：检查余额与状态，在单库事务中更新余额并插入一条分户账借方记录。
+ `POST /internal/accounts/credit`  
  请求：结构同上。  
  含义：更新余额并插入一条分户账贷方记录。

#### 数据库设计（`account_db`）

+ 表 `accounts`
  - `id` (PK)
  - `customer_id`
  - `account_no`
  - `currency`
  - `balance`
  - `status` (ACTIVE/FROZEN/CLOSED)
  - `created_at`, `updated_at`
+ 表 `account_ledger`
  - `id` (PK)
  - `account_id`
  - `transaction_id`（关联 transfers.id）
  - `direction` (DEBIT/CREDIT)
  - `amount`
  - `balance_after`
  - `occurred_at`

---

### 3.3 Transfer-Service

**职责**：作为交易编排器，驱动风控、账户、总账、通知等服务完成一笔行内或跨行转账。

#### 主要接口

+ `POST /transfers`  
  发起转账。请求：

```json
{
  "fromAccountId": "A",
  "toAccountId": "B",
  "amount": 100.00,
  "currency": "CNY",
  "type": "INTERNAL" // or "EXTERNAL"
}
```

响应：`{ transferId, status }`。

+ `GET /transfers/{transferId}`  
  查询交易状态与简要信息。

#### 内部交互（通过 HTTP 调用其他服务）

+ 调用 `risk-service`：`POST /risk/check`
+ 调用 `account-service`：`/internal/accounts/debit`、`/internal/accounts/credit`
+ 调用 `ledger-service`：`POST /entries`
+ 调用 `notification-service`：`POST /notify`
+ 调用 `clearing-gateway-service`（跨行时）：`POST /external/transfers` + 接收回调

#### 数据库设计（`transfer_db`）

+ 表 `transfers`
  - `id` (transferId, PK)
  - `from_account_id`
  - `to_account_id`
  - `amount`
  - `currency`
  - `type` (INTERNAL/EXTERNAL)
  - `status` (INIT/PENDING/DEBIT_DONE/CREDIT_DONE/LEDGER_POSTED/SUCCESS/FAILED)
  - `created_at`, `last_updated_at`
+ 表 `transfer_events`（可选，用于记录状态机演进）
  - `id` (PK)
  - `transfer_id`
  - `event_type`（RISK_PASSED / DEBIT_SUCCESS 等）
  - `data` (JSON)
  - `created_at`

---

### 3.4 Ledger-Service

**职责**：执行复式记账，保证所有资金流在总账层面的借贷平衡。

#### 主要接口

+ `POST /entries`  
  请求：

```json
{
  "transactionId": "T123",
  "entries": [
    { "ledgerAccountCode": "CUS_A", "debitAmount": 100.00 },
    { "ledgerAccountCode": "CUS_B", "creditAmount": 100.00 }
  ]
}
```

行为：在单库事务中写入多条分录记录，确保借贷合规。

+ `GET /entries/{transactionId}`  
  按交易 ID 查询所有总账分录。
+ `GET /trial-balance`  
  返回当前试算平衡信息，用于整体对账。

#### 数据库设计（`ledger_db`）

+ 表 `ledger_accounts`
  - `id` (PK)
  - `code`（科目代码）
  - `name`
  - `type` (ASSET/LIABILITY/INCOME/EXPENSE)
+ 表 `ledger_entries`
  - `id` (PK)
  - `transaction_id`
  - `ledger_account_id`
  - `debit_amount` (nullable)
  - `credit_amount` (nullable)
  - `occurred_at`

---

### 3.5 Risk-Service

**职责**：根据预配置规则对转账进行同步风控判断。

#### 主要接口

+ `POST /risk/check`  
  请求：

```json
{
  "customerId": "C1",
  "fromAccountId": "A",
  "toAccountId": "B",
  "amount": 100.00,
  "currency": "CNY"
}
```

响应：

```json
{
  "result": "ALLOW",    // or "DENY"
  "reasonCode": "OK"    // or "AMOUNT_LIMIT", "BLACKLIST", ...
}
```

#### 数据库设计（`risk_db`）

+ 表 `risk_rules`
  - `id` (PK)
  - `rule_type`（AMOUNT_LIMIT / BLACKLIST / FREQUENCY 等）
  - `config` (JSON)
  - `enabled`
+ 表 `risk_decisions`
  - `id` (PK)
  - `transfer_id`
  - `result` (ALLOW/DENY)
  - `reason_code`
  - `created_at`

---

### 3.6 Notification-Service

**职责**：发送并记录通知结果，用于描述“用户感知”。

#### 主要接口

+ `POST /notify`  
  请求：

```json
{
  "transferId": "T123",
  "customerId": "C1",
  "channel": "SMS",
  "templateCode": "TRANSFER_SUCCESS",
  "params": { "amount": 100.00, "toAccount": "B" }
}
```

响应：`{ notificationId, status: "SENT" }`（可模拟为同步成功）。

+ `GET /notifications/{notificationId}`  
  查询通知发送状态。

#### 数据库设计（`notify_db`）

+ 表 `notifications`
  - `id` (PK)
  - `transfer_id`
  - `customer_id`
  - `channel`
  - `template_code`
  - `status` (PENDING/SENT/FAILED)
  - `sent_at`, `created_at`

---

### 3.7 Clearing-Gateway-Service（可选）

**职责**：模拟对接外部银行的清算通道。

+ `POST /external/transfers`：接受跨行转账请求，异步回调结果；
+ `POST /callbacks/clearing-result`：回调 transfer-service，告知清算成功或失败。

数据库可简单记录 `external_transfers`，包括状态和回调信息。

---

## 4. 系统技术架构（Java 8 + Spring Boot + Vue3）

技术架构分为前端层、网关接入层、业务服务层、数据存储层和基础设施/DevOps 层。

1. **前端层（Web Portal）**  
   使用 **Vue3 + TypeScript + Vite** 实现单页应用（SPA），提供客户视角的“账户总览、转账发起、交易查询”界面，以及运维视角的“交易统计、不变量检查结果可视化”等页面。前端构建产物通过 Nginx 容器镜像部署在 Kubernetes 中，对后端微服务进行 HTTP 调用。
2. **网关接入层**  
   使用 Nginx Ingress（或简单 Nginx）作为 API 接入层，将前端的请求路由到后端各个 Spring Boot 微服务（主要是 transfer-service 和 account-service），实现统一域名暴露和基础的反向代理。
3. **业务服务层**  
   各业务微服务均基于 **Java 8 + Spring Boot** 开发，遵循典型的三层结构（Controller / Service / Repository）。服务间通过 REST/HTTP 调用，统一使用 JSON 作为数据格式。每个服务内使用 Spring Data JPA 或 MyBatis 访问数据库，通过本地事务保证自身数据的一致性。
4. **数据存储层**  
   后端使用 MySQL（或 PostgreSQL）作为关系型数据库，实现按业务域拆分的多个数据库（account_db、transfer_db、ledger_db、risk_db、notify_db）。数据库实例可以部署在集群外部或作为有状态服务部署在 Kubernetes 中。
5. **基础设施与 DevOps 层**  
   源代码托管在 GitHub，使用 GitHub Actions 构建 CI/CD 流水线：在 Mac 本地开发后将代码推送到 GitHub，由 Actions 在 Ubuntu 上的 self-hosted runner 上执行构建、测试、镜像构建与推送，再通过 **Helm** 对远程 Kubernetes 集群执行 `helm upgrade --install`，完成自动化部署。容器运行时为 Docker/containerd，镜像仓库可选用 GitHub Container Registry。
6. **可观测性与混沌实验集成**  
   在 Kubernetes 集群中部署 Coroot 及其依赖，通过 eBPF 或 OpenTelemetry Agent 收集各微服务的性能指标、请求拓扑和错误信息。Chaos Mesh 作为故障注入框架在同一集群中运行，用于在 Pod、网络层面注入故障，其效果通过 Coroot 和业务 UI 全面观测。