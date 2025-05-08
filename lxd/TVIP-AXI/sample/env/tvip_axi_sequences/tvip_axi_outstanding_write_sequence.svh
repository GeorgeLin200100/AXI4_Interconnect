`ifndef TVIP_AXI_OUTSTANDING_WRITE_SEQUENCE_SVH
`define TVIP_AXI_OUTSTANDING_WRITE_SEQUENCE_SVH

class tvip_axi_outstanding_write_sequence extends tvip_axi_base_sequence;
  tvip_axi_master_outstanding_access_sequence  write_sequences[$];
  tvip_axi_master_read_sequence   read_sequences[$];
  
  function new(string name = "tvip_axi_outstanding_write_sequence");
    super.new(name);
  endfunction

  task body();
    for (int i = 0;i < 1;++i) begin
      //fork
        automatic int ii = i;
        do_outstanding_write_read_access_by_sequence(ii);
      //join_none
    end
    //wait fork;
  endtask

  task do_outstanding_write_read_access_by_sequence(int index);
    int slave_idx;
    int slave_idx_real[10];
    string scenario;
    //int slave_idx = index % num_slaves;
      automatic tvip_axi_master_outstanding_access_sequence  write_sequence;
      //automatic tvip_axi_master_read_sequence   read_sequence;
      automatic tvip_axi_master_outstanding_access_sequence  read_sequence;
      automatic tvip_axi_master_outstanding_access_sequence cloned_t;
      `uvm_info("[OUSTANDING DEBUG]","write_sequence defined", UVM_LOW)
      `uvm_info("[OUSTANDING DEBUG]","read_sequence defined", UVM_LOW)
    if ($value$plusargs("SCENARIO=%s",scenario)) begin
      if (scenario == "1M1S") begin
        `uvm_info("SCENARIO", "IS 1M1S", UVM_LOW)
        foreach (slave_idx_real[i]) begin
          slave_idx_real[i] = 1;
        end
        slave_idx = 1; // dont care
      end else if (scenario == "1MnS") begin
        `uvm_info("SCENARIO", "IS 1MnS", UVM_LOW)
        foreach (slave_idx_real[i]) begin
          //slave_idx_real[i] = $urandom_range(3, 0); // slave 0,1,2,3
          randcase 
            50: slave_idx_real[i] = 1;
            50: slave_idx_real[i] = 3;
          endcase
          `uvm_info("SCENARIO", $sformatf("slave_idx_real[%0d]=%0d", i, slave_idx_real[i]), UVM_LOW)
        end
        slave_idx = 1; // dont care
      end
    end
      `tue_do_with(write_sequence, {
        address >= get_slave_base_addr(slave_idx); // don't care
        address >= get_slave_base_addr(slave_idx); // don't care
        (address + burst_size * burst_length) <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        address % (1 << burst_size) == 0; // 2^burst_size
        access_type == TVIP_AXI_WRITE_ACCESS;
        foreach (addr_new[i]) {
          addr_new[i] >= get_slave_base_addr(slave_idx_real[i]);
          addr_new[i] >= get_slave_base_addr(slave_idx_real[i]);
          (addr_new[i] + burst_size * burst_length) <= (get_slave_base_addr(slave_idx_real[i]) + addr_region_size - 1);
          addr_new[i] % (1 << burst_size) == 0; // 2^burst_size
        }
      })
      // $cast(cloned_t, write_sequence.clone());
      // write_sequences.push_back(cloned_t);
      // `uvm_info("[OUSTANDING DEBUG]","write_sequence randomized", UVM_LOW)
    //end
    // foreach (write_sequences[i]) begin
    //     write_sequences[i].wait_for_response();
    //     `uvm_info("[OUTSTANDING DEBUG]", "wait for response",UVM_LOW)
    // end
    //foreach (write_sequences[i]) begin
      `tue_do_with(read_sequence, {
        // address      == write_sequences[i].address;
        // burst_size   == write_sequences[i].burst_size;
        // burst_length >= write_sequences[i].burst_length;
        foreach (addr_new[i]) {
          addr_new[i] == write_sequence.addr_new[i];
        }
        address      == write_sequence.address;
        burst_size   == write_sequence.burst_size;
        burst_length == write_sequence.burst_length;
        access_type  == TVIP_AXI_READ_ACCESS;
      })
      `uvm_info("[OUSTANDING DEBUG]","read_sequence randomized", UVM_LOW)
      foreach (read_sequence.addr_new[i]) begin
        `uvm_info("[ADDRESS DEBUG]", $sformatf("w:%0h, r:%0h", write_sequence.addr_new[i], read_sequence.addr_new[i]), UVM_LOW)
      end
      for (int i = 0;i < write_sequence.burst_length;++i) begin
        foreach(write_sequence.addr_new[j]) begin
          if (!compare_data(
            i,
            write_sequence.addr_new[j], write_sequence.burst_size,
            write_sequence.strobe, write_sequence.data_new[j],
            read_sequence.responses[write_sequence.ids[j]].data
          )) begin
            `uvm_error("CMPDATA", "write and read data are mismatched !!")
          end
        end
      end
    //end
  endtask

  `uvm_object_utils(tvip_axi_outstanding_write_sequence)
endclass

`endif 