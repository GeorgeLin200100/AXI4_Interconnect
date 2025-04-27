
`timescale 1ns/1ns

module ecc_test;

    reg                 [63:0]  data_in;
    wire [6:0]  parity_out;
  
    reg                [63:0]  data_read;
    reg [6:0]  parity_read;
    wire error_flag;
    wire [6:0] is_parity_diff;
    wire [63:0] data_corrected;
    wire [6:0] parity_corrected;
    
    reg [63:0] data_fault_temp;
    reg [6:0] parity_fault_temp;

    ecc_d64b_p7_enc u_ecc_d64b_p7_enc(
        .data_in(data_in),
        .parity_out(parity_out)
    );

    ecc_d64b_p7_dec u_ecc_d64b_p7_dec(
        .data_in( data_read),
        .parity_in( parity_read),
        .error_flag( error_flag), 
        .is_parity_diff(is_parity_diff ),
        .ecc_corrected( ), 
        .data_corrected(data_corrected ), 
        .parity_corrected(parity_corrected)
    );

  initial  begin
    data_in = 0;
    data_read = 0;
    #10
    parity_read =0;
    #100;

    data_in = $urandom(123);
    data_read = data_in;
    #10
    parity_read =parity_out;
    #100;

    data_fault_temp = 1 << $urandom_range(0, 63);
    $display("data_fault_temp = %b", data_fault_temp);
    data_read = data_read ^ data_fault_temp;
    #10
    parity_read =parity_out;
    #100;

    data_in = $urandom(357);
    data_read = data_in;
    parity_fault_temp = (1 << $urandom_range(0, 6));
    $display("parity_fault_temp = %b", parity_fault_temp);
    #10
    parity_read =parity_out ^ parity_fault_temp;
    #100;

    $stop;

  end

  initial begin
      $dumpfile("fifo.vcd");
      $dumpvars(0, test);
  end


endmodule
