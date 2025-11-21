-- 风控决策表
CREATE TABLE IF NOT EXISTS risk_decisions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    transfer_id VARCHAR(50) NOT NULL COMMENT '转账ID',
    result VARCHAR(20) NOT NULL COMMENT '决策结果:ALLOW/DENY',
    reason_code VARCHAR(50) NOT NULL COMMENT '原因代码',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    INDEX idx_transfer_id (transfer_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风控决策表';

-- 风控规则表
CREATE TABLE IF NOT EXISTS risk_rules (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    rule_type VARCHAR(50) NOT NULL COMMENT '规则类型',
    config JSON COMMENT '规则配置',
    enabled TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    updated_at DATETIME NOT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风控规则表';

