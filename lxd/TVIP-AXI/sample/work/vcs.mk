VCS_ARGS	+= -full64
VCS_ARGS	+= -lca
VCS_ARGS	+= -sverilog
VCS_ARGS	+= -l compile.log
VCS_ARGS	+= -timescale=1ns/1ps
VCS_ARGS	+= -ntb_opts uvm-$(UVM_VERSION)
VCS_ARGS	+= +define+UVM_NO_DEPRECATED+UVM_OBJECT_MUST_HAVE_CONSTRUCTO
VCS_ARGS	+= +define+UVM_VERDI_COMPWAVE
VCS_ARGS    += +lint=TFIPC-L
VCS_ARGS	+= -top top
VCS_ARGS	+= -debug_acc+all -debug_region+cell+encrypt



SIMV_ARGS	+= -l simv.log
SIMV_ARGS	+= -f test.f
SIMV_ARGS   += -cm line+cond+fsm+branch+tgl+assert
SIMV_ARGS   += -cm_name $(TEST)_cm
SIMV_ARGS   += -cm_dir ./cm
SIMV_ARGS   += +UVM_TR_RECORD
SIMV_ARGS   += +UVM_VERDI_TRACE="UVM_AWARE+RAL+HIER+COMPWAVE"
SIMV_ARGS   += +SEQ=$(SEQ)
SIMV_ARGS	+= +SCENARIO=$(SCENARIO)

ifeq ($(strip $(RANDOM_SEED)), auto)
	SIMV_ARGS	+= +ntb_random_seed_automatic
else
	SIMV_ARGS	+= +ntb_random_seed=$(RANDOM_SEED)
endif

ifeq ($(strip $(DUMP)), vpd)
	VCS_ARGS	+= -debug_access
	VCS_ARGS	+= +vcs+vcdpluson
	SIMV_ARGS	+= -vpd_file dump.vpd
endif

ifeq ($(strip $(DUMP)), fsdb)
	VCS_ARGS	+= -debug_access
	VCS_ARGS	+= -kdb
	VCS_ARGS	+= +vcs+fsdbon
	SIMV_ARGS	+= +fsdbfile+dump.fsdb
endif

ifeq ($(strip $(DUMP)), fsdb_zoix)
	VCS_ARGS	+= -debug_access
	VCS_ARGS	+= -kdb
	VCS_ARGS	+= +vcs+fsdbon
#	SIMV_ARGS	+= +fsdbfile+dump.fsdb
endif

ifeq ($(strip $(DUMP)), vcd_zoix)
	VCS_ARGS	+= -debug_access
	VCS_ARGS	+= -kdb
	VCS_ARGS	+= +vcs+fsdbon
#	SIMV_ARGS	+= +fsdbfile+dump.fsdb
endif

ifeq ($(strip $(GUI)), dve)
	VCS_ARGS	+= -debug_access+all
	VCS_ARGS	+= +vcs+vcdpluson
	SIMV_ARGS	+= -gui=dve
endif

ifeq ($(strip $(GUI)), verdi)
	VCS_ARGS	+= -debug_access+all
	VCS_ARGS	+= -kdb
	VCS_ARGS	+= +vcs+fsdbon
	SIMV_ARGS	+= -gui=verdi
endif

CLEAN_TARGET	+= simv*
CLEAN_TARGET	+= csrc
CLEAN_TARGET	+= *.h

CLEAN_ALL_TARGET += *.vpd
CLEAN_ALL_TARGET += *.fsdb
CLEAN_ALL_TARGET += *.key
CLEAN_ALL_TARGET += *.conf
#CLEAN_ALL_TARGET += *.rc
CLEAN_ALL_TARGET += DVEfiles
CLEAN_ALL_TARGET += verdiLog
CLEAN_ALL_TARGET += .inter.vpd.uvm

SIGNAL_FILE ?= all_signal.txt
SIGNAL_LIST := $(shell cat $(SIGNAL_FILE))
SIGNAL_NAME ?= $(shell head -n 1 $(SIGNAL_LIST) | awk '{print $$1}')
FORCE_VALUE ?= 1
FAULT_TYPE ?= 1

