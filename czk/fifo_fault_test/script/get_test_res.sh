#!/bin/bash 
 
# 参数校验 
if [ $# -ne 2 ]; then 
    echo "用法: $0 <inputfile> <num>"
    exit 1 
fi 
 
inputfile="$1"
num="$2"
 
# 验证输入文件存在 
if [ ! -f "$inputfile" ]; then 
    echo "错误：文件 $inputfile 不存在"
    exit 1 
fi 
 
# 步骤1：查找以!开头的行 
target_line=$(grep -m1 '^!' "$inputfile")
 
# 处理未找到的情况 
if [ -z "$target_line" ]; then 
    echo "error"
    exit 0 
fi 
 
# 步骤2：提取第二个字符并判断 
char=$(echo "$target_line" | cut -c2)
 
if [ "$char" = "0" ] ; then 
    echo "t${num}=0"
    exit 3
elif [ "$char" = "1" ]; then
    echo "t${num}=1"
    exit 4
else
    echo "error"
fi 