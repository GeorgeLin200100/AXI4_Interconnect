`ifndef TVIP_AXI_SAMPLE_PKG_SV
`define TVIP_AXI_SAMPLE_PKG_SV

package tvip_axi_sample_pkg;
  import uvm_pkg::*;
  import tue_pkg::*;
  import tvip_axi_types_pkg::*;
  import tvip_axi_pkg::*;
  import tvip_axi_sequences_pkg::*;

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

  `include "top_defines.svh"
  `include "tvip_axi_sample_configuration.svh"
  `include "tvip_axi_scoreboard.svh"
  //`include "tvip_axi_sample_write_read_sequence.svh"
  // `include "tvip_axi_sequences/tvip_axi_sequence_pkg.svh"
  `include "tvip_axi_fault.svh"
  `include "tvip_axi_sample_test.svh"

endpackage

`endif
