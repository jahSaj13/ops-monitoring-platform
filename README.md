# 运维监控与 CI/CD 实战平台

## 项目简介
独立搭建的运维监控与高可用架构平台，涵盖 Docker Compose 和 Kubernetes 双套部署方案、数据库主从复制、TCP 负载均衡、全链路监控告警、CI/CD 流水线、日志收集、混沌工程。

## 技术栈
容器化: Docker + Docker Compose（11个服务）+ Kubernetes (K3s)
数据库: MySQL 8.0（主从复制）
负载均衡: Nginx TCP Stream
Web 应用: Python Flask + 自定义 Prometheus metrics
监控告警: Prometheus + MySQL Exporter + Grafana + Alertmanager
日志系统: Loki + Promtail
CI/CD: Jenkins Pipeline（Build → Deploy → Verify）
混沌工程: ChaosBlade + 手动故障注入
自动化: Shell 一键部署脚本

## 架构图
                    ┌─────────────────────────────────────────┐
                    │              Grafana :3000              │
                    │        指标 + 日志统一可视化             │
                    └──────────────────┬──────────────────────┘
                                       ↑
                      ┌────────────────┴────────────────┐
                      ↓                                  ↑
              ┌───────────────┐                  ┌───────────────┐
              │ Prometheus    │                  │ Loki :3100    │
              │ :9090         │                  │ 日志存储       │
              └──┬───────┬────┘                  └───────┬───────┘
                 ↑       ↓                               ↑
            ┌────┴──┐ ┌──┴──────────┐            ┌──────┴──────┐
            │Exporter│ │Alertmanager │            │  Promtail   │
            │:9104   │ │:9093        │            │  日志采集    │
            └────┬───┘ └─────────────┘            └─────────────┘
                 ↑
            ┌────┴──────────────────────┐
            │   Nginx :3306             │
            │   TCP 负载均衡             │
            └──┬──────────────────┬─────┘
               ↙                    ↘
        ┌──────┴────────┐    ┌──────┴────────┐
        │ mysql-master  │    │ mysql-slave   │
        │ :3306         │    │ :3307         │
        │ 主库           │    │ 从库           │
        └──────┬────────┘    └───────────────┘
               ↑ 主从复制
               └────────────────────────────┘
               ↑
        ┌──────┴────────┐  ┌──────────────┐  ┌──────────────┐
        │ lab-web       │  │  Jenkins     │  │  Shell脚本    │
        │ :5000         │  │  :8080       │  │  一键部署     │
        │ Flask Web     │  │  CI/CD流水线  │  │  健康检查     │
        └──────────────┘  └──────────────┘  └──────────────┘

## 部署方案
Docker Compose（单机版）: cd ~/my-ops-lab && ./start-all.sh
Kubernetes（集群版）: kubectl apply -f k8s/

## 服务列表（11个容器）
服务              端口        用途
-------------------------------------------------------
Nginx             3306        TCP 负载均衡
MySQL Master      3306        主库
MySQL Slave       3307        从库
MySQL Exporter    9104        暴露 MySQL 指标
Prometheus        9090        采集 + 告警评估
Grafana           3000        可视化仪表盘（指标+日志）
Alertmanager      9093        告警管理
Jenkins           8080        CI/CD 流水线
Web App           5000        Flask 应用 + 自定义 metrics
Loki              3100        日志存储
Promtail          --          日志采集

## 告警规则
1. MySQL 连接数过高: 连接数 > 5, 持续 30 秒
2. MySQL QPS 上升: 每秒查询数 > 1, 持续 30 秒

## CI/CD 流水线
三阶段: Build → Deploy → Verify（Console Output: SUCCESS）

## 验证清单
验证项                验证方式                        结果
-----------------------------------------------------------------------
监控链路              curl Exporter + Prometheus targets   全部 up
主从复制              主库 INSERT → 从库 SELECT           实时同步
负载均衡              Nginx 连续连接, server_id 切换      1/2 交替
告警触发              制造并发连接 → Alertmanager 页面     端到端验证
CI/CD                 Jenkins Console Output              SUCCESS
Web 应用              curl :5000/ + :5000/users           返回 JSON
日志系统              Grafana Explore 查看系统日志          正常
CPU 压力测试          yes 命令占满 CPU                     88% 占用, 服务未中断
K8s 自愈              删除 Pod → 自动重建                 验证通过

## 踩坑记录
1. Docker Hub 镜像拉取超时 -> 换国内镜像源 docker.1ms.run
2. Jenkins 容器内 docker: not found -> 挂载 docker.sock + Docker 二进制
3. K3s DNS 解析失败 -> CoreDNS 未就绪, 改用 Pod IP 直连
4. Grafana 白屏 -> 虚拟机内存从 2GB 升级到 4GB

## 截图
Grafana 仪表盘, Alertmanager 告警, Jenkins 流水线, Web 应用监控, Loki 日志等

## 作者
卢双信
