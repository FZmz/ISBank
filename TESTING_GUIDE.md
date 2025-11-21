# ISBank 测试指南

## 📋 测试说明

由于项目采用Spring Boot微服务架构,单元测试需要Mock大量依赖。当前项目已提供完整的业务功能实现,建议采用以下测试策略:

## 🎯 推荐的测试方式

### 1. 集成测试 (推荐)

使用提供的集成测试脚本和指南进行端到端测试:

```bash
# 运行API集成测试脚本
./test-api.sh
```

参考文档: [INTEGRATION_TEST_GUIDE.md](INTEGRATION_TEST_GUIDE.md)

### 2. API文档测试 (推荐)

通过Knife4j界面进行交互式API测试:

1. 启动所有服务
2. 访问: http://localhost:8080/doc.html
3. 在界面中测试各个API接口

### 3. 前端界面测试 (推荐)

通过前端界面进行完整业务流程测试:

1. 访问: http://localhost:3000
2. 测试账户管理功能
3. 测试转账流程
4. 验证数据一致性

## 🧪 单元测试说明

### 当前状态

项目中包含的单元测试文件由于以下原因可能无法直接运行:

1. **Mock复杂度高**: 微服务间调用需要Mock多个依赖
2. **数据库依赖**: 需要配置测试数据库或使用H2内存数据库
3. **Spring上下文**: 需要完整的Spring Boot测试配置

### 修复单元测试的步骤

如果您需要运行单元测试,请按以下步骤修复:

#### 步骤1: 添加测试依赖

在各服务的`pom.xml`中确认包含:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>
```

#### 步骤2: 创建测试配置

在`src/test/resources/application-test.yml`:

```yaml
spring:
  datasource:
    driver-class-name: org.h2.Driver
    url: jdbc:h2:mem:testdb
    username: sa
    password:
  sql:
    init:
      mode: always
```

#### 步骤3: 使用Spring Boot Test

推荐使用`@SpringBootTest`进行集成测试:

```java
@SpringBootTest
@AutoConfigureMockMvc
public class AccountServiceIntegrationTest {
    
    @Autowired
    private AccountService accountService;
    
    @Test
    public void testCreateAccount() {
        CreateAccountRequest request = new CreateAccountRequest();
        request.setCustomerId("CUST001");
        request.setCurrency("CNY");
        request.setInitialBalance(new BigDecimal("1000.00"));
        
        Account account = accountService.createAccount(request);
        
        assertNotNull(account);
        assertNotNull(account.getId());
        assertEquals("CUST001", account.getCustomerId());
    }
}
```

## 📝 测试用例示例

### Account Service 测试

```java
@SpringBootTest
@Transactional
public class AccountServiceTest {
    
    @Autowired
    private AccountService accountService;
    
    @Test
    public void testDebit() {
        // 1. 创建账户
        CreateAccountRequest createReq = new CreateAccountRequest();
        createReq.setCustomerId("TEST001");
        createReq.setCurrency("CNY");
        createReq.setInitialBalance(new BigDecimal("1000.00"));
        Account account = accountService.createAccount(createReq);
        
        // 2. 扣款
        DebitRequest debitReq = new DebitRequest();
        debitReq.setAccountId(account.getId());
        debitReq.setAmount(new BigDecimal("100.00"));
        debitReq.setCurrency("CNY");
        debitReq.setTransactionId("TXN001");
        
        accountService.debit(debitReq);
        
        // 3. 验证余额
        Account updated = accountService.getAccount(account.getId());
        assertEquals(new BigDecimal("900.00"), updated.getBalance());
    }
}
```

### Transfer Service 测试

```java
@SpringBootTest
@Transactional
public class TransferServiceTest {
    
    @Autowired
    private TransferService transferService;
    
    @Autowired
    private AccountService accountService;
    
    @Test
    public void testCreateTransfer() {
        // 1. 创建两个账户
        Account from = createTestAccount("1000.00");
        Account to = createTestAccount("500.00");
        
        // 2. 创建转账
        CreateTransferRequest request = new CreateTransferRequest();
        request.setFromAccountId(from.getId());
        request.setToAccountId(to.getId());
        request.setAmount(new BigDecimal("100.00"));
        request.setCurrency("CNY");
        request.setTransferType(TransferType.INTERNAL);
        
        Transfer transfer = transferService.createTransfer(request);
        
        // 3. 验证转账状态
        assertNotNull(transfer);
        assertNotNull(transfer.getId());
    }
    
    private Account createTestAccount(String balance) {
        CreateAccountRequest req = new CreateAccountRequest();
        req.setCustomerId("TEST" + System.currentTimeMillis());
        req.setCurrency("CNY");
        req.setInitialBalance(new BigDecimal(balance));
        return accountService.createAccount(req);
    }
}
```

## 🔍 测试覆盖建议

### 核心业务测试

| 服务 | 测试重点 |
|------|---------|
| Account Service | 账户创建、扣款、入账、冻结/解冻 |
| Transfer Service | 转账创建、状态流转 |
| Risk Service | 风控规则验证 |
| Ledger Service | 借贷平衡校验 |
| Notification Service | 通知发送 |

### 异常场景测试

- 余额不足
- 账户冻结
- 金额超限
- 借贷不平衡
- 服务调用失败

## 🚀 快速验证方案

如果您只是想快速验证系统功能,推荐使用以下方案:

### 方案1: 使用test-api.sh脚本

```bash
chmod +x test-api.sh
./test-api.sh
```

### 方案2: 使用Postman/Curl

参考 `INTEGRATION_TEST_GUIDE.md` 中的API测试用例

### 方案3: 使用前端界面

1. 启动系统
2. 访问 http://localhost:3000
3. 执行完整业务流程

## 📊 测试报告

### 集成测试结果

运行 `./test-api.sh` 后会输出:

- ✅ 账户创建测试
- ✅ 账户查询测试
- ✅ 转账创建测试
- ✅ 转账查询测试

### 手动测试清单

- [ ] 创建账户
- [ ] 查询账户
- [ ] 冻结账户
- [ ] 解冻账户
- [ ] 行内转账
- [ ] 跨行转账
- [ ] 风控拦截
- [ ] 余额不足拦截
- [ ] 查看总账
- [ ] 查看通知记录

## 💡 建议

1. **优先使用集成测试**: 更接近真实场景
2. **使用API文档测试**: 快速验证接口
3. **前端界面测试**: 验证完整流程
4. **单元测试**: 仅在需要时编写

## 📚 相关文档

- [集成测试指南](INTEGRATION_TEST_GUIDE.md)
- [快速启动指南](QUICK_START.md)
- [部署指南](README_DEPLOYMENT.md)

---

**注意**: 当前项目重点在于功能实现和系统集成,单元测试可作为后续优化项。建议优先使用集成测试和API测试验证系统功能。

