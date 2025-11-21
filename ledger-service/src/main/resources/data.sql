-- 初始化总账科目数据
INSERT IGNORE INTO ledger_accounts (id, code, name, type) 
VALUES 
(1, 'CASH', '现金', 'ASSET'),
(2, 'CUSTOMER_DEPOSIT', '客户存款', 'LIABILITY'),
(3, 'TRANSFER_FEE_INCOME', '转账手续费收入', 'INCOME');

