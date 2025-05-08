`ifndef TVIP_AXI_MASTER_OUTSTANDING_ACCESS_SEQUENCE_SVH
`define TVIP_AXI_MASTER_OUTSTANDING_ACCESS_SEQUENCE_SVH
class tvip_axi_master_outstanding_access_sequence extends tvip_axi_master_access_sequence;
  semaphore outstanding_lock;
  tvip_axi_master_item requests[10];
  tvip_axi_master_item responses[int];
  int ids[10];
  rand tvip_axi_address addr_new[10];
  rand      tvip_axi_data         data_new[][];
  rand tvip_axi_id id_new[10];

  constraint c_valid_data_new {
    solve access_type  before data_new;
    solve burst_length before data_new;
    data_new.size() == 10;
    foreach(data_new[j]) {
      (access_type == TVIP_AXI_WRITE_ACCESS) -> data_new[j].size() == burst_length;
      (access_type == TVIP_AXI_READ_ACCESS ) -> data_new[j].size() == 0;
      foreach (data_new[j][i]) {
        (data_new[j][i] >> this.configuration.data_width) == 0;
      }
    }
  }

  function new(string name = "tvip_axi_master_outstanding_access_sequence");
    super.new(name);
    //outstanding_lock = new(10);
  endfunction

  virtual task body();
    // `uvm_info("[OUSTANDING DEBUG]","enter child body", UVM_LOW)
    // transmit_request();
    // `uvm_info("[OUSTANDING DEBUG]","child request item sent", UVM_LOW)
    //wait_for_response();
  //`uvm_info("[OUSTANDING DEBUG]","child response item back", UVM_LOW)
    
    for (int i = 0; i < 10; i++) begin
      //fork
        automatic int ii = i;
        //outstanding_lock.get();
        requests[ii] = tvip_axi_master_item::type_id::create($sformatf("requests[%0d]",ii));
        start_item(requests[ii]);
        // if(!requests[ii].randomize()) begin
        //   `uvm_fatal("BODY", "Randomize failed")
        // end
        copy_outstanding_request_info(ii);
        finish_item(requests[ii]);
        //`uvm_send(requests[ii])
        ids[ii]=requests[ii].get_transaction_id();
        `uvm_info("OUTSTANDING",$sformatf("Sent request ID %0d", ids[ii]), UVM_LOW)
        //outstanding_lock.put();
      //join_none
    end
    //wait fork;

    
    for (int i = 0; i < 10; i++) begin
      fork
        automatic int ii = i;
        automatic int id;
        automatic tvip_axi_master_item rsp;
        automatic int id  = requests[ii].get_transaction_id();
        //get_response(rsp);
        get_response(rsp, id);
        //id = rsp.get_transaction_id();
        responses[id] = rsp;
        `uvm_info("RESPONSE",$sformatf("Received response for ID %0d", id), UVM_LOW)
      join
    end
  endtask

    //local function void copy_outstanding_request_info();
  function void copy_outstanding_request_info(int i);
    requests[i].access_type          = access_type;
    //requests[i].id                   = id;
    requests[i].id                   = id_new[i];
    //requests[i].address              = address;
    requests[i].address              = addr_new[i];
    `uvm_info("[ADDRESS_DEBUG]", $sformatf("requests[%0d].address=%0h, addr_new[%0d]=%0h",i, requests[i].address, i, addr_new[i]), UVM_LOW)
    requests[i].burst_length         = burst_length;
    requests[i].burst_size           = burst_size;
    requests[i].burst_type           = burst_type;
    requests[i].memory_type          = memory_type;
    requests[i].protection           = protection;
    requests[i].qos                  = qos;
    requests[i].start_delay          = start_delay;
    requests[i].response_ready_delay = new[response_ready_delay.size()](response_ready_delay);
    requests[i].need_response        = 1;
    if (requests[i].is_write()) begin
      requests[i].data             = new[data_new[i].size()](data_new[i]);
      requests[i].strobe           = new[strobe.size()](strobe);
      requests[i].write_data_delay = new[write_data_delay.size()](write_data_delay);
    end
  endfunction

  // `uvm_object_utils_begin(tvip_axi_master_access_sequence)
  //   `uvm_field_enum(tvip_axi_access_type, access_type, UVM_DEFAULT)
  //   `uvm_field_int(id, UVM_DEFAULT | UVM_HEX)
  //   `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
  //   `uvm_field_int(burst_length, UVM_DEFAULT | UVM_DEC)
  //   `uvm_field_int(burst_size, UVM_DEFAULT | UVM_DEC)
  //   `uvm_field_enum(tvip_axi_burst_type, burst_type, UVM_DEFAULT)
  //   `uvm_field_enum(tvip_axi_memory_type, memory_type, UVM_DEFAULT | UVM_NOCOMPARE)
  //   `uvm_field_int(protection, UVM_DEFAULT | UVM_BIN)
  //   `uvm_field_int(qos, UVM_DEFAULT | UVM_DEC)
  //   `uvm_field_array_int(data, UVM_DEFAULT | UVM_HEX)
  //   `uvm_field_array_int(strobe, UVM_DEFAULT | UVM_HEX)
  //   `uvm_field_array_enum(tvip_axi_response, response, UVM_DEFAULT)
  //   `uvm_field_int(start_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  //   `uvm_field_array_int(write_data_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  //   `uvm_field_array_int(response_ready_delay, UVM_DEFAULT | UVM_DEC | UVM_NOCOMPARE)
  // `uvm_object_utils_end
  //`tue_object_default_constructor(tvip_axi_master_outstanding_access_sequence)
  `uvm_object_utils(tvip_axi_master_outstanding_access_sequence)
endclass
`endif
