`ifndef TVIP_AXI_SAMPLE_PKG_SV
`define TVIP_AXI_SAMPLE_PKG_SV

package tvip_axi_sample_pkg;
  import uvm_pkg::*;
  import tue_pkg::*;
  import tvip_axi_types_pkg::*;
  import tvip_axi_pkg::*;

  `include "uvm_macros.svh"
  `include "tue_macros.svh"

  // handle multi-agent write function conflict
  `uvm_analysis_imp_decl(_m0)
  `uvm_analysis_imp_decl(_m1)
  `uvm_analysis_imp_decl(_m2)
  `uvm_analysis_imp_decl(_s0)
  `uvm_analysis_imp_decl(_s1)
  `uvm_analysis_imp_decl(_s2)
  `uvm_analysis_imp_decl(_s3)

  `define SLAVE_ADDR_REGION_SIZE  32'h00FF_FFFF
  `define SLAVE_0_BASE_ADDR       32'h0000_0000
  `define SLAVE_1_BASE_ADDR       32'h0100_0000
  `define SLAVE_2_BASE_ADDR       32'h0200_0000
  `define SLAVE_3_BASE_ADDR       32'h0300_0000

  `include "tvip_axi_sample_configuration.svh"
  `include "tvip_axi_scoreboard.svh"
  `include "tvip_axi_sample_write_read_sequence.svh"
  `include "tvip_axi_sample_test.svh"

endpackage

`endif
