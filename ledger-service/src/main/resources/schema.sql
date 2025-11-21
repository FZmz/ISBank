-- 总账科目表
CREATE TABLE IF NOT EXISTS ledger_accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '科目代码',
    name VARCHAR(100) NOT NULL COMMENT '科目名称',
    type VARCHAR(20) NOT NULL COMMENT '科目类型:ASSET/LIABILITY/INCOME/EXPENSE',
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='总账科目表';

-- 总账分录表
CREATE TABLE IF NOT EXISTS ledger_entries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    transaction_id VARCHAR(50) NOT NULL COMMENT '交易ID',
    ledger_account_id BIGINT NOT NULL COMMENT '总账科目ID',
    debit_amount DECIMAL(19, 2) COMMENT '借方金额',
    credit_amount DECIMAL(19, 2) COMMENT '贷方金额',
    occurred_at DATETIME NOT NULL COMMENT '发生时间',
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_ledger_account_id (ledger_account_id),
    INDEX idx_occurred_at (occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='总账分录表';

