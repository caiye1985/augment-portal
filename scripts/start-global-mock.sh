#!/bin/bash
# 快捷启动全局API Mock Server
cd "$(dirname "$0")/.."
./scripts/start-mock-server.sh --global --watch --dynamic --cors
