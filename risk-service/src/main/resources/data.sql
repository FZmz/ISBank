-- 初始化风控规则数据
INSERT IGNORE INTO risk_rules (id, rule_type, config, enabled, created_at, updated_at) 
VALUES 
(1, 'AMOUNT_LIMIT', '{"singleLimit": 50000.00}', 1, NOW(), NOW());

