## Demo work-area
export WORK_AREA=${PWD}
export SIM_PATH=${WORK_ARE}/sim
export TEST_PATH=${WORK_ARE}/testcases

###############################
# MAIN TARGETS
###############################

all: vcs_comp vcs_sim_test1 vcs_sim_test2 vcs_sim_test3 vcs_faultsim_test1

###############################
# HELP and utils
###############################

help:
	@echo "---------------------------------------------------------------------------------"
	@echo "all       : vcs_comp vcs_sim_test1 vcs_sim_test2 vcs_sim_test3"
	@echo ""
	@echo "vcs_comp  : run vcs for project compile"  
	@echo "vcs_sim_test1  : Run FIFO test 1"
	@echo "vcs_sim_test2  : Run FIFO test 2"
	@echo "vcs_sim_test3  : Run FIFO test 3"
	@echo "vcs_faultsim_test1  : Run FIFO fault inject test 1"
	@echo "---------------------------------------------------------------------------------"

###############################
# compile and simulation
###############################	

vcs_comp: clean
	cd ${WORK_AREA}/${SIM_PATH} && \
	vcs -full64 -sverilog -debug_access+all \
	-f ${WORK_AREA}/rtl_fifo.f -kdb -lca \
	-l vcs_compile.log


vcs_sim_test%:
	cd ${WORK_AREA}/${SIM_PATH} && \
	simv  -l simulation_test$*.log +test$* 

vcs_faultsim_test%:
	cd ${WORK_AREA}/${SIM_PATH} && \
	cp ${WORK_AREA}/fault_cmd/test$*_fault.cmd . && \
	simv  -l simulation_test$*.log +test$* -ucli -do test$*_fault.cmd

###############################
# Bring up Verdi
###############################

run_verdi: 
	cd ${WORK_AREA}/${SIM_PATH} && \
	verdi -ssf fifo.fsdb
###############################
# Clean
###############################

clean: 
	rm -rf *.log  ./sim/* 
	

