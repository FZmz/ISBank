-- 通知表
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    transfer_id VARCHAR(50) NOT NULL COMMENT '转账ID',
    customer_id VARCHAR(50) NOT NULL COMMENT '客户ID',
    channel VARCHAR(20) NOT NULL COMMENT '通知渠道:SMS/EMAIL/PUSH',
    template_code VARCHAR(50) NOT NULL COMMENT '模板代码',
    status VARCHAR(20) NOT NULL COMMENT '状态:PENDING/SENT/FAILED',
    sent_at DATETIME COMMENT '发送时间',
    created_at DATETIME NOT NULL COMMENT '创建时间',
    INDEX idx_transfer_id (transfer_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知表';

