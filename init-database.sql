-- ISBank 数据库初始化脚本
-- 使用方法: mysql -u root -p < init-database.sql

-- 创建数据库
CREATE DATABASE IF NOT EXISTS greenbank CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE greenbank;

-- ============================================
-- 1. 账户服务表 (Account Service)
-- ============================================

-- 账户表
CREATE TABLE IF NOT EXISTS accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    customer_id VARCHAR(50) NOT NULL COMMENT '客户ID',
    account_no VARCHAR(50) NOT NULL UNIQUE COMMENT '账户号',
    currency VARCHAR(10) NOT NULL COMMENT '币种',
    balance DECIMAL(19, 2) NOT NULL DEFAULT 0.00 COMMENT '余额',
    status VARCHAR(20) NOT NULL COMMENT '账户状态:ACTIVE/FROZEN/CLOSED',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    updated_at DATETIME NOT NULL COMMENT '更新时间',
    INDEX idx_customer_id (customer_id),
    INDEX idx_account_no (account_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='账户表';

-- 账户分户账表
CREATE TABLE IF NOT EXISTS account_ledger (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    account_id BIGINT NOT NULL COMMENT '账户ID',
    transaction_id VARCHAR(50) NOT NULL COMMENT '交易ID',
    direction VARCHAR(10) NOT NULL COMMENT '借贷方向:DEBIT/CREDIT',
    amount DECIMAL(19, 2) NOT NULL COMMENT '金额',
    balance_after DECIMAL(19, 2) NOT NULL COMMENT '交易后余额',
    occurred_at DATETIME NOT NULL COMMENT '发生时间',
    INDEX idx_account_id (account_id),
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_occurred_at (occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='账户分户账表';

-- ============================================
-- 2. 转账服务表 (Transfer Service)
-- ============================================

-- 转账表
CREATE TABLE IF NOT EXISTS transfers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    transfer_id VARCHAR(50) NOT NULL UNIQUE COMMENT '转账ID',
    from_account_id BIGINT NOT NULL COMMENT '转出账户ID',
    to_account_id BIGINT NOT NULL COMMENT '转入账户ID',
    amount DECIMAL(19, 2) NOT NULL COMMENT '金额',
    currency VARCHAR(10) NOT NULL COMMENT '币种',
    transfer_type VARCHAR(20) NOT NULL COMMENT '转账类型:INTERNAL/EXTERNAL',
    status VARCHAR(20) NOT NULL COMMENT '状态:PENDING/SUCCESS/FAILED/CANCELLED',
    remark VARCHAR(200) COMMENT '备注',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    updated_at DATETIME NOT NULL COMMENT '更新时间',
    INDEX idx_transfer_id (transfer_id),
    INDEX idx_from_account (from_account_id),
    INDEX idx_to_account (to_account_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='转账表';

-- ============================================
-- 3. 风控服务表 (Risk Service)
-- ============================================

-- 风控决策表
CREATE TABLE IF NOT EXISTS risk_decisions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    decision_id VARCHAR(50) NOT NULL UNIQUE COMMENT '决策ID',
    customer_id VARCHAR(50) NOT NULL COMMENT '客户ID',
    from_account_id BIGINT COMMENT '转出账户ID',
    to_account_id BIGINT COMMENT '转入账户ID',
    amount DECIMAL(19, 2) NOT NULL COMMENT '金额',
    currency VARCHAR(10) NOT NULL COMMENT '币种',
    decision VARCHAR(20) NOT NULL COMMENT '决策结果:PASS/REJECT',
    reason VARCHAR(200) COMMENT '决策原因',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    INDEX idx_decision_id (decision_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_decision (decision),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风控决策表';

-- ============================================
-- 4. 总账服务表 (Ledger Service)
-- ============================================

-- 总账科目表
CREATE TABLE IF NOT EXISTS ledger_accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    account_code VARCHAR(50) NOT NULL UNIQUE COMMENT '科目代码',
    account_name VARCHAR(100) NOT NULL COMMENT '科目名称',
    account_type VARCHAR(20) NOT NULL COMMENT '科目类型:ASSET/LIABILITY/EQUITY/REVENUE/EXPENSE',
    parent_code VARCHAR(50) COMMENT '父科目代码',
    level INT NOT NULL COMMENT '科目级别',
    is_leaf BOOLEAN NOT NULL COMMENT '是否叶子节点',
    balance DECIMAL(19, 2) NOT NULL DEFAULT 0.00 COMMENT '余额',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    updated_at DATETIME NOT NULL COMMENT '更新时间',
    INDEX idx_account_code (account_code),
    INDEX idx_parent_code (parent_code),
    INDEX idx_account_type (account_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='总账科目表';

-- 总账分录表
CREATE TABLE IF NOT EXISTS ledger_entries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    entry_id VARCHAR(50) NOT NULL COMMENT '分录ID',
    transaction_id VARCHAR(50) NOT NULL COMMENT '交易ID',
    account_code VARCHAR(50) NOT NULL COMMENT '科目代码',
    direction VARCHAR(10) NOT NULL COMMENT '借贷方向:DEBIT/CREDIT',
    amount DECIMAL(19, 2) NOT NULL COMMENT '金额',
    currency VARCHAR(10) NOT NULL COMMENT '币种',
    summary VARCHAR(200) COMMENT '摘要',
    occurred_at DATETIME NOT NULL COMMENT '发生时间',
    INDEX idx_entry_id (entry_id),
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_account_code (account_code),
    INDEX idx_occurred_at (occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='总账分录表';

-- ============================================
-- 5. 通知服务表 (Notification Service)
-- ============================================

-- 通知表
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    notification_id VARCHAR(50) NOT NULL UNIQUE COMMENT '通知ID',
    transfer_id VARCHAR(50) NOT NULL COMMENT '转账ID',
    customer_id VARCHAR(50) NOT NULL COMMENT '客户ID',
    channel VARCHAR(20) NOT NULL COMMENT '通知渠道:SMS/EMAIL/PUSH',
    template_code VARCHAR(50) NOT NULL COMMENT '模板代码',
    content TEXT COMMENT '通知内容',
    status VARCHAR(20) NOT NULL COMMENT '状态:PENDING/SENT/FAILED',
    sent_at DATETIME COMMENT '发送时间',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    INDEX idx_notification_id (notification_id),
    INDEX idx_transfer_id (transfer_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知表';

-- ============================================
-- 初始化数据
-- ============================================

-- 插入测试账户
INSERT INTO accounts (customer_id, account_no, currency, balance, status, created_at, updated_at) VALUES
('CUST001', 'ACC1001', 'CNY', 10000.00, 'ACTIVE', NOW(), NOW()),
('CUST002', 'ACC1002', 'CNY', 5000.00, 'ACTIVE', NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- 插入总账科目
INSERT INTO ledger_accounts (account_code, account_name, account_type, level, is_leaf, balance, created_at, updated_at) VALUES
('1001', '库存现金', 'ASSET', 1, true, 0.00, NOW(), NOW()),
('1002', '银行存款', 'ASSET', 1, true, 0.00, NOW(), NOW()),
('2001', '应付账款', 'LIABILITY', 1, true, 0.00, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

SELECT '数据库初始化完成!' AS message;

