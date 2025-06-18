#TVIP_AXI_HOME	= $(shell git rev-parse --show-toplevel)
TVIP_AXI_HOME = $(shell git rev-parse --show-toplevel)/lxd/TVIP-AXI
export TVIP_AXI_HOME

TUE_HOME	?= $(TVIP_AXI_HOME)/tue
export TUE_HOME

TVIP_COMMON_HOME	?= $(TVIP_AXI_HOME)/tvip-common
export TVIP_COMMON_HOME

FILE_LISTS	+= $(TUE_HOME)/compile.f
FILE_LISTS	+= $(TVIP_COMMON_HOME)/compile.f
FILE_LISTS	+= $(TVIP_AXI_HOME)/compile.f
FILE_LISTS	+= $(TVIP_AXI_HOME)/sample/env/compile.f

#SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/tvip_axi_sample_delay.sv
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/priority_encoder.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/arbiter.v
#SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi_interconnect.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi_crossbar_addr.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi_register_wr.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi_register_rd.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi_crossbar_wr.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi_crossbar_rd.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi_crossbar.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi4_safety_connector.v
SOURCE_FILES    += $(TVIP_AXI_HOME)/sample/env/axi4_safety_connector_wrapper.sv
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/top.sv
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_tmr_safety_connector.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_ds_1m3s.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_ds.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_unit.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_us_3m1s.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_tmr_voter_us.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_sft_crossbar_wr.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_sft_crossbar_rd.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_sft_crossbar_addr.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_sft_register_wr.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_sft_register_rd.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_sft_tmr_crossbar_addr.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/ecc_d64b_p7_func.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/sft_arbiter.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/sft_priority_encoder.v
SOURCE_FILES	+= $(TVIP_AXI_HOME)/sample/env/axi_tmr_simple_voter.v

SIMULATOR	?= vcs
RANDOM_SEED	?= auto
DUMP	?= fsdb
GUI	?= off
UVM_VERSION ?= 1.2
SEQ ?= AABBCCDD
SCENARIO ?= 1M1S

TESTS	+= default
TESTS	+= request_delay
TESTS	+= response_delay
TESTS	+= ready_delay
TESTS	+= out_of_order_response
TESTS	+= read_interleave
TESTS	+= wvalid_preceding_awvalid

.PHONY: all $(TESTS) clean clean_all

all: $(TESTS)

$(TESTS):
	make sim_$(SIMULATOR) TEST=$@

CLEAN_TARGET	+= *.log
CLEAN_ALL_TARGET += *.log
CLEAN_ALL_TARGET += *.key
CLEAN_ALL_TARGET += *.vdb

clean:
	rm -rf $(CLEAN_TARGET)

clean_all:
	make clean
	rm -rf $(CLEAN_ALL_TARGET)
	rm -rf $(addprefix */,$(CLEAN_ALL_TARGET))

include vcs.mk
include xcelium.mk
include vivado.mk
include dsim.mk
