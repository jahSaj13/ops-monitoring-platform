#!/bin/bash
# 一键启动运维监控环境

set -e

echo "========================================="
echo "  运维监控环境一键部署脚本"
echo "========================================="

echo ""
echo "[1/4] 启动所有服务..."
docker compose up -d

echo ""
echo "[2/4] 等待 MySQL 就绪..."
until docker exec lab-mysql-master mysqladmin ping -uroot -pTest123456 --silent 2>/dev/null; do
    echo "  MySQL 尚未就绪，等待中..."
    sleep 3
done
echo "  MySQL 已就绪！"

echo ""
echo "[3/4] 等待其他服务就绪..."
sleep 15

echo ""
echo "[4/4] 健康检查..."

echo -n "  MySQL Exporter (9104): "
if curl -s http://localhost:9104/metrics | grep -q mysql_up; then
    echo "✅ 正常"
else
    echo "❌ 异常"
fi

echo -n "  Prometheus (9090): "
if curl -s http://localhost:9090/-/healthy 2>/dev/null | grep -q Healthy; then
    echo "✅ 正常"
else
    echo "❌ 异常"
fi

echo -n "  Grafana (3000): "
if curl -s http://localhost:3000/api/health 2>/dev/null | grep -q ok; then
    echo "✅ 正常"
else
    echo "❌ 异常"
fi

echo -n "  Web App (5000): "
if curl -s http://localhost:5000/ | grep -q "Hello"; then
    echo "✅ 正常"
else
    echo "❌ 异常"
fi

echo -n "  Loki (3100): "
if curl -s http://localhost:3100/ready | grep -q "ready"; then
    echo "✅ 正常"
else
    echo "❌ 异常"
fi

echo -n "  Jenkins (8080): "
if curl -s http://localhost:8080/login 2>/dev/null | grep -q Jenkins; then
    echo "✅ 正常"
else
    echo "❌ 异常"
fi

echo ""
echo "========================================="
echo "  全部就绪！"
echo "  Grafana:      http://你的IP:3000 (admin/admin)"
echo "  Prometheus:   http://你的IP:9090"
echo "  Alertmanager: http://你的IP:9093"
echo "  Jenkins:      http://你的IP:8080"
echo "========================================="
