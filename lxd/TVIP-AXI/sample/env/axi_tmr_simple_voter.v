`timescale 1ns / 1ps

module axi_tmr_simple_voter #(
    parameter   WIDTH  = 1
)
(
    input [WIDTH - 1 : 0] d0,
    input [WIDTH - 1 : 0] d1,
    input [WIDTH - 1 : 0] d2,
    output [WIDTH - 1 : 0] q
);

    assign q = (d0 == d1) ? d0 : (d0 == d2) ? d0 : d1;
endmodule
