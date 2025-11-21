-- 初始化测试账户数据
INSERT IGNORE INTO accounts (id, customer_id, account_no, currency, balance, status, created_at, updated_at) 
VALUES 
(1, 'C001', 'ACC1001', 'CNY', 10000.00, 'ACTIVE', NOW(), NOW()),
(2, 'C002', 'ACC1002', 'CNY', 5000.00, 'ACTIVE', NOW(), NOW()),
(3, 'C003', 'ACC1003', 'CNY', 8000.00, 'ACTIVE', NOW(), NOW());

