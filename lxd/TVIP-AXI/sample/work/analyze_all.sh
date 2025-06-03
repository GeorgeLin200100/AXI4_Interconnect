#!/bin/bash

# 根目录路径
WORK_DIR="./fault_test"
RESULT_FILE="fault_test_result.log"

# 初始化输出文件
echo "仿真结果统计：" > "$RESULT_FILE"
echo "----------------------------------" >> "$RESULT_FILE"

# 计数器
pass=0
fail=0
total=0

# 遍历所有 sim_* 子目录
for simdir in "$WORK_DIR"/sim_*; do
    if [ -f "$simdir/simv.log" ]; then
        # 调用 check_sim_log.py 脚本获取结果
        result=$(python3 check_sim_log.py "$simdir/simv.log")
        echo "$result" >> "$RESULT_FILE"

        # 统计
        if echo "$result" | grep -q "PASS"; then
            ((pass++))
        else
            ((fail++))
        fi
        ((total++))
    else
        echo "$simdir/simv.log 不存在，跳过。" >> "$RESULT_FILE"
    fi
done

# 汇总统计
echo "----------------------------------" >> "$RESULT_FILE"
echo "✅ PASS: $pass" >> "$RESULT_FILE"
echo "❌ FAIL: $fail" >> "$RESULT_FILE"
if [ "$total" -gt 0 ]; then
    percent=$(awk "BEGIN { printf \"%.2f\", ($pass/$total)*100 }")
    echo "✔️ 成功率: $percent%" >> "$RESULT_FILE"
else
    echo "⚠️ 未找到任何 simv.log" >> "$RESULT_FILE"
fi

echo "✅ 已完成分析，结果输出到：$RESULT_FILE"
