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

