module top();
  timeunit 1ns;
  timeprecision 1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tvip_axi_types_pkg::*;
  import  tvip_axi_pkg::*;
  import  tvip_axi_sample_pkg::*;

  bit aclk  = 0;
  initial begin
    forever begin
      #(0.5ns);
      aclk  ^= 1'b1;
    end
  end

  bit areset_n  = 0;
  initial begin
    repeat (20) @(posedge aclk);
    areset_n  = 1;
  end

  tvip_axi_if axi_if[7](aclk, areset_n);

  /* Original delay module commented out
  generate
    for (genvar i = 0; i < 3; i++) begin : master
      for (genvar j = 0; j < 4; j++) begin : slave
        tvip_axi_sample_delay #(
          .WRITE_ADDRESS_DELAY  (8),
          .WRITE_DATA_DELAY     (8),
          .WRITE_RESPONSE_DELAY (8),
          .READ_ADDRESS_DELAY   (8),
          .READ_RESPONSE_DELAY  (8)
        ) u_delay_${i}_${j} (
          aclk, areset_n, axi_if[i], axi_if[3 + j]
        );
      end
    end
  endgenerate
  */

  // New safety connector instantiation
  axi4_safety_connector_wrap u_connector (
    .aclk     (aclk),
    .areset_n (areset_n),
    .s0_axi   (axi_if[0]),
    .s1_axi   (axi_if[1]),
    .s2_axi   (axi_if[2]),
    .m0_axi   (axi_if[3]),
    .m1_axi   (axi_if[4]),
    .m2_axi   (axi_if[5]),
    .m3_axi   (axi_if[6])
  );

  initial begin
    uvm_config_db #(tvip_axi_vif)::set(null, "", "vif[0]", axi_if[0]);
    uvm_config_db #(tvip_axi_vif)::set(null, "", "vif[1]", axi_if[1]);
    uvm_config_db #(tvip_axi_vif)::set(null, "", "vif[2]", axi_if[2]);
    uvm_config_db #(tvip_axi_vif)::set(null, "", "vif[3]", axi_if[3]);
    uvm_config_db #(tvip_axi_vif)::set(null, "", "vif[4]", axi_if[4]);
    uvm_config_db #(tvip_axi_vif)::set(null, "", "vif[5]", axi_if[5]);
    uvm_config_db #(tvip_axi_vif)::set(null, "", "vif[6]", axi_if[6]);
    run_test("tvip_axi_sample_test");
  end
endmodule
