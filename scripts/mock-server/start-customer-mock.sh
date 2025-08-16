#!/bin/bash
# 快捷启动客户关系管理模块 Mock Server
cd "$(dirname "$0")/.."
./scripts/start-mock-server.sh -m REQ-016-客户关系管理模块 --watch --dynamic --cors
