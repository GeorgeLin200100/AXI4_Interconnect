`ifndef TVIP_AXI_SEQUENCES_PKG_SV
`define TVIP_AXI_SEQUENCES_PKG_SV

package tvip_axi_sequences_pkg;
  import uvm_pkg::*;
  import tvip_axi_pkg::*;

  `include "uvm_macros.svh"
  `include "tvip_axi_macros.svh"

  `include "tvip_axi_base_sequence.svh"
  `include "tvip_axi_basic_write_read_sequence.svh"
  `include "tvip_axi_sequence_by_sequence.svh"
  `include "tvip_axi_sequence_by_item.svh"
  `include "tvip_axi_sequence_launcher.svh"
endpackage

`endif 