`ifndef TVIP_AXI_SCOREBOARD_SVH
`define TVIP_AXI_SCOREBOARD_SVH

class tvip_axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(tvip_axi_scoreboard)

  // Analysis ports for master and slave transactions
  //uvm_analysis_imp #(tvip_axi_item, tvip_axi_scoreboard) master_imp[3];
  //uvm_analysis_imp #(tvip_axi_item, tvip_axi_scoreboard) slave_imp[4];

  uvm_analysis_imp_m0 #(tvip_axi_item, tvip_axi_scoreboard) master_imp_m0;
  uvm_analysis_imp_m1 #(tvip_axi_item, tvip_axi_scoreboard) master_imp_m1;
  uvm_analysis_imp_m2 #(tvip_axi_item, tvip_axi_scoreboard) master_imp_m2;
  uvm_analysis_imp_s0 #(tvip_axi_item, tvip_axi_scoreboard) slave_imp_s0;
  uvm_analysis_imp_s1 #(tvip_axi_item, tvip_axi_scoreboard) slave_imp_s1;
  uvm_analysis_imp_s2 #(tvip_axi_item, tvip_axi_scoreboard) slave_imp_s2;
  uvm_analysis_imp_s3 #(tvip_axi_item, tvip_axi_scoreboard) slave_imp_s3;
  // Queues to store expected and actual transactions
  tvip_axi_item expected_transactions[$];
  tvip_axi_item actual_transactions[$];
  
  // Transaction ordering queues
  tvip_axi_item master_ordered_transactions[3][$];
  tvip_axi_item slave_ordered_transactions[4][$];
  
  // Address map for interconnect
  typedef struct {
    tvip_axi_address start_addr;
    tvip_axi_address end_addr;
    int slave_idx;
  } addr_map_entry_t;
  
  addr_map_entry_t addr_map[$] = '{
    '{64'h0000_0000_0000_0000, 64'h0000_FFFF_FFFF_FFFF, 0},
    '{64'h0001_0000_0000_0000, 64'h0001_FFFF_FFFF_FFFF, 1},
    '{64'h0002_0000_0000_0000, 64'h0002_FFFF_FFFF_FFFF, 2},
    '{64'h0003_0000_0000_0000, 64'h0003_FFFF_FFFF_FFFF, 3}
  };

  function new(string name = "tvip_axi_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    // for (int i = 0; i < 3; i++) begin
    //   master_imp[i] = new($sformatf("master_imp[%0d]", i), this);
    // end
    // for (int i = 0; i < 4; i++) begin
    //   slave_imp[i] = new($sformatf("slave_imp[%0d]", i), this);
    // end
    master_imp_m0 = new("master_imp_m0", this);
    master_imp_m1 = new("master_imp_m1", this);
    master_imp_m2 = new("master_imp_m2", this);
    slave_imp_s0 = new("slave_imp_s0", this);
    slave_imp_s1 = new("slave_imp_s1", this);
    slave_imp_s2 = new("slave_imp_s2", this);
    slave_imp_s3 = new("slave_imp_s3", this);

  endfunction

  // // Write function for master analysis ports
  // function void write(tvip_axi_item t);
  //   // The write method is called by the analysis port, so we can use the port's index
  //   // to determine which master it came from
  //   int idx = 0;
  //   foreach (master_imp[i]) begin
  //     if (master_imp[i] == this.m_imp) begin
  //       idx = i;
  //       break;
  //     end
  //   end
  //   process_master_transaction(idx, t);
  // endfunction

  // Write function for master analysis ports
  function void process_master_transaction(int idx, tvip_axi_item t);
    tvip_axi_item cloned_t;
    $cast(cloned_t, t.clone());
    expected_transactions.push_back(cloned_t);
    master_ordered_transactions[idx].push_back(cloned_t);
    verify_address_decoding(cloned_t);
    verify_protocol(cloned_t);
  endfunction

  // Write function for master analysis ports
  function void write_m0(tvip_axi_item t);
    process_master_transaction(0, t);
  endfunction

  function void write_m1(tvip_axi_item t);
    process_master_transaction(1, t);
  endfunction

  function void write_m2(tvip_axi_item t);
    process_master_transaction(2, t);
  endfunction

  // // Write function for slave analysis ports
  // function void write_slave(tvip_axi_item t);
  //   int idx = 0;
  //   // Determine which slave port this came from
  //   foreach (slave_imp[i]) begin
  //     if (slave_imp[i] == this.s_imp) begin
  //       idx = i;
  //       break;
  //     end
  //   end
  //   process_slave_transaction(idx, t);
  // endfunction

  // Helper function to process slave transactions
  function void process_slave_transaction(int idx, tvip_axi_item t);
    tvip_axi_item cloned_t;
    $cast(cloned_t, t.clone());
    actual_transactions.push_back(cloned_t);
    slave_ordered_transactions[idx].push_back(cloned_t);
    check_transaction(cloned_t);
    verify_transaction_ordering(idx, cloned_t);
  endfunction

    // Write function for slave analysis ports
  function void write_s0(tvip_axi_item t);
    process_slave_transaction(0, t);
  endfunction

  function void write_s1(tvip_axi_item t);
    process_slave_transaction(1, t);
  endfunction

  function void write_s2(tvip_axi_item t);
    process_slave_transaction(2, t);
  endfunction

  function void write_s3(tvip_axi_item t);
    process_slave_transaction(3, t);
  endfunction

  // Function to verify address decoding
  function bit verify_address_decoding(tvip_axi_item t);
    int expected_slave_idx = -1;
    foreach (addr_map[i]) begin
      if (t.address >= addr_map[i].start_addr && t.address <= addr_map[i].end_addr) begin
        expected_slave_idx = addr_map[i].slave_idx;
        break;
      end
    end
    
    if (expected_slave_idx == -1) begin
      `uvm_error("ADDR_DECODE", $sformatf("Address 0x%0h is not mapped to any slave", t.address))
      return 0;
    end
    
    return 1;
  endfunction

  // Function to verify transaction ordering
  function bit verify_transaction_ordering(int slave_idx, tvip_axi_item t);
    if (t.access_type == TVIP_AXI_WRITE_ACCESS) begin
      // For writes, check AW channel ordering
      if (slave_ordered_transactions[slave_idx].size() > 1) begin
        tvip_axi_item prev_t = slave_ordered_transactions[slave_idx][$];
        if (prev_t.id == t.id && prev_t.address > t.address) begin
          `uvm_error("ORDER", $sformatf("Write transaction ordering violation: ID=%0d, Addr=0x%0h", t.id, t.address))
          return 0;
        end
      end
    end
    else begin
      // For reads, check AR channel ordering
      if (slave_ordered_transactions[slave_idx].size() > 1) begin
        tvip_axi_item prev_t = slave_ordered_transactions[slave_idx][$];
        if (prev_t.id == t.id && prev_t.address > t.address) begin
          `uvm_error("ORDER", $sformatf("Read transaction ordering violation: ID=%0d, Addr=0x%0h", t.id, t.address))
          return 0;
        end
      end
    end
    return 1;
  endfunction

  // Function to verify AXI4 protocol
  function bit verify_protocol(tvip_axi_item t);
    // Check address alignment
    if (t.burst_size > 0) begin
      int alignment = 1 << t.burst_size;
      if ((t.address % alignment) != 0) begin
        `uvm_error("PROTOCOL", $sformatf("Address 0x%0h not aligned to burst size %0d", t.address, t.burst_size))
        return 0;
      end
    end
    
    // Check burst type compatibility
    if (t.burst_type == TVIP_AXI_FIXED_BURST) begin
      if (t.burst_length > 16) begin
        `uvm_error("PROTOCOL", "Fixed burst length exceeds maximum of 16")
        return 0;
      end
    end
    
    return 1;
  endfunction

  // Function to check if a transaction matches any expected transaction
  function void check_transaction(tvip_axi_item actual);
    bit found = 0;
    foreach (expected_transactions[i]) begin
      if (compare_transactions(actual, expected_transactions[i])) begin
        found = 1;
        verify_response(expected_transactions[i], actual);
        expected_transactions.delete(i);
        break;
      end
    end
    if (!found) begin
      `uvm_error("SCOREBOARD", $sformatf("Unexpected transaction received: %s", actual.sprint()))
    end
  endfunction

  // Function to verify response
  function bit verify_response(tvip_axi_item request, tvip_axi_item response);
    if (request.access_type != response.access_type) begin
      `uvm_error("RESPONSE", "Request and response access types don't match")
      return 0;
    end
    
    if (request.id != response.id) begin
      `uvm_error("RESPONSE", "Request and response IDs don't match")
      return 0;
    end
    
    if (!(response.response[0] inside {TVIP_AXI_OKAY, TVIP_AXI_EXOKAY})) begin
      `uvm_error("RESPONSE", $sformatf("Unexpected response type: %0d", response.response[0]))
      return 0;
        end
    
    return 1;
  endfunction

  // Function to compare two transactions
  function bit compare_transactions(tvip_axi_item t1, tvip_axi_item t2);
    if (t1.access_type != t2.access_type) return 0;
    if (t1.address != t2.address) return 0;
    if (t1.burst_size != t2.burst_size) return 0;
    if (t1.burst_length != t2.burst_length) return 0;
    if (t1.data.size() != t2.data.size()) return 0;
    for (int i = 0; i < t1.data.size(); i++) begin
      if (t1.data[i] != t2.data[i]) return 0;
    end
    return 1;
  endfunction

  // Check for any remaining expected transactions at the end of simulation
  function void report_phase(uvm_phase phase);
    if (expected_transactions.size() > 0) begin
      `uvm_error("SCOREBOARD", $sformatf("There are %0d expected transactions that were not received", 
                expected_transactions.size()))
    end
  endfunction

endclass

`endif 