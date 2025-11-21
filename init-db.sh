#!/bin/bash

echo "========================================="
echo "ISBank 数据库初始化脚本"
echo "========================================="

# 检查MySQL是否安装
if ! command -v mysql &> /dev/null; then
    echo "错误: 未找到MySQL客户端,请先安装MySQL"
    exit 1
fi

echo ""
echo "请输入MySQL root密码:"
read -s MYSQL_PASSWORD

echo ""
echo "正在初始化数据库..."

# 执行SQL脚本
mysql -u root -p"$MYSQL_PASSWORD" < init-database.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✅ 数据库初始化成功!"
    echo "========================================="
    echo ""
    echo "已创建的数据库: greenbank"
    echo ""
    echo "已创建的表:"
    echo "  1. accounts - 账户表"
    echo "  2. account_ledger - 账户分户账表"
    echo "  3. transfers - 转账表"
    echo "  4. risk_decisions - 风控决策表"
    echo "  5. ledger_accounts - 总账科目表"
    echo "  6. ledger_entries - 总账分录表"
    echo "  7. notifications - 通知表"
    echo ""
    echo "已插入测试数据:"
    echo "  - 2个测试账户"
    echo "  - 3个总账科目"
    echo ""
    echo "现在可以启动服务了: ./start-all.sh"
    echo "========================================="
else
    echo ""
    echo "❌ 数据库初始化失败,请检查错误信息"
    exit 1
fi

