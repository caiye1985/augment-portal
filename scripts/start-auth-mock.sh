#!/bin/bash
# 快捷启动认证业务域 Mock Server
cd "$(dirname "$0")/.."
./scripts/start-mock-server.sh -d auth --watch --dynamic --cors
