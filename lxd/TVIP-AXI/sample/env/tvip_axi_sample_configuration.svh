`ifndef TVIP_AXI_SAMPLE_CONFIGURATION_SVH
`define TVIP_AXI_SAMPLE_CONFIGURATION_SVH

class tvip_axi_sample_configuration extends tue_configuration;
  bit                     enable_request_start_delay;
  bit                     enable_write_data_delay;
  bit                     enable_response_start_delay;
  bit                     enable_response_delay;
  bit                     enable_ready_delay;
  bit                     enable_out_of_order_response;
  bit                     enable_read_interleave;
  rand  tvip_axi_configuration  axi_cfg[7];  // Changed from [2] to [7] for 3 masters and 4 slaves

  constraint c_axi_basic {
    foreach (axi_cfg[i]) {
      axi_cfg[i].id_width         == 8;
      axi_cfg[i].address_width    == 64;
      axi_cfg[i].max_burst_length == 256;
      axi_cfg[i].data_width       == 64;
      axi_cfg[i].qos_range[0]     != -1;
      axi_cfg[i].qos_range[1]     != -1;
    }
  }

  constraint c_request_start_delay {
    if (enable_request_start_delay) {
      foreach (axi_cfg[i]) {
        if (i < 3) begin  // Only for master interfaces
          axi_cfg[i].request_start_delay.min_delay          == 0;
          axi_cfg[i].request_start_delay.max_delay          == 10;
          axi_cfg[i].request_start_delay.weight_zero_delay  == 6;
          axi_cfg[i].request_start_delay.weight_short_delay == 3;
          axi_cfg[i].request_start_delay.weight_long_delay  == 1;
        end
      }
    }
  }

  constraint c_write_data_delay {
    if (enable_write_data_delay) {
      foreach (axi_cfg[i]) {
        if (i < 3) begin  // Only for master interfaces
          axi_cfg[i].write_data_delay.min_delay          == 0;
          axi_cfg[i].write_data_delay.max_delay          == 10;
          axi_cfg[i].write_data_delay.weight_zero_delay  == 6;
          axi_cfg[i].write_data_delay.weight_short_delay == 3;
          axi_cfg[i].write_data_delay.weight_long_delay  == 1;
        end
      }
    }
  }

  constraint c_response_weight {
    foreach (axi_cfg[i]) {
      if (i >= 3) begin  // Only for slave interfaces
        axi_cfg[i].response_weight_okay         == 6;
        axi_cfg[i].response_weight_exokay       == 2;
        axi_cfg[i].response_weight_slave_error  == 1;
        axi_cfg[i].response_weight_decode_error == 1;
      end
    }
  }

  constraint c_response_start_delay {
    if (enable_response_start_delay) {
      foreach (axi_cfg[i]) {
        if (i >= 3) begin  // Only for slave interfaces
          axi_cfg[i].response_start_delay.min_delay          == 0;
          axi_cfg[i].response_start_delay.max_delay          == 10;
          axi_cfg[i].response_start_delay.weight_zero_delay  == 6;
          axi_cfg[i].response_start_delay.weight_short_delay == 3;
          axi_cfg[i].response_start_delay.weight_long_delay  == 1;
        end
      }
    }
  }

  constraint c_response_delay {
    if (enable_response_delay) {
      foreach (axi_cfg[i]) {
        if (i >= 3) begin  // Only for slave interfaces
          axi_cfg[i].response_delay.min_delay          == 0;
          axi_cfg[i].response_delay.max_delay          == 10;
          axi_cfg[i].response_delay.weight_zero_delay  == 6;
          axi_cfg[i].response_delay.weight_short_delay == 3;
          axi_cfg[i].response_delay.weight_long_delay  == 1;
        end
      }
    }
  }

  constraint c_ready_delay {
    if (enable_ready_delay) {
      foreach (axi_cfg[i]) {
        if (i < 3) begin  // Master interfaces
          axi_cfg[i].bready_delay.min_delay          == 0;
          axi_cfg[i].bready_delay.max_delay          == 10;
          axi_cfg[i].bready_delay.weight_zero_delay  == 6;
          axi_cfg[i].bready_delay.weight_short_delay == 3;
          axi_cfg[i].bready_delay.weight_long_delay  == 1;

          axi_cfg[i].rready_delay.min_delay          == 0;
          axi_cfg[i].rready_delay.max_delay          == 10;
          axi_cfg[i].rready_delay.weight_zero_delay  == 6;
          axi_cfg[i].rready_delay.weight_short_delay == 3;
          axi_cfg[i].rready_delay.weight_long_delay  == 1;
        end
        else begin  // Slave interfaces
          axi_cfg[i].awready_delay.min_delay          == 0;
          axi_cfg[i].awready_delay.max_delay          == 10;
          axi_cfg[i].awready_delay.weight_zero_delay  == 6;
          axi_cfg[i].awready_delay.weight_short_delay == 3;
          axi_cfg[i].awready_delay.weight_long_delay  == 1;

          axi_cfg[i].wready_delay.min_delay          == 0;
          axi_cfg[i].wready_delay.max_delay          == 10;
          axi_cfg[i].wready_delay.weight_zero_delay  == 6;
          axi_cfg[i].wready_delay.weight_short_delay == 3;
          axi_cfg[i].wready_delay.weight_long_delay  == 1;

          axi_cfg[i].arready_delay.min_delay          == 0;
          axi_cfg[i].arready_delay.max_delay          == 10;
          axi_cfg[i].arready_delay.weight_zero_delay  == 6;
          axi_cfg[i].arready_delay.weight_short_delay == 3;
          axi_cfg[i].arready_delay.weight_long_delay  == 1;
        end
      }
    }
  }

  constraint c_response_ordering {
    if (enable_out_of_order_response || enable_read_interleave) {
      foreach (axi_cfg[i]) {
        if (i >= 3) begin  // Only for slave interfaces
          axi_cfg[i].response_ordering == TVIP_AXI_OUT_OF_ORDER;
          axi_cfg[i].outstanding_responses inside {[2:5]};
        end
      }
    }
    else begin
      foreach (axi_cfg[i]) {
        if (i >= 3) begin  // Only for slave interfaces
          axi_cfg[i].response_ordering == TVIP_AXI_IN_ORDER;
        end
      }
    }
  }

  constraint c_read_interleave {
    if (enable_read_interleave) {
      foreach (axi_cfg[i]) {
        if (i >= 3) begin  // Only for slave interfaces
          axi_cfg[i].enable_response_interleaving == 1;
        end
      }
    }
    else begin
      foreach (axi_cfg[i]) {
        if (i >= 3) begin  // Only for slave interfaces
          axi_cfg[i].enable_response_interleaving == 0;
        end
      }
    }
  }

  function new(string name = "tvip_axi_sample_configuration");
    super.new(name);
    foreach (axi_cfg[i]) begin
      axi_cfg[i] = tvip_axi_configuration::type_id::create($sformatf("axi_cfg[%0d]", i));
    end
  endfunction

  function void pre_randomize();
    uvm_cmdline_processor clp;
    string                values[$];
    clp = uvm_cmdline_processor::get_inst();
    if (clp.get_arg_matches("+ENABLE_REQUEST_START_DELAY", values)) begin
      enable_request_start_delay  = 1;
    end
    if (clp.get_arg_matches("+ENABLE_WRITE_DATA_DELAY", values)) begin
      enable_write_data_delay = 1;
    end
    if (clp.get_arg_matches("+ENABLE_RESPONSE_START_DELAY", values)) begin
      enable_response_start_delay = 1;
    end
    if (clp.get_arg_matches("+ENABLE_RESPONSE_DELAY", values)) begin
      enable_response_delay = 1;
    end
    if (clp.get_arg_matches("+ENABLE_READY_DELAY", values)) begin
      enable_ready_delay  = 1;
    end
    if (clp.get_arg_matches("+ENABLE_OUT_OF_ORDER_RESPONSE", values)) begin
      enable_out_of_order_response  = 1;
    end
    if (clp.get_arg_matches("+ENABLE_READ_INTERLEAVE", values)) begin
      enable_read_interleave  = 1;
    end
  endfunction

  `uvm_object_utils_begin(tvip_axi_sample_configuration)
    `uvm_field_int(enable_write_data_delay, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(enable_response_start_delay, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(enable_response_delay, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(enable_ready_delay, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(enable_out_of_order_response, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(enable_read_interleave, UVM_DEFAULT | UVM_BIN)
    `uvm_field_sarray_object(axi_cfg, UVM_DEFAULT)
  `uvm_object_utils_end
endclass

`endif
