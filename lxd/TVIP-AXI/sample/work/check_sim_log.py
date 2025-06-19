import re
import sys

def analyze_log(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # 检查是否存在仿真完整标志
    report_summary_found = "--- UVM Report Summary ---" in content

    error_match = re.search(r"UVM_ERROR\s*:\s*(\d+)", content)
    fatal_match = re.search(r"UVM_FATAL\s*:\s*(\d+)", content)

    uvm_error = int(error_match.group(1)) if error_match else 0
    uvm_fatal = int(fatal_match.group(1)) if fatal_match else 0

    # 判断仿真是否成功
    if report_summary_found and uvm_error == 0 and uvm_fatal == 0:
        result = "PASS"
    else:
        result = "FAIL"

    # 如果没有 report summary，说明仿真未正常结束
    if not report_summary_found:
        print(f"{filepath}: {result} (Incomplete simulation log)")
    else:
        print(f"{filepath}: {result} (UVM_ERROR={uvm_error}, UVM_FATAL={uvm_fatal})")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 check_sim_log.py <simv.log>")
        sys.exit(1)

    analyze_log(sys.argv[1])
