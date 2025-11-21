-- ========================================
-- ISBank 微服务数据库初始化脚本
-- 每个微服务使用独立的数据库
-- ========================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS greenbank_account DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS greenbank_risk DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS greenbank_ledger DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS greenbank_notification DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS greenbank_transfer DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ========================================
-- Account Service 数据库
-- ========================================
USE greenbank_account;

-- 账户表
CREATE TABLE IF NOT EXISTS accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    customer_id VARCHAR(50) NOT NULL COMMENT '客户ID',
    account_no VARCHAR(50) NOT NULL UNIQUE COMMENT '账户号',
    currency VARCHAR(10) NOT NULL COMMENT '币种',
    balance DECIMAL(19, 2) NOT NULL DEFAULT 0.00 COMMENT '余额',
    status VARCHAR(20) NOT NULL COMMENT '状态:ACTIVE/FROZEN/CLOSED',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    updated_at DATETIME NOT NULL COMMENT '更新时间',
    INDEX idx_customer_id (customer_id),
    INDEX idx_account_no (account_no),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='账户表';

-- 账户流水表
CREATE TABLE IF NOT EXISTS account_ledger (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    account_id BIGINT NOT NULL COMMENT '账户ID',
    transaction_id VARCHAR(50) NOT NULL COMMENT '交易ID',
    amount DECIMAL(19, 2) NOT NULL COMMENT '金额',
    balance_after DECIMAL(19, 2) NOT NULL COMMENT '交易后余额',
    type VARCHAR(20) NOT NULL COMMENT '类型:DEBIT/CREDIT',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    INDEX idx_account_id (account_id),
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='账户流水表';

-- 初始化测试账户
INSERT INTO accounts (customer_id, account_no, currency, balance, status, created_at, updated_at) VALUES
('C001', 'ACC1001', 'CNY', 10000.00, 'ACTIVE', NOW(), NOW()),
('C002', 'ACC1002', 'CNY', 5000.00, 'ACTIVE', NOW(), NOW()),
('C003', 'ACC1003', 'CNY', 8000.00, 'ACTIVE', NOW(), NOW())
ON DUPLICATE KEY UPDATE balance=balance;

-- ========================================
-- Risk Service 数据库
-- ========================================
USE greenbank_risk;

-- 风控决策表
CREATE TABLE IF NOT EXISTS risk_decisions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    transfer_id VARCHAR(50) NOT NULL COMMENT '转账ID',
    from_account_id BIGINT NOT NULL COMMENT '源账户ID',
    to_account_id BIGINT NOT NULL COMMENT '目标账户ID',
    amount DECIMAL(19, 2) NOT NULL COMMENT '金额',
    currency VARCHAR(10) NOT NULL COMMENT '币种',
    result VARCHAR(20) NOT NULL COMMENT '决策结果:ALLOW/REJECT',
    reason_code VARCHAR(50) COMMENT '原因代码',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    INDEX idx_transfer_id (transfer_id),
    INDEX idx_result (result),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风控决策表';

-- ========================================
-- Ledger Service 数据库
-- ========================================
USE greenbank_ledger;

-- 总账科目表
CREATE TABLE IF NOT EXISTS ledger_accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '科目代码',
    name VARCHAR(100) NOT NULL COMMENT '科目名称',
    type VARCHAR(20) NOT NULL COMMENT '类型:ASSET/LIABILITY/EQUITY/REVENUE/EXPENSE',
    balance DECIMAL(19, 2) NOT NULL DEFAULT 0.00 COMMENT '余额',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    updated_at DATETIME NOT NULL COMMENT '更新时间',
    INDEX idx_code (code),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='总账科目表';

-- 总账分录表
CREATE TABLE IF NOT EXISTS ledger_entries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    transaction_id VARCHAR(50) NOT NULL COMMENT '交易ID',
    ledger_account_id BIGINT NOT NULL COMMENT '总账科目ID',
    debit_amount DECIMAL(19, 2) COMMENT '借方金额',
    credit_amount DECIMAL(19, 2) COMMENT '贷方金额',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_ledger_account_id (ledger_account_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='总账分录表';

-- 初始化总账科目
INSERT INTO ledger_accounts (code, name, type, balance, created_at, updated_at) VALUES
('CASH', '现金', 'ASSET', 0.00, NOW(), NOW()),
('CUSTOMER_DEPOSIT', '客户存款', 'LIABILITY', 0.00, NOW(), NOW()),
('REVENUE', '收入', 'REVENUE', 0.00, NOW(), NOW())
ON DUPLICATE KEY UPDATE name=name;

-- ========================================
-- Notification Service 数据库
-- ========================================
USE greenbank_notification;

-- 通知记录表
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    transfer_id VARCHAR(50) NOT NULL COMMENT '转账ID',
    customer_id VARCHAR(50) NOT NULL COMMENT '客户ID',
    channel VARCHAR(20) NOT NULL COMMENT '渠道:SMS/EMAIL/PUSH',
    template_code VARCHAR(50) NOT NULL COMMENT '模板代码',
    content TEXT COMMENT '通知内容',
    status VARCHAR(20) NOT NULL COMMENT '状态:PENDING/SENT/FAILED',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    sent_at DATETIME COMMENT '发送时间',
    INDEX idx_transfer_id (transfer_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知记录表';

-- ========================================
-- Transfer Service 数据库
-- ========================================
USE greenbank_transfer;

-- 转账表
CREATE TABLE IF NOT EXISTS transfers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    from_account_id BIGINT NOT NULL COMMENT '源账户ID',
    to_account_id BIGINT NOT NULL COMMENT '目标账户ID',
    amount DECIMAL(19, 2) NOT NULL COMMENT '金额',
    currency VARCHAR(10) NOT NULL COMMENT '币种',
    type VARCHAR(20) NOT NULL COMMENT '转账类型:INTERNAL/EXTERNAL',
    status VARCHAR(30) NOT NULL COMMENT '状态',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    last_updated_at DATETIME NOT NULL COMMENT '最后更新时间',
    INDEX idx_from_account_id (from_account_id),
    INDEX idx_to_account_id (to_account_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='转账表';

