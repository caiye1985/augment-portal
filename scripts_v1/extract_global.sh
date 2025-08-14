#!/bin/bash
set -e

PRD_BASE="docs/prd/split"

# 获取最新版
LATEST_VERSION=$(ls -d "$PRD_BASE"/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
LATEST_DIR="$PRD_BASE/$LATEST_VERSION"
GLOBAL_FILE="$LATEST_DIR/global.md"
GLOBAL_DIR="$LATEST_DIR/globals"
APPENDIX_DIR="$LATEST_DIR/appendix"

echo "📂 最新 PRD 版本: v$LATEST_VERSION"

# 检查目录存在
[ ! -d "$GLOBAL_DIR" ] && { echo "❌ 缺少全局目录: $GLOBAL_DIR"; exit 1; }
[ ! -d "$APPENDIX_DIR" ] && echo "⚠️ 未找到附录目录: $APPENDIX_DIR（将跳过附录整合）"

echo "🔍 合并全局信息与附录..."
> "$GLOBAL_FILE"  # 清空或创建文件

# 合并 global/
find "$GLOBAL_DIR" -type f -name "*.md" | sort | while read f; do
    echo "### 来自: $(basename "$f")" >> "$GLOBAL_FILE"
    cat "$f" >> "$GLOBAL_FILE"
    echo -e "\n" >> "$GLOBAL_FILE"
done

# 合并 appendix/（如果存在）
if [ -d "$APPENDIX_DIR" ]; then
    find "$APPENDIX_DIR" -type f -name "*.md" | sort | while read f; do
        echo "### 来自: $(basename "$f")" >> "$GLOBAL_FILE"
        cat "$f" >> "$GLOBAL_FILE"
        echo -e "\n" >> "$GLOBAL_FILE"
    done
fi

echo "✅ 已生成全局信息文件（含附录）: $GLOBAL_FILE"
