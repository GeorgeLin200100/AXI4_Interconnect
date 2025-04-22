`ifndef TVIP_AXI_SEQUENCE_LAUNCHER_SVH
`define TVIP_AXI_SEQUENCE_LAUNCHER_SVH

typedef enum {
  BASIC_WRITE_READ,
  SEQUENCE_BY_SEQUENCE,
  SEQUENCE_BY_ITEM,
  ALL_SEQUENCES
} tvip_axi_sequence_type_e;

class tvip_axi_sequence_launcher extends tvip_axi_base_sequence;
  tvip_axi_sequence_type_e sequence_type = BASIC_WRITE_READ;

  function new(string name = "tvip_axi_sequence_launcher");
    super.new(name);
  endfunction

  task body();
    case (sequence_type)
      BASIC_WRITE_READ: begin
        tvip_axi_basic_write_read_sequence seq;
        seq = tvip_axi_basic_write_read_sequence::type_id::create("basic_seq");
        seq.start(m_sequencer);
      end
      SEQUENCE_BY_SEQUENCE: begin
        tvip_axi_sequence_by_sequence seq;
        seq = tvip_axi_sequence_by_sequence::type_id::create("seq_by_seq");
        seq.start(m_sequencer);
      end
      SEQUENCE_BY_ITEM: begin
        tvip_axi_sequence_by_item seq;
        seq = tvip_axi_sequence_by_item::type_id::create("seq_by_item");
        seq.start(m_sequencer);
      end
      ALL_SEQUENCES: begin
        tvip_axi_basic_write_read_sequence basic_seq;
        tvip_axi_sequence_by_sequence seq_by_seq;
        tvip_axi_sequence_by_item seq_by_item;

        basic_seq = tvip_axi_basic_write_read_sequence::type_id::create("basic_seq");
        seq_by_seq = tvip_axi_sequence_by_sequence::type_id::create("seq_by_seq");
        seq_by_item = tvip_axi_sequence_by_item::type_id::create("seq_by_item");

        basic_seq.start(m_sequencer);
        seq_by_seq.start(m_sequencer);
        seq_by_item.start(m_sequencer);
      end
    endcase
  endtask

  `uvm_object_utils_begin(tvip_axi_sequence_launcher)
    `uvm_field_enum(tvip_axi_sequence_type_e, sequence_type, UVM_DEFAULT)
  `uvm_object_utils_end
endclass

`endif 