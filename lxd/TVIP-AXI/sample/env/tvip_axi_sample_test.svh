`ifndef TVIP_AXI_SAMPLE_TEST_SVH
`define TVIP_AXI_SAMPLE_TEST_SVH
class tvip_axi_sample_test extends tue_test #(
  .CONFIGURATION  (tvip_axi_sample_configuration)
);
  tvip_axi_master_agent     master_agents[];
  tvip_axi_master_sequencer master_sequencers[];
  tvip_axi_slave_agent      slave_agents[];
  tvip_axi_slave_sequencer  slave_sequencers[];

  function new(string name = "tvip_axi_sample_test", uvm_component parent = null);
    super.new(name, parent);
    `ifndef XILINX_SIMULATOR
      `uvm_info("SRANDOM", $sformatf("Initial random seed: %0d", $get_initial_random_seed), UVM_NONE)
    `endif
  endfunction

  function void create_configuration();
    super.create_configuration();
    for (int i = 0; i < 7; i++) begin
      void'(uvm_config_db #(tvip_axi_vif)::get(null, "", $sformatf("vif[%0d]", i), configuration.axi_cfg[i].vif));
    end
    if (configuration.randomize()) begin
      `uvm_info(get_name(), $sformatf("configuration...\n%s", configuration.sprint()), UVM_NONE)
    end
    else begin
      `uvm_fatal(get_name(), "randomization failed !!")
    end
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    foreach (configuration.axi_cfg[i]) begin
      if (i < 3) begin
        master_agents[i] = tvip_axi_master_agent::type_id::create($sformatf("master_agent[%0d]", i), this);
        master_agents[i].set_configuration(configuration.axi_cfg[i]);
      end
    end

    foreach (configuration.axi_cfg[j]) begin
      if (j >= 3 && j < 7) begin
        slave_agents[j-3] = tvip_axi_slave_agent::type_id::create($sformatf("slave_agent[%0d]", j-3), this);
        slave_agents[j-3].set_configuration(configuration.axi_cfg[j]);
      end
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    foreach (master_agents[i]) begin
      master_sequencers[i] = master_agents[i].sequencer;
    end
    foreach (slave_agents[j]) begin
      slave_sequencers[j]  = slave_agents[j].sequencer;
    end
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    foreach (master_sequencers[i]) begin
      uvm_config_db #(uvm_object_wrapper)::set(
        master_sequencers[i], "main_phase", "default_sequence", tvip_axi_sample_write_read_sequence::type_id::get()
      );
    end
    foreach (slave_sequencers[j]) begin
      uvm_config_db #(uvm_object_wrapper)::set(
        slave_sequencers[j], "run_phase", "default_sequence", tvip_axi_slave_default_sequence::type_id::get()
      );
    end
  endfunction

  `uvm_component_utils(tvip_axi_sample_test)
endclass
`endif
