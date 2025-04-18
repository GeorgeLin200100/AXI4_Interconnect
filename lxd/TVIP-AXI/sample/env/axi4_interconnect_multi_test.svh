`ifndef AXI4_INTERCONNECT_MULTI_TEST_SVH
`define AXI4_INTERCONNECT_MULTI_TEST_SVH

class axi4_interconnect_multi_test extends tvip_axi_sample_test;
  `uvm_component_utils(axi4_interconnect_multi_test)

  function new(string name = "axi4_interconnect_multi_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    
    foreach (master_sequencers[i]) begin
      uvm_config_db #(uvm_object_wrapper)::set(
        master_sequencers[i], "main_phase", "default_sequence", 
        tvip_axi_sample_write_read_sequence::type_id::get()
      );
    end
  endfunction

  task run_phase(uvm_phase phase);
    fork
      begin
        foreach (master_sequencers[i]) begin
          automatic int idx = i;
          fork
            master_sequencers[idx].start_phase_sequence(phase);
          join_none;
        end
        wait fork;
      end
      begin
        foreach (slave_sequencers[j]) begin
          automatic int idx = j;
          fork
            slave_sequencers[idx].start_phase_sequence(phase);
          join_none;
        end
        wait fork;
      end
    join
  endtask

endclass

`endif