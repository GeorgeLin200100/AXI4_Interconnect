`ifndef TVIP_AXI_OUTSTANDING_WRITE_SEQUENCE_SVH
`define TVIP_AXI_OUTSTANDING_WRITE_SEQUENCE_SVH

class tvip_axi_outstanding_write_sequence extends tvip_axi_base_sequence;
  // Number of outstanding writes to generate
  int unsigned num_outstanding_writes = 4;
  
  // Fixed master/slave indices for this test
  int unsigned master_idx = 2;
  int unsigned slave_idx = 1;
  
  function new(string name = "tvip_axi_outstanding_write_sequence");
    super.new(name);
  endfunction

  task body();
    do_outstanding_write_test();
  endtask

  task do_outstanding_write_test();
    tvip_axi_master_item write_items[$];
    tvip_axi_master_item response_items[$];
    
    `uvm_info(get_name(), $sformatf("Starting outstanding write test with master[%0d] to slave[%0d]", 
              master_idx, slave_idx), UVM_LOW)
    
    // Generate multiple write requests without waiting for responses
    for (int i = 0; i < num_outstanding_writes; ++i) begin
      tvip_axi_master_item write_item;
      
      `tue_do_with(write_item, {
        access_type == TVIP_AXI_WRITE_ACCESS;
        // Target the specific slave
        address >= get_slave_base_addr(slave_idx);
        address <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        (address + burst_size * burst_length) <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        address % (1 << burst_size) == 0; // 2^burst_size alignment
        
        // Add randomized burst configurations
        burst_length inside {[1:8]};
        burst_size inside {1, 2, 4, 8};
      })
      
      // Set need_response to 1 to get response objects
      write_item.need_response = 1;
      
      write_items.push_back(write_item);
      `uvm_info(get_name(), $sformatf("Generated write request %0d to addr 0x%0h", i, write_item.address), UVM_LOW)
    end
    
    // Wait for all responses to arrive
    `uvm_info(get_name(), "Waiting for responses from all outstanding writes", UVM_LOW)
    foreach (write_items[i]) begin
      tvip_axi_item response_item;
      wait_for_response(write_items[i], response_item);
      response_items.push_back(response_item);
      `uvm_info(get_name(), $sformatf("Received response %0d for addr 0x%0h", i, write_items[i].address), UVM_LOW)
    end
    
    // Verify all writes completed successfully
    foreach (write_items[i]) begin
      if (response_items[i].response[0] != TVIP_AXI_OKAY) begin
        `uvm_error(get_name(), $sformatf("Write %0d failed with response %s", 
                   i, response_items[i].response[0].name()))
      end
    end
    
    `uvm_info(get_name(), "Outstanding write test completed successfully", UVM_LOW)
  endtask

  `uvm_object_utils_begin(tvip_axi_outstanding_write_sequence)
    `uvm_field_int(num_outstanding_writes, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(master_idx, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(slave_idx, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass

`endif 