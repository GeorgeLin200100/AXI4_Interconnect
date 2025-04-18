`ifndef TVIP_AXI_SCOREBOARD_SVH
`define TVIP_AXI_SCOREBOARD_SVH

class tvip_axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(tvip_axi_scoreboard)

  // Define coverage group types
  typedef enum {
    TVIP_AXI_FIXED,
    TVIP_AXI_INCR,
    TVIP_AXI_WRAP
  } tvip_axi_burst_type_e;

  typedef enum {
    TVIP_AXI_OKAY,
    TVIP_AXI_EXOKAY,
    TVIP_AXI_SLVERR,
    TVIP_AXI_DECERR
  } tvip_axi_response_e;

  typedef enum {
    TVIP_AXI_READ,
    TVIP_AXI_WRITE
  } tvip_axi_access_type_e;

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

  // Transaction ID tracking
  typedef struct {
    tvip_axi_item transaction;
    int master_idx;
    int source_id;  // Add source tracking
  } pending_transaction_t;
  
  pending_transaction_t pending_transactions[int][$];

  pending_transaction_t pending_t;
  
  // Queue for slave transactions that arrive before their master transactions
  typedef struct {
    tvip_axi_item transaction;
    int slave_idx;
    int source_id;  // Add source tracking
  } pending_slave_transaction_t;
  
  pending_slave_transaction_t pending_slave_transactions[int][$];

  pending_slave_transaction_t pending_slave_t;
  
  // Address map for interconnect
  typedef struct {
    tvip_axi_address start_addr;
    tvip_axi_address end_addr;
    int slave_idx;
  } addr_map_entry_t;
  
  addr_map_entry_t addr_map[$] = '{
    '{`SLAVE_0_BASE_ADDR, `SLAVE_0_BASE_ADDR+`SLAVE_ADDR_REGION_SIZE, 0},
    '{`SLAVE_1_BASE_ADDR, `SLAVE_1_BASE_ADDR+`SLAVE_ADDR_REGION_SIZE, 1},
    '{`SLAVE_2_BASE_ADDR, `SLAVE_2_BASE_ADDR+`SLAVE_ADDR_REGION_SIZE, 2},
    '{`SLAVE_3_BASE_ADDR, `SLAVE_3_BASE_ADDR+`SLAVE_ADDR_REGION_SIZE, 3}
  };

  // Coverage collection
  covergroup axi_transaction_cg with function sample(tvip_axi_item t);
    // Address coverage
    address_cp: coverpoint t.address {
      bins slave0 = {[`SLAVE_0_BASE_ADDR:`SLAVE_0_BASE_ADDR+`SLAVE_ADDR_REGION_SIZE]};
      bins slave1 = {[`SLAVE_1_BASE_ADDR:`SLAVE_1_BASE_ADDR+`SLAVE_ADDR_REGION_SIZE]};
      bins slave2 = {[`SLAVE_2_BASE_ADDR:`SLAVE_2_BASE_ADDR+`SLAVE_ADDR_REGION_SIZE]};
      bins slave3 = {[`SLAVE_3_BASE_ADDR:`SLAVE_3_BASE_ADDR+`SLAVE_ADDR_REGION_SIZE]};
      bins invalid = default;
    }
    
    // Burst type coverage
    burst_type_cp: coverpoint t.burst_type {
      bins fixed = {TVIP_AXI_FIXED_BURST};
      bins incr = {TVIP_AXI_INCREMENTING_BURST};
      bins wrap = {TVIP_AXI_WRAPPING_BURST};
    }
    
    // Burst length coverage
    burst_length_cp: coverpoint t.burst_length {
      bins lengths[] = {1, 2, 4, 8, 16, 32, 64, 128, 256};
    }
    
    // Response coverage
    response_cp: coverpoint t.response[0] {
      bins okay = {TVIP_AXI_OKAY};
      bins exokay = {TVIP_AXI_EXOKAY};
      bins slverr = {TVIP_AXI_SLAVE_ERROR};
      bins decerr = {TVIP_AXI_DECODE_ERROR};
    }
    
    // Access type coverage
    access_type_cp: coverpoint t.access_type {
      bins read = {TVIP_AXI_READ_ACCESS};
      bins write = {TVIP_AXI_WRITE_ACCESS};
    }
    
    // Burst size coverage
    burst_size_cp: coverpoint t.burst_size {
      bins size_1 = {TVIP_AXI_BURST_SIZE_1_BYTE};   // 1 byte
      bins size_2 = {TVIP_AXI_BURST_SIZE_2_BYTES};   // 2 bytes
      bins size_4 = {TVIP_AXI_BURST_SIZE_4_BYTES};   // 4 bytes
      bins size_8 = {TVIP_AXI_BURST_SIZE_8_BYTES};   // 8 bytes
      bins size_16 = {TVIP_AXI_BURST_SIZE_16_BYTES};  // 16 bytes
      bins size_32 = {TVIP_AXI_BURST_SIZE_32_BYTES};  // 32 bytes
      bins size_64 = {TVIP_AXI_BURST_SIZE_64_BYTES};  // 64 bytes
      bins size_128 = {TVIP_AXI_BURST_SIZE_128_BYTES}; // 128 bytes
    }
    
    // Cross coverage between burst type and length
    burst_type_x_length: cross burst_type_cp, burst_length_cp;
    
    // Cross coverage between access type and response
    access_x_response: cross access_type_cp, response_cp;
    
    // Cross coverage between burst size and length
    size_x_length: cross burst_size_cp, burst_length_cp;
  endgroup

  axi_transaction_cg axi_cg = new();

  // Coverage collection for transaction ordering
  covergroup axi_ordering_cg with function sample(int master_idx, int slave_idx);
    master_slave_cp: coverpoint master_idx {
      bins m0 = {0};
      bins m1 = {1};
      bins m2 = {2};
    }
    
    slave_cp: coverpoint slave_idx {
      bins s0 = {0};
      bins s1 = {1};
      bins s2 = {2};
      bins s3 = {3};
    }
    
    master_slave_x: cross master_slave_cp, slave_cp;
  endgroup

  axi_ordering_cg ordering_cg = new();

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
    // Sample coverage for master transaction
    axi_cg.sample(cloned_t);
  endfunction

  // Write function for master analysis ports
  function void write_m0(tvip_axi_item t);
    `uvm_info("[WRITE_M0 CALLED]", $sformatf("%0h,%0d", t.address, t.id), UVM_LOW)
    process_master_transaction(0, t);

    `uvm_info("[ABOUT TO ENTER SLAVE PENDING CHECK]]", $sformatf("%0h, %0d", t.address, pending_slave_transactions.size()), UVM_LOW)
    //`uvm_info("[WRITE_M0 ITEM]", $sformatf("%s",t.sprint()), UVM_LOW)
    // Process any pending slave transactions for this ID
    if (pending_slave_transactions.exists(t.id)) begin
      `uvm_info("[PENDING_SLAVE_TRAN EXISTS]", $sformatf("%0h", t.address), UVM_LOW)
      foreach (pending_slave_transactions[t.id][i]) begin
        process_slave_transaction(pending_slave_transactions[t.id][i].slave_idx, 
                                pending_slave_transactions[t.id][i].transaction);
      end
      pending_slave_transactions.delete(t.id);
    end else begin
      pending_t.transaction = t;
      pending_t.master_idx = 0;
      pending_transactions[t.id].push_back(pending_t);
    end
  endfunction

  function void write_m1(tvip_axi_item t);
    `uvm_info("[WRITE_M1 CALLED]", $sformatf("%0h, %0d", t.address, t.id), UVM_LOW)
    process_master_transaction(1, t);
    
    // Process any pending slave transactions for this ID
    if (pending_slave_transactions.exists(t.id)) begin
      foreach (pending_slave_transactions[t.id][i]) begin
        process_slave_transaction(pending_slave_transactions[t.id][i].slave_idx, 
                                pending_slave_transactions[t.id][i].transaction);
      end
      pending_slave_transactions.delete(t.id);
    end else begin
      pending_t.transaction = t;
      pending_t.master_idx = 1;
      pending_transactions[t.id].push_back(pending_t);
    end
  endfunction

  function void write_m2(tvip_axi_item t);
    `uvm_info("[WRITE_M2 CALLED]", $sformatf("%0h, %0d", t.address, t.id), UVM_LOW)
    process_master_transaction(2, t);
    
    
    
    // Process any pending slave transactions for this ID
    if (pending_slave_transactions.exists(t.id)) begin
      foreach (pending_slave_transactions[t.id][i]) begin
        process_slave_transaction(pending_slave_transactions[t.id][i].slave_idx, 
                                pending_slave_transactions[t.id][i].transaction);
      end
      pending_slave_transactions.delete(t.id);
    end else begin
      pending_t.transaction = t;
      pending_t.master_idx = 2;
      pending_transactions[t.id].push_back(pending_t);
    end
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
    // Sample coverage for slave transaction
    axi_cg.sample(cloned_t);
    // Sample ordering coverage
    ordering_cg.sample(pending_t.master_idx, idx);
  endfunction

    // Write function for slave analysis ports
  function void write_s0(tvip_axi_item t);
    `uvm_info("[WRITE_S0 CALLED]", $sformatf("%0h", t.address), UVM_LOW)
    if (pending_transactions.exists(t.id) && pending_transactions[t.id].size() > 0) begin
      // Get the oldest pending transaction with this ID
      `uvm_info("[WRITE_SO PEND_MST_T EXIST]", $sformatf("%0h", t.address), UVM_LOW)
      pending_t = pending_transactions[t.id][0];
      process_slave_transaction(0, t);
      pending_transactions[t.id].pop_front();
    end else begin
      // Queue the slave transaction if master hasn't arrived yet
      `uvm_info("[WRITE_SO PEND_SLAVE_T PUSH BACK]", $sformatf("%0h, %0d", t.address, t.id), UVM_LOW)
      //`uvm_info("[WRITE_S0 ITEM]", $sformatf("%s",t.sprint()), UVM_LOW)
      if (!pending_slave_transactions.exists(t.id)) begin
        pending_slave_transactions[t.id]={};
      end
      pending_slave_t.transaction = t;
      pending_slave_t.slave_idx = 0;
      pending_slave_transactions[t.id].push_back(pending_slave_t);
      if (!pending_slave_transactions.exists(t.id)) begin
        `uvm_info("[HAVEN'T PUSH BACK PENDING SLAVE TRANS]", $sformatf("%0h, %0d", t.address, t.id), UVM_LOW)
      end
    end
  endfunction

  function void write_s1(tvip_axi_item t);
    `uvm_info("[WRITE_S1 CALLED]", $sformatf("%0h", t.address), UVM_LOW)
    if (pending_transactions.exists(t.id) && pending_transactions[t.id].size() > 0) begin
      // Get the oldest pending transaction with this ID
      pending_t = pending_transactions[t.id][0];
      process_slave_transaction(1, t);
      pending_transactions[t.id].pop_front();
    end else begin
      // Queue the slave transaction if master hasn't arrived yet
      `uvm_info("[WRITE_S1 PEND_SLAVE_T PUSH BACK]", $sformatf("%0h, %0d", t.address, t.id), UVM_LOW)
      if (!pending_slave_transactions.exists(t.id)) begin
        pending_slave_transactions[t.id]={};
      end
      pending_slave_t.transaction = t;
      pending_slave_t.slave_idx = 1;
      pending_slave_transactions[t.id].push_back(pending_slave_t);
    end
  endfunction

  function void write_s2(tvip_axi_item t);
    `uvm_info("[WRITE_S2 CALLED]", $sformatf("%0h", t.address), UVM_LOW)
    if (pending_transactions.exists(t.id) && pending_transactions[t.id].size() > 0) begin
      // Get the oldest pending transaction with this ID
      pending_t = pending_transactions[t.id][0];
      process_slave_transaction(2, t);
      pending_transactions[t.id].pop_front();
    end else begin
      // Queue the slave transaction if master hasn't arrived yet
      `uvm_info("[WRITE_S2 PEND_SLAVE_T PUSH BACK]", $sformatf("%0h, %0d", t.address, t.id), UVM_LOW)
      if (!pending_slave_transactions.exists(t.id)) begin
        pending_slave_transactions[t.id]={};
      end
      pending_slave_t.transaction = t;
      pending_slave_t.slave_idx = 2;
      pending_slave_transactions[t.id].push_back(pending_slave_t);
    end
  endfunction

  function void write_s3(tvip_axi_item t);
    `uvm_info("[WRITE_S3 CALLED]", $sformatf("%0h", t.address), UVM_LOW)
    if (pending_transactions.exists(t.id) && pending_transactions[t.id].size() > 0) begin
      // Get the oldest pending transaction with this ID
      pending_t = pending_transactions[t.id][0];
      process_slave_transaction(3, t);
      pending_transactions[t.id].pop_front();
    end else begin
      // Queue the slave transaction if master hasn't arrived yet
      if (!pending_slave_transactions.exists(t.id)) begin
        pending_slave_transactions[t.id]={};
      end
      pending_slave_t.transaction = t;
      pending_slave_t.slave_idx = 3;
      pending_slave_transactions[t.id].push_back(pending_slave_t);
    end
  endfunction

  // Function to verify address decoding
  function bit verify_address_decoding(tvip_axi_item t);
    int expected_slave_idx = -1;
    `uvm_info("[SENT ADDR]", $sformatf("%0h", t.address), UVM_LOW)
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
    
    // Check burst length limits
    if (t.burst_length > 256) begin
      `uvm_error("PROTOCOL", $sformatf("Burst length %0d exceeds AXI4 maximum of 256", t.burst_length))
      return 0;
    end
    
    // // Check wrap burst alignment
    // if (t.burst_type == TVIP_AXI_WRAPPING_BURST) begin
    //   int wrap_boundary = t.burst_length * (1 << t.burst_size);
    //   if ((t.address % wrap_boundary) != 0) begin
    //     `uvm_error("PROTOCOL", $sformatf("Wrap burst address 0x%0h not aligned to wrap boundary %0d", 
    //               t.address, wrap_boundary))
    //     return 0;
    //   end
    // end
    
    // Check burst type compatibility
    if (t.burst_type == TVIP_AXI_FIXED_BURST) begin
      if (t.burst_length > 16) begin
        `uvm_error("PROTOCOL", "Fixed burst length exceeds maximum of 16")
        return 0;
      end
    end

    // // Check narrow transfers
    // if (t.burst_size < t.data_width) begin
    //   if (t.burst_type == TVIP_AXI_WRAPPING_BURST) begin
    //     `uvm_error("PROTOCOL", "Narrow transfers not allowed with wrap burst type")
    //     return 0;
    //   end
    // end
    
    return 1;
  endfunction

  // Function to check if a transaction matches any expected transaction
  function void check_transaction(tvip_axi_item actual);
    bit found = 0;
    foreach (expected_transactions[i]) begin
      if (compare_transactions(actual, expected_transactions[i])) begin
        found = 1;
        verify_response(expected_transactions[i], actual);
        `uvm_info("EXPECT_TRANSACTION_SIZE", $sformatf("%0d",expected_transactions.size()),UVM_LOW)
        expected_transactions.delete(i);
        `uvm_info("EXPECT_TRANSACTION_SIZE1", $sformatf("%0d",expected_transactions.size()),UVM_LOW)
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
    
    // Check all response beats
    foreach (response.response[i]) begin
      if (!(response.response[i] inside {TVIP_AXI_OKAY, TVIP_AXI_EXOKAY, TVIP_AXI_SLAVE_ERROR, TVIP_AXI_DECODE_ERROR})) begin
        `uvm_error("RESPONSE", $sformatf("Invalid response type at beat %0d: %0d", 
                  i, response.response[i]))
        return 0;
      end
    end
    
    // // For write transactions, verify byte strobes
    // if (request.access_type == TVIP_AXI_WRITE_ACCESS) begin
    //   if (request.byte_enable.size() != response.byte_enable.size()) begin
    //     `uvm_error("RESPONSE", "Byte enable size mismatch between request and response")
    //     return 0;
    //   end
    //   foreach (request.byte_enable[i]) begin
    //     if (request.byte_enable[i] != response.byte_enable[i]) begin
    //       `uvm_error("RESPONSE", $sformatf("Byte enable mismatch at index %0d", i))
    //       return 0;
    //     end
    //   end
    // end
    
    return 1;
  endfunction

  // Function to compare two transactions
  function bit compare_transactions(tvip_axi_item t1, tvip_axi_item t2);
    `uvm_info("ACCESS_TYPE MATCHED", $sformatf("%0d,%0d", t1.access_type, t2.access_type), UVM_LOW) 
    `uvm_info("ADDRESS MATCHED", $sformatf("%0h,%0h", t1.address, t2.address), UVM_LOW) 
    `uvm_info("BURST_SIZE MATCHED", $sformatf("%0d,%0d", t1.burst_size, t2.burst_size), UVM_LOW) 
    `uvm_info("BURST_LENGTH MATCHED", $sformatf("%0d,%0d", t1.burst_length, t2.burst_length), UVM_LOW) 
    `uvm_info("DATA_SIZE MATCHED", $sformatf("%0d,%0d", t1.data.size(), t2.data.size()), UVM_LOW) 
    if (t1.access_type != t2.access_type) 
      return 0;
    if (t1.address != t2.address) return 0;
    if (t1.burst_size != t2.burst_size) return 0;
    if (t1.burst_length != t2.burst_length) return 0; 
    if (t1.data.size() != t2.data.size()) return 0;  
    for (int i = 0; i < t1.data.size(); i++) begin
      if (t1.data[i] != t2.data[i]) return 0;
    end
    
    // foreach (t1.byte_enable[i]) begin
    //   if (t1.byte_enable[i] != t2.byte_enable[i]) return 0;
    // end
    
    return 1;
  endfunction

  // Check for any remaining expected transactions at the end of simulation
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    if (expected_transactions.size() > 0) begin
      `uvm_error("SCOREBOARD", $sformatf("There are %0d expected transactions that were not received", 
                expected_transactions.size()))
    end

    // Cleanup pending transactions
    foreach (pending_transactions[id]) begin
      pending_transactions[id].delete();
    end
    
    foreach (pending_slave_transactions[id]) begin
      pending_slave_transactions[id].delete();
    end

    `uvm_info("COVERAGE", "Coverage Report:", UVM_LOW)
    `uvm_info("COVERAGE", $sformatf("Transaction Coverage: %0.2f%%", axi_cg.get_coverage()), UVM_LOW)
    `uvm_info("COVERAGE", $sformatf("Ordering Coverage: %0.2f%%", ordering_cg.get_coverage()), UVM_LOW)
  endfunction

endclass

`endif 