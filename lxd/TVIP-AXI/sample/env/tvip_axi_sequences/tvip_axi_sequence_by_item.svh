`ifndef TVIP_AXI_SEQUENCE_BY_ITEM_SVH
`define TVIP_AXI_SEQUENCE_BY_ITEM_SVH

class tvip_axi_sequence_by_item extends tvip_axi_base_sequence;
  function new(string name = "tvip_axi_sequence_by_item");
    super.new(name);
  endfunction

  task body();
    for (int i = 0;i < 20;++i) begin
      fork
        automatic int ii = i;
        do_write_read_access_by_item(ii);
      join_none
    end
    wait fork;
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

  `uvm_object_utils(tvip_axi_sequence_by_item)
endclass

`endif 