#!/bin/bash

echo "========================================="
echo "ISBank 微服务银行系统 - 停止脚本"
echo "========================================="

echo "正在停止所有Spring Boot服务..."

# 查找并停止所有Spring Boot进程
pids=$(ps aux | grep 'spring-boot:run' | grep -v grep | awk '{print $2}')

if [ -z "$pids" ]; then
    echo "没有发现运行中的服务"
else
    echo "发现以下进程:"
    ps aux | grep 'spring-boot:run' | grep -v grep
    echo ""
    echo "正在停止进程..."
    echo $pids | xargs kill -9
    echo "所有服务已停止"
fi

echo "========================================="

