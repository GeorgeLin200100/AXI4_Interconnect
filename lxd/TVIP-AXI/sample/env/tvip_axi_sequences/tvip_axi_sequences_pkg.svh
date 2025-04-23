`ifndef TVIP_AXI_SEQUENCES_PKG_SV
`define TVIP_AXI_SEQUENCES_PKG_SV

package tvip_axi_sequences_pkg;
  import uvm_pkg::*;
  import tue_pkg::*;
  import tvip_axi_types_pkg::*;
  import tvip_axi_pkg::*;

  `include "uvm_macros.svh"
  `include "tue_macros.svh"

  `include "top_defines.svh"

  `include "tvip_axi_base_sequence.svh"
  `include "tvip_axi_basic_write_read_sequence.svh"
  `include "tvip_axi_sequence_by_sequence.svh"
  `include "tvip_axi_sequence_by_item.svh"
  `include "tvip_axi_outstanding_write_sequence.svh"
  `include "tvip_axi_sequence_launcher.svh"
endpackage

`endif 