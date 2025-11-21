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

