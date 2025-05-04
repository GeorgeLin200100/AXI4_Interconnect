`ifndef TVIP_AXI_BASE_SEQUENCE_SVH
`define TVIP_AXI_BASE_SEQUENCE_SVH

class tvip_axi_base_sequence extends tvip_axi_master_sequence_base;
  int unsigned  num_masters = 3;
  int unsigned  num_slaves = 4;
  int unsigned  addr_region_size = `SLAVE_ADDR_REGION_SIZE;
  tvip_axi_address  slave_base_addr[4] = '{
    `SLAVE_0_BASE_ADDR,  // Slave 0
    `SLAVE_1_BASE_ADDR,  // Slave 1
    `SLAVE_2_BASE_ADDR,  // Slave 2
    `SLAVE_3_BASE_ADDR   // Slave 3
  };
  tvip_axi_address  address_mask[int];

  function new(string name = "tvip_axi_base_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  // Common utility functions
  task wait_for_response(
    input   tvip_axi_item request,
    output  tvip_axi_item response
  );
    if (request.need_response) begin
      int id  = request.get_transaction_id();
      get_response(response, id);
    end
    else begin
      request.wait_for_done();
      response  = request;
    end
  endtask

  function bit compare_data(
    input int               index,
    input tvip_axi_address  address,
    input int               burst_size,
    ref   tvip_axi_strobe   strobe[],
    ref   tvip_axi_data     write_data[],
    ref   tvip_axi_data     read_data[]
  );
    int byte_width;
    int byte_offset;

    byte_width  = configuration.data_width / 8;
    byte_offset = ((address & get_address_mask(burst_size)) + (burst_size * index)) % byte_width;
    for (int i = 0;i < burst_size;++i) begin
      int   byte_index  = byte_offset + i;
      byte  write_byte;
      byte  read_byte;

      if (!strobe[index][byte_index]) begin
        continue;
      end

      write_byte  = write_data[index][8*byte_index+:8];
      read_byte   = read_data[index][8*byte_index+:8];
      if (write_byte != read_byte) begin
          `uvm_info("[MISMATCHED DATA]", $sformatf("write_data:%0h, read_data:%0h",write_data[index], read_data[index]), UVM_LOW)
        return 0;
      end else begin
          `uvm_info("MATCHED DATA",$sformatf("write_data:%0h, read_data:%0h",write_data[index], read_data[index]), UVM_LOW)
      end
    end

    return 1;
  endfunction

  function tvip_axi_address get_slave_base_addr(int slave_idx);
    return slave_base_addr[slave_idx];
  endfunction

  function tvip_axi_address get_address_mask(int burst_size);
    if (!address_mask.exists(burst_size)) begin
      tvip_axi_address  mask;
      mask                      = '1;
      mask                      = (mask >> $clog2(burst_size)) << $clog2(burst_size);
      address_mask[burst_size]  = mask;
    end
    return address_mask[burst_size];
  endfunction

  `uvm_object_utils(tvip_axi_base_sequence)
endclass

`endif 