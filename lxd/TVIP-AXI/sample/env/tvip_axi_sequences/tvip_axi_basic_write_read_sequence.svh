`ifndef TVIP_AXI_BASIC_WRITE_READ_SEQUENCE_SVH
`define TVIP_AXI_BASIC_WRITE_READ_SEQUENCE_SVH

class tvip_axi_basic_write_read_sequence extends tvip_axi_base_sequence;
  function new(string name = "tvip_axi_basic_write_read_sequence");
    super.new(name);
  endfunction

  task body();
    do_basic_write_read_access();
  endtask

  task do_basic_write_read_access();
    tvip_axi_master_item  write_items[$];
    tvip_axi_master_item  read_items[$];

    for (int i = 0;i < 20;++i) begin
      tvip_axi_master_item  write_item;
      // int slave_idx = i % num_slaves;
      int slave_idx = 1;
      `tue_do_with(write_item, {
        access_type == TVIP_AXI_WRITE_ACCESS;
        address >= get_slave_base_addr(slave_idx);
        address <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        (address + burst_size * burst_length) <= (get_slave_base_addr(slave_idx) + addr_region_size - 1);
        address % (1 << burst_size) == 0; // 2^burst_size
      })
      write_items.push_back(write_item);
      `uvm_info("[WRITE_ITEM PUSH BACK]", $sformatf("%0h,%0d", write_item.address, write_item.id), UVM_LOW)
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
      `uvm_info("[REPONSE_ITEM BACK]", $sformatf("%0h", response_item.address), UVM_LOW)

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

  `uvm_object_utils(tvip_axi_basic_write_read_sequence)
endclass

`endif 