import re
import sys

def analyze_log(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    error_match = re.search(r"UVM_ERROR\s*:\s*(\d+)", content)
    fatal_match = re.search(r"UVM_FATAL\s*:\s*(\d+)", content)

    uvm_error = int(error_match.group(1)) if error_match else 0
    uvm_fatal = int(fatal_match.group(1)) if fatal_match else 0

    result = "PASS" if uvm_error == 0 and uvm_fatal == 0 else "FAIL"
    print(f"{filepath}: {result} (UVM_ERROR={uvm_error}, UVM_FATAL={uvm_fatal})")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 check_sim_log.py <simv.log>")
        sys.exit(1)

    analyze_log(sys.argv[1])
