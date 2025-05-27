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
#VCS_ARGS	+= -debug_all 
#VCS_ARGS	+= +acc +vpi 
#VCS_ARGS	+= -debug_access+all
#VCS_ARGS	+= -debug_access+r+w+nomemcbk -debug_region+cell


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

SIGNAL_NAME ?= $(shell head -n 1 $(SIGNAL_LIST) | awk '{print $$1}')
FORCE_VALUE ?= 1
FAULT_TYPE ?= 1

.PHONY: sim_vcs compile_vcs

sim_vcs:
	[ -f simv ] || ($(MAKE) compile_vcs)
	cd $(TEST); ../simv $(SIMV_ARGS)

compile_vcs:
	vcs $(VCS_ARGS) $(addprefix -f , $(FILE_LISTS)) $(SOURCE_FILES)

#fault_sim_* signal_name=[ ] +force_value=[0/1] fault_type=[1/2]
fault_sim_%:
	cd fault_test; ../simv $(SIMV_ARGS) +FAULT_EN +SIGNAL_NAME=$(SIGNAL_NAME) +FORCE_VALUE=$(FORCE_VALUE) +FAULT_TYPE=$(FAULT_TYPE) 

#make sim_get_signal TEST=outstanding_access
sim_get_signal:
	cd $(TEST); ../simv $(SIMV_ARGS) -ucli -do ../get_all_signal.tcl 

verdi:
	verdi -ssf "${DIR_NAME}/dump.fsdb" -f compile.f