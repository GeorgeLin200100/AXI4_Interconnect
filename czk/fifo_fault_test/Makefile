## Demo work-area
export WORK_AREA=${PWD}
export SIM_PATH=${WORK_AREA}/sim
export RESULT_PATH=${WORK_AREA}/result
export SCRIPT_PATH=${WORK_AREA}/script

###############################
# MAIN TARGETS
###############################

all: vcs_comp vcs_faultsim_set


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

vcs_comp: 
	cd ${SIM_PATH} && \
	vcs -full64 -sverilog -debug_access+all \
	-f ${WORK_AREA}/rtl_fifo.filelist -kdb -lca \
	-l vcs_compile.log

vcs_sim_test%:
	cd ${SIM_PATH} && \
	./simv  -l simulation_test$*.log +test$* 

vcs_faultsim_test%:
	cd ${SIM_PATH} && \
	cp ${WORK_AREA}/fault_cmd/test$*_fault.cmd . && \
	./simv  -l simulation_test_fault$*.log +test$* -ucli -do test$*_fault.cmd

vcs_faultsim_1:
	cd ${SIM_PATH} && \
	cp ${WORK_AREA}/fault_cmd/test1_fault.cmd . && \
	./simv -l ${RESULT_PATH}/vcs_faultsim_1.log +test1 -ucli -do test1_fault.cmd

vcs_faultsim_set:
	cd ${SIM_PATH} && \
	cp ${WORK_AREA}/fault_cmd/test1_fault.cmd . && \
	cp ${WORK_AREA}/signal_list.txt . && \
	${SCRIPT_PATH}/faultsim_set.sh

###############################
# Bring up Verdi
###############################

run_verdi: 
	cd ${SIM_PATH} && \
	verdi -sverilog -ssf fifo.fsdb -f ${WORK_AREA}/rtl_fifo.f &
###############################
# Clean
###############################

clean: 
	rm -rf *.log  ./sim/* 
	

