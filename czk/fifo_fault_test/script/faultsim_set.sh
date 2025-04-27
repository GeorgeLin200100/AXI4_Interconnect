#!/bin/bash 
signal_file=$WORK_AREA/signal_list.txt
result_file=$RESULT_PATH/vcs_faultsim_set_result.txt

# 检查文件存在性 
if [ ! -f "$signal_file" ]; then 
    echo "错误 signal_list.txt文件不存在" >&2 
    exit 1 
fi

#计数
success=0
fail=0
line_number=0 

echo $line_number >$result_file
while read -r signal_line 
do 
    ((line_number++))
    echo "正在处理第${line_number}行: ${signal_line}"

    str="force $signal_line 1" 
    # 替换目标文件第二行
    sed -i "2s#.*#${str//\\/\\\\}#" test1_fault.cmd  
    cat test1_fault.cmd

    # 执行仿真
    ./simv  -l simulation_test_fault1.log +test1 -ucli -do test1_fault.cmd > /dev/null

    $SCRIPT_PATH/get_test_res.sh simulation_test_fault1.log $line_number >> $result_file

    #3成功4失败
    if [ $? -eq 3 ]; then
        success=$((success + 1))
    elif [ $? -eq 4 ]; then
        fail=$((fail + 1))
    fi

done <$signal_file

echo $line_number >>$result_file
echo "成功的信号数: $success" >> $result_file
echo "失败的信号数: $fail" >> $result_file