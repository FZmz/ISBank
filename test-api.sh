#!/bin/bash

echo "========================================="
echo "ISBank API 集成测试脚本"
echo "========================================="

API_GATEWAY="http://localhost:8080"

echo ""
echo "测试1: 查询账户1信息"
echo "-----------------------------------"
curl -s -X GET "${API_GATEWAY}/api/account/accounts/1" | jq '.'

echo ""
echo "测试2: 查询账户2信息"
echo "-----------------------------------"
curl -s -X GET "${API_GATEWAY}/api/account/accounts/2" | jq '.'

echo ""
echo "测试3: 执行转账(账户1 -> 账户2, 金额100)"
echo "-----------------------------------"
TRANSFER_RESULT=$(curl -s -X POST "${API_GATEWAY}/api/transfer/transfers" \
  -H "Content-Type: application/json" \
  -d '{
    "fromAccountId": 1,
    "toAccountId": 2,
    "amount": 100,
    "currency": "CNY",
    "type": "INTERNAL"
  }')

echo "$TRANSFER_RESULT" | jq '.'

# 提取转账ID
TRANSFER_ID=$(echo "$TRANSFER_RESULT" | jq -r '.data.id')

if [ "$TRANSFER_ID" != "null" ] && [ -n "$TRANSFER_ID" ]; then
  echo ""
  echo "测试4: 查询转账状态 (ID: $TRANSFER_ID)"
  echo "-----------------------------------"
  sleep 2
  curl -s -X GET "${API_GATEWAY}/api/transfer/transfers/${TRANSFER_ID}" | jq '.'
fi

echo ""
echo "测试5: 查询账户1分户账"
echo "-----------------------------------"
curl -s -X GET "${API_GATEWAY}/api/account/accounts/1/ledger" | jq '.'

echo ""
echo "测试6: 测试风控拦截(金额超限)"
echo "-----------------------------------"
curl -s -X POST "${API_GATEWAY}/api/transfer/transfers" \
  -H "Content-Type: application/json" \
  -d '{
    "fromAccountId": 1,
    "toAccountId": 2,
    "amount": 60000,
    "currency": "CNY",
    "type": "INTERNAL"
  }' | jq '.'

echo ""
echo "========================================="
echo "测试完成!"
echo "========================================="
echo ""
echo "提示: 如果看到错误,请检查:"
echo "1. 所有服务是否已启动"
echo "2. API网关是否运行在8080端口"
echo "3. 数据库是否已初始化"
echo ""

