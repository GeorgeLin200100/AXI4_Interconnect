## AXI Safety Connector
### Enviroment
VCS & Verdi 2018.02
Z01X 2018.01
### Capability
 - Read/Write Burst
 - Outstanding Write/Read
 - Out-of-order Single-Slave Response
 - Out-of-order Multi-Slave Response
 - Safety Mechanism
 
## Get Started
```
git clone https://GeorgeLin200100/AXI4_Interconnect.git
cd AXI4_Interconnect/lxd/TVIP-AXI/sample/work/

make compile_vcs

# Usage:
# TEST = default/out_of_order_response/outstanding_access/read_interleave/ready_delay/request_delay/response_delay/wvalid_preceding_awvalid
# SEQ = BASIC_WRITE_READ/SEQUENCE_BY_SEQUENCE/SEQUENCE_BY_ITEM/OUTSTANDING_WRITE/ALL_SEQUENCES
# SCENARIO = 1MnS/1M1S
# to test outstanding access behavior
export TEST=outstanding_access
export SEQ=OUSTANDING_WRITE
export SCENARIO=1MnS
make sim_vcs TEST=$(TEST) SEQ=$(SEQ) SCENARIO=$(SCENARIO)

# to view simv.log
cat $(TEST)/simv.log

## to view waveform (shall carry the TEST arg same as the former command)
cd ../..
./open_verdi.sh $(TEST)
```

Remember to modify top_define.svh!

## Fault Simulation Flow
### UVM Backdoor Fault Simulation
#### 1 Compile the Design

make compile_vcs


#### 2 Generate Signal List for Fault Injection
Please wait for the signal extraction to complete. If the terminal remains in the UCLI interactive environment, type run and press Enter to allow the simulation to finish.

make sim_get_signal TEST=outstanding_access SEQ=OUTSTANDING_WRITE SCENARIO=1MnS


#### 3 Prepare the Fault List

cp outstanding_access/all_signal.txt ./all_signal.txt


#### 4 Run Batch Fault Simulation

make batch_fault_sim TEST=outstanding_access SEQ=OUTSTANDING_WRITE SCENARIO=1MnS FORCE_VALUE=1 FAULT_TYPE=1 SIGNAL_FILE=all_signal.txt -j12


#### 5 Analyze Results
This script requires Python 3 to be installed and available in your environment.

./analyze_all.sh && cat fault_test_result.log


### Z01X Fault Simulation
#### Option 1: Run Full Campaign
make zoix_all


#### Option 2: Run Step-by-Step
make zoix_clean

make zoix_compile

make zoix_fmsh

make zoix_get_report