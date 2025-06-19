`ifndef TVIP_AXI_SAMPLE_TEST_SVH
`define TVIP_AXI_SAMPLE_TEST_SVH

class tvip_axi_sample_test extends tue_test #(
  .CONFIGURATION  (tvip_axi_sample_configuration)
);
  tvip_axi_master_agent     master_agents[3];
  tvip_axi_master_sequencer master_sequencers[3];
  tvip_axi_slave_agent      slave_agents[4];
  tvip_axi_slave_sequencer  slave_sequencers[4];
  tvip_axi_scoreboard       scoreboard;
  tvip_axi_sequence_launcher launcher;
  string seq_name;
  tvip_axi_sequence_type_e seq_type;
  fault_injector injector;
  // uvm_analysis_imp #(tvip_axi_item, tvip_axi_scoreboard) master_imp[3];
  // uvm_analysis_imp #(tvip_axi_item, tvip_axi_scoreboard) slave_imp[4];
  uvm_analysis_imp_m0 #(tvip_axi_item, tvip_axi_scoreboard) master_imp_m0;
  uvm_analysis_imp_m1 #(tvip_axi_item, tvip_axi_scoreboard) master_imp_m1;
  uvm_analysis_imp_m2 #(tvip_axi_item, tvip_axi_scoreboard) master_imp_m2;
  uvm_analysis_imp_s0 #(tvip_axi_item, tvip_axi_scoreboard) slave_imp_s0;
  uvm_analysis_imp_s1 #(tvip_axi_item, tvip_axi_scoreboard) slave_imp_s1;
  uvm_analysis_imp_s2 #(tvip_axi_item, tvip_axi_scoreboard) slave_imp_s2;
  uvm_analysis_imp_s3 #(tvip_axi_item, tvip_axi_scoreboard) slave_imp_s3;

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

    // Create scoreboard
    scoreboard = tvip_axi_scoreboard::type_id::create("scoreboard", this);

    // Create master agents
    foreach (configuration.axi_cfg[i]) begin
      if (i < 3) begin
        master_agents[i] = tvip_axi_master_agent::type_id::create($sformatf("master_agent[%0d]", i), this);
        master_agents[i].set_configuration(configuration.axi_cfg[i]);
      end
    end

    // Create slave agents
    foreach (configuration.axi_cfg[j]) begin
      if (j >= 3 && j < 7) begin
        slave_agents[j-3] = tvip_axi_slave_agent::type_id::create($sformatf("slave_agent[%0d]", j-3), this);
        slave_agents[j-3].set_configuration(configuration.axi_cfg[j]);
      end
    end

    // Create fault injector
    injector = fault_injector::type_id::create("injector", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect master agents to scoreboard
    foreach (master_agents[i]) begin
        master_sequencers[i] = master_agents[i].sequencer;
    //  master_agents[i].item_port.connect($sformatf("scoreboard.master_imp_m%0d", i));
    end

    foreach (master_agents[i]) begin
      case (i)
        0: master_agents[i].item_port.connect(scoreboard.master_imp_m0);
        1: master_agents[i].item_port.connect(scoreboard.master_imp_m1);
        2: master_agents[i].item_port.connect(scoreboard.master_imp_m2);
      endcase
    end

    // Connect slave agents to scoreboard
    foreach (slave_agents[j]) begin
      slave_sequencers[j] = slave_agents[j].sequencer;
      //slave_agents[j].item_port.connect($sformatf("scoreboard.slave_imp_s%0d", j));
    end

    foreach (slave_agents[i]) begin
      case (i)
        0: slave_agents[i].item_port.connect(scoreboard.slave_imp_s0);
        1: slave_agents[i].item_port.connect(scoreboard.slave_imp_s1);
        2: slave_agents[i].item_port.connect(scoreboard.slave_imp_s2);
        3: slave_agents[i].item_port.connect(scoreboard.slave_imp_s3);
      endcase
    end
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    
    // Create and configure the sequence launcher
    launcher = tvip_axi_sequence_launcher::type_id::create("launcher");

    if ($value$plusargs("SEQ=%s",seq_name)) begin
      if (seq_name == "BASIC_WRITE_READ") begin
      `uvm_info("[CATCH SEQ]", "BASIC_WRITE_READ", UVM_LOW)
        seq_type = BASIC_WRITE_READ;
      end else if (seq_name == "SEQUENCE_BY_SEQUENCE") begin
      `uvm_info("[CATCH SEQ]", "SEQUENCE_BY_SEQUENCE", UVM_LOW)
        seq_type = SEQUENCE_BY_SEQUENCE;
      end else if (seq_name == "SEQUENCE_BY_ITEM") begin
      `uvm_info("[CATCH SEQ]", "SEQUENCE_BY_ITEM", UVM_LOW)
        seq_type = SEQUENCE_BY_ITEM;
      end else if (seq_name == "OUTSTANDING_WRITE") begin
      `uvm_info("[CATCH SEQ]", "OUTSTANDING_WRITE", UVM_LOW)
        seq_type = OUTSTANDING_WRITE;
      end else if (seq_name == "ALL_SEQUENCES") begin
        seq_type = ALL_SEQUENCES;
      end else begin
        `uvm_error("[ARG_MISS]","seq arg not passed!")
      end
      `uvm_info("[SEQ_TYPE]",$sformatf("SEQ = %s",seq_name),UVM_LOW)
    end else begin
      `uvm_info("[CATCH SEQ]", "No catch!", UVM_LOW)
    end

    launcher.sequence_type = seq_type;
    `uvm_info("SEQ_DEBUG", $sformatf("Launcher sequence_type = %s", launcher.sequence_type.name()), UVM_LOW)
    
    // Set the sequence launcher as the default sequence for each master sequencer
    foreach (master_sequencers[i]) begin
      uvm_config_db #(tvip_axi_sequence_type_e)::set(
        master_sequencers[i], "", "sequence_type", seq_type
      );
      // Register the sequence launcher as the default sequence for the run phase
      if (i == 1) begin
        uvm_config_db #(uvm_object_wrapper)::set(
          master_sequencers[i], "run_phase", "default_sequence", launcher.get_type()
        );
      end
    end
    
    // Set default sequence for slave sequencers
    foreach (slave_sequencers[j]) begin
      //if (j == 1) begin
        uvm_config_db #(uvm_object_wrapper)::set(
          slave_sequencers[j], "run_phase", "default_sequence", tvip_axi_slave_default_sequence::type_id::get()
        );
      //end
    end
  endfunction

  //touched fault_injector
  /*
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase); // 调用父类的 run_phase（如果存在）
    // 启动故障注入组件的 run_phase
    injector.run_phase(phase);
  endtask
  */

  `uvm_component_utils(tvip_axi_sample_test)
endclass

`endif
