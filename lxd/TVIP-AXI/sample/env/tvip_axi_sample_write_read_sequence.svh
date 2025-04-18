`ifndef TVIP_AXI_SAMPLE_WRITE_READ_SEQUENCE_SVH
`define TVIP_AXI_SAMPLE_WRITE_READ_SEQUENCE_SVH

class tvip_axi_sample_write_read_sequence extends tvip_axi_master_sequence_base;
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

  function new(string name = "tvip_axi_sample_write_read_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  task body();
    do_basic_write_read_access();

    // for (int i = 0;i < 1;++i) begin
    //   fork
    //     automatic int ii  = i;
    //     do_write_read_access_by_sequence(ii);
    //   join_none
    // end
    // wait fork;

    // for (int i = 0;i < 1;++i) begin
    //   fork
    //     automatic int ii  = i;
    //     do_write_read_access_by_item(ii);
    //   join_none
    // end
    // wait fork;
  endtask

  task do_basic_write_read_access();
    tvip_axi_master_item  write_items[$];
    tvip_axi_master_item  read_items[$];

    for (int i = 0;i < 1;++i) begin
      tvip_axi_master_item  write_item;
      int slave_idx = i % num_slaves;
      `tue_do_with(write_item, {
        access_type == TVIP_AXI_WRITE_ACCESS;
        address >= get_slave_base_addr(slave_idx);
        address <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        (address + burst_size * burst_length) <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        address % (1 << burst_size) == 0; // 2^burst_size
      })
      write_items.push_back(write_item);
      `uvm_info("[WRITE_ITEM PUSH BACK]", $sformatf("%0h", write_item.address), UVM_LOW)
    end
    write_items[$].wait_for_done();

    foreach (write_items[i]) begin
      tvip_axi_master_item  read_item;
      `tue_do_with(read_item, {
        access_type  == TVIP_AXI_READ_ACCESS;
        address      == write_items[i].address;
        burst_size   == write_items[i].burst_size;
        burst_length == write_items[i].burst_length;
      })
      read_items.push_back(read_item);
      `uvm_info("[READ_ITEM PUSH BACK]", $sformatf("%0h", read_item.address), UVM_LOW)
    end

    foreach (write_items[i]) begin
      tvip_axi_item write_item;
      tvip_axi_item read_item;
      tvip_axi_item response_item;

      write_item  = write_items[i];
      read_item   = read_items[i];
      wait_for_response(read_item, response_item);
      `uvm_info("[REPONSE_ITEM BACK]", $sformatf("%0h", read_item.address), UVM_LOW)

      for (int j = 0;j < write_item.burst_length;++j) begin
        if (!compare_data(
          j,
          write_item.address, write_item.burst_size,
          write_item.strobe, write_item.data,
          response_item.data
        )) begin
          `uvm_error("CMPDATA", "write and read data are mismatched !!")
        end
      end
    end
  endtask

  task do_write_read_access_by_sequence(int index);
    tvip_axi_master_write_sequence  write_sequence;
    tvip_axi_master_read_sequence   read_sequence;
    int slave_idx = index % num_slaves;

    `tue_do_with(write_sequence, {
      address >= get_slave_base_addr(slave_idx);
      address <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
      (address + burst_size * burst_length) <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
      address % (1 << burst_size) == 0; // 2^burst_size
    })
    `tue_do_with(read_sequence, {
      address      == write_sequence.address;
      burst_size   == write_sequence.burst_size;
      burst_length >= write_sequence.burst_length;
    })

    for (int i = 0;i < write_sequence.burst_length;++i) begin
      if (!compare_data(
        i,
        write_sequence.address, write_sequence.burst_size,
        write_sequence.strobe, write_sequence.data,
        read_sequence.data
      )) begin
        `uvm_error("CMPDATA", "write and read data are mismatched !!")
      end
    end
  endtask

  task do_write_read_access_by_item(int index);
    tvip_axi_master_item  write_item;
    tvip_axi_item         write_response;
    tvip_axi_master_item  read_item;
    tvip_axi_item         read_response;
    int slave_idx = index % num_slaves;

    `tue_do_with(write_item, {
      need_response == (index < 10);
      access_type   == TVIP_AXI_WRITE_ACCESS;
      address       >= get_slave_base_addr(slave_idx);
      address       <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
      (address + burst_size * burst_length) <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
      address % (1 << burst_size) == 0; // 2^burst_size
    })
    wait_for_response(write_item, write_response);

    `tue_do_with(read_item, {
      need_response == write_item.need_response;
      access_type   == TVIP_AXI_READ_ACCESS;
      address       == write_item.address;
      burst_size    == write_item.burst_size;
      burst_length  == write_item.burst_length;
    })
    wait_for_response(read_item, read_response);

    for (int i = 0;i < write_response.burst_length;++i) begin
      if (!compare_data(
        i,
        write_response.address, write_response.burst_size,
        write_response.strobe, write_response.data,
        read_response.data
      )) begin
        `uvm_error("CMPDATA", "write and read data are mismatched !!")
      end
    end
  endtask

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
        return 0;
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

  `uvm_object_utils(tvip_axi_sample_write_read_sequence)
endclass

`endif
