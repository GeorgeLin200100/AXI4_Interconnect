#!/bin/bash

# 检查是否提供了参数
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_name>"
  echo "Example: $0 default"
  exit 1
fi

DIR_NAME=$1

# 进入工作目录
cd sample/work || { echo "Failed to enter directory: sample/work"; exit 1; }

# 启动 verdi
verdi -ssf "${DIR_NAME}/dump.fsdb" -f compile.f