.PHONY: sim_vcs compile_vcs

sim_vcs:
	[ -f simv ] || ($(MAKE) compile_vcs)
	cd $(TEST); ../simv $(SIMV_ARGS)

compile_vcs:
	vcs $(VCS_ARGS) $(addprefix -f , $(FILE_LISTS)) $(SOURCE_FILES)

.PHONY: batch_fault_sim fault_sim fault_sim_% sim_get_signal verdi
#batch tests
batch_fault_sim:$(addprefix fault_sim_, $(SIGNAL_LIST))

fault_sim_%:
	@echo "$@ TEST=$(TEST) SEQ=$(SEQ) SCENARIO=$(SCENARIO) SIGNAL_NAME=$* FORCE_VALUE=$(FORCE_VALUE) FAULT_TYPE=$(FAULT_TYPE)";
	mkdir -p fault_test/sim_$*; \
	cp -f $(TEST)/test.f fault_test/sim_$*/test.f; \
	cd fault_test/sim_$*; \
	../../simv $(SIMV_ARGS) +FAULT_EN +SIGNAL_NAME=$* +FORCE_VALUE=$(FORCE_VALUE) +FAULT_TYPE=$(FAULT_TYPE) 

#single test
fault_sim:
	cp -f $(TEST)/test.f fault_test/test.f; cd fault_test; ../simv $(SIMV_ARGS) +FAULT_EN +SIGNAL_NAME=$(SIGNAL_NAME) +FORCE_VALUE=$(FORCE_VALUE) +FAULT_TYPE=$(FAULT_TYPE) 

#make sim_get_signal TEST=outstanding_access
sim_get_signal:
	cd $(TEST); ../simv $(SIMV_ARGS) -ucli -do ../get_all_signal.tcl 

verdi:
	verdi -ssf "${DIR_NAME}/dump.fsdb" -f compile.f


	
#export UVM_HOME=/home/ICer/uvm/uvm-1.2
ZOIX_ARGS += -l zoix.log
ZOIX_ARGS += +fault+var -w 
ZOIX_ARGS += -sverilog 
ZOIX_ARGS += -timescale=1ns/1ps
ZOIX_ARGS += +incdir+$(TVIP_AXI_HOME)/sample/env
ZOIX_ARGS += -top axi_tmr_safety_connector
#ZOIX_ARGS += -full64
#ZOIX_ARGS += -lca
#ZOIX_ARGS += +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv
#ZOIX_ARGS += $(UVM_HOME)/src/dpi/uvm_dpi.cc
#ZOIX_ARGS += -CFLAGS -DVCS
#ZOIX_ARGS += -ntb_opts uvm-$(UVM_VERSION)
#ZOIX_ARGS += +define+UVM_NO_DEPRECATED+UVM_OBJECT_MUST_HAVE_CONSTRUCTO
#ZOIX_ARGS += +define+UVM_VERDI_COMPWAVE
#ZOIX_ARGS += -debug_acc+all -debug_region+cell+encrypt

ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/priority_encoder.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/arbiter.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_crossbar_addr.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_register_wr.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_register_rd.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_crossbar_wr.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_crossbar_rd.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_crossbar.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi4_safety_connector.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_tmr_safety_connector.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_ds_1m3s.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_ds.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_unit.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_us_3m1s.v
ZOIX_SRC += $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_us.v

#ZOIX_SIM_ARGS += +fsdb+verify
.PHONY: zoix_all zoix_clean zoix_compile zoix_sim zoix_fmsh

zoix_all: zoix_clean zoix_compile zoix_fmsh

zoix_clean:
	cd zoix_work && \
	./clean.csh

zoix_compile:
	cd zoix_work && \
	$(ZOIXHOME)/bin/zoix $(ZOIX_ARGS) $(ZOIX_SRC)

zoix_sim:
	cd zoix_work && \
	./zoix.sim +fsdb+dut+top.u_connector.u_connector +fsdb+file+zoix_axi_connector.fsdb $(ZOIX_SIM_ARGS)

zoix_fmsh:
	cd zoix_work && \
	$(ZOIXHOME)/bin/fmsh -load axi_connector.fmsh