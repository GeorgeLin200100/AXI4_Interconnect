`ifndef TVIP_AXI_OUTSTANDING_WRITE_SEQUENCE_SVH
`define TVIP_AXI_OUTSTANDING_WRITE_SEQUENCE_SVH

class tvip_axi_outstanding_write_sequence extends tvip_axi_base_sequence;
  int unsigned num_outstanding_writes = 4;
  tvip_axi_master_outstanding_access_sequence  write_sequences[$];
  tvip_axi_master_read_sequence   read_sequences[$];
  
  function new(string name = "tvip_axi_outstanding_write_sequence");
    super.new(name);
  endfunction

  task body();
    for (int i = 0;i < 5;++i) begin
      fork
        automatic int ii = i;
        do_outstanding_write_read_access_by_sequence(ii);
      join_none
    end
    wait fork;
  endtask

  task do_outstanding_write_read_access_by_sequence(int index);
    
    //int slave_idx = index % num_slaves;
    int slave_idx = 1;
    //for (int i = 0; i < num_outstanding_writes; i++) begin
      automatic tvip_axi_master_outstanding_access_sequence  write_sequence;
      automatic tvip_axi_master_outstanding_access_sequence cloned_t;
      `uvm_info("[OUSTANDING DEBUG]","write_sequence defined", UVM_LOW)
      `uvm_info("[OUSTANDING DEBUG]","read_sequence defined", UVM_LOW)
      `tue_do_with(write_sequence, {
        address >= get_slave_base_addr(slave_idx);
        address <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        (address + burst_size * burst_length) <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        address % (1 << burst_size) == 0; // 2^burst_size
      })
      $cast(cloned_t, write_sequence.clone());
      write_sequences.push_back(cloned_t);
      `uvm_info("[OUSTANDING DEBUG]","write_sequence randomized", UVM_LOW)
    //end
    // foreach (write_sequences[i]) begin
    //     write_sequences[i].wait_for_response();
    //     `uvm_info("[OUTSTANDING DEBUG]", "wait for response",UVM_LOW)
    // end
    foreach (write_sequences[i]) begin
      automatic tvip_axi_master_read_sequence   read_sequence;
      `tue_do_with(read_sequence, {
        address      == write_sequences[i].address;
        burst_size   == write_sequences[i].burst_size;
        burst_length >= write_sequences[i].burst_length;
      })
      `uvm_info("[OUSTANDING DEBUG]","read_sequence randomized", UVM_LOW)
      for (int i = 0;i < write_sequences[i].burst_length;++i) begin
        if (!compare_data(
          i,
          write_sequences[i].address, write_sequences[i].burst_size,
          write_sequences[i].strobe, write_sequences[i].data,
          read_sequence.data
        )) begin
          `uvm_error("CMPDATA", "write and read data are mismatched !!")
        end
      end
    end
  endtask

  `uvm_object_utils(tvip_axi_outstanding_write_sequence)
endclass

`endif 