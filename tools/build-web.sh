#!/usr/bin/env bash
set -euo pipefail

# Windows / macOS 共用构建逻辑；保留旧入口兼容现有命令。
# 首次先在 Creator 导入本工程；Windows 构建时关闭编辑器，macOS 保持打开。
# Jolt 固定文件名要求关闭 MD5 缓存。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec node "$ROOT/tools/build-web.mjs"
