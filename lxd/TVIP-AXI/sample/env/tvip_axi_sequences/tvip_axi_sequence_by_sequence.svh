`ifndef TVIP_AXI_SEQUENCE_BY_SEQUENCE_SVH
`define TVIP_AXI_SEQUENCE_BY_SEQUENCE_SVH

class tvip_axi_sequence_by_sequence extends tvip_axi_base_sequence;
  function new(string name = "tvip_axi_sequence_by_sequence");
    super.new(name);
  endfunction

  task body();
    for (int i = 0;i < 20;++i) begin
      fork
        automatic int ii = i;
        do_write_read_access_by_sequence(ii);
      join_none
    end
    wait fork;
  endtask

  task do_write_read_access_by_sequence(int index);
    tvip_axi_master_write_sequence  write_sequence;
    tvip_axi_master_read_sequence   read_sequence;
    //int slave_idx = index % num_slaves;
    int slave_idx = 1;

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

  `uvm_object_utils(tvip_axi_sequence_by_sequence)
endclass

`endif 