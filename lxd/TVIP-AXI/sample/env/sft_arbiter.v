/*

Copyright (c) 2014-2021 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * Arbiter module
 */
module sft_arbiter #
(
    parameter PORTS = 4,
    // select round robin arbitration
    parameter ARB_TYPE_ROUND_ROBIN = 0,
    // blocking arbiter enable
    parameter ARB_BLOCK = 0,
    // block on acknowledge assert when nonzero, request deassert when 0
    parameter ARB_BLOCK_ACK = 1,
    // LSB priority selection
    parameter ARB_LSB_HIGH_PRIORITY = 0
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [PORTS-1:0]         request,
    input  wire [PORTS-1:0]         acknowledge,

    output wire [PORTS-1:0]         grant,
    output wire                     grant_valid,
    output wire [$clog2(PORTS)-1:0] grant_encoded
);

    wire [PORTS-1:0] request_tmr0;
    wire [PORTS-1:0] acknowledge_tmr0;
    wire [PORTS-1:0] grant_tmr0;
    wire grant_valid_tmr0;
    wire [$clog2(PORTS)-1:0] grant_encoded_tmr0;

    wire [PORTS-1:0] request_tmr1;
    wire [PORTS-1:0] acknowledge_tmr1;
    wire [PORTS-1:0] grant_tmr1;
    wire grant_valid_tmr1;
    wire [$clog2(PORTS)-1:0] grant_encoded_tmr1;

    wire [PORTS-1:0] request_tmr2;
    wire [PORTS-1:0] acknowledge_tmr2;
    wire [PORTS-1:0] grant_tmr2;
    wire grant_valid_tmr2;
    wire [$clog2(PORTS)-1:0] grant_encoded_tmr2;

    axi_tmr_simple_voter #(PORTS) axi_tmr_simple_voter_grant (.d0(grant_tmr0), .d1(grant_tmr1), .d2(grant_tmr2), .q(grant));
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_grant_valid (.d0(grant_valid_tmr0), .d1(grant_valid_tmr1), .d2(grant_valid_tmr2), .q(grant_valid));
    axi_tmr_simple_voter #($clog2(PORTS)) axi_tmr_simple_voter_grant_encoded (.d0(grant_encoded_tmr0), .d1(grant_encoded_tmr1), .d2(grant_encoded_tmr2), .q(grant_encoded));

    assign request_tmr0 = request;
    assign request_tmr1 = request;
    assign request_tmr2 = request;

    assign acknowledge_tmr0 = acknowledge;
    assign acknowledge_tmr1 = acknowledge;
    assign acknowledge_tmr2 = acknowledge;


    arbiter#(
        .PORTS                ( PORTS ),
        .ARB_TYPE_ROUND_ROBIN ( ARB_TYPE_ROUND_ROBIN ),
        .ARB_BLOCK            ( ARB_BLOCK ),
        .ARB_BLOCK_ACK        ( ARB_BLOCK_ACK ),
        .ARB_LSB_HIGH_PRIORITY ( ARB_LSB_HIGH_PRIORITY )
    )u_arbiter_tmr0(
        .clk                  ( clk ),
        .rst                  ( rst ),
        .request              ( request_tmr0 ),
        .acknowledge          ( acknowledge_tmr0 ),
        .grant                ( grant_tmr0 ),
        .grant_valid          ( grant_valid_tmr0 ),
        .grant_encoded        ( grant_encoded_tmr0 )
    );

    arbiter#(
        .PORTS                ( PORTS ),
        .ARB_TYPE_ROUND_ROBIN ( ARB_TYPE_ROUND_ROBIN ),
        .ARB_BLOCK            ( ARB_BLOCK ),
        .ARB_BLOCK_ACK        ( ARB_BLOCK_ACK ),
        .ARB_LSB_HIGH_PRIORITY ( ARB_LSB_HIGH_PRIORITY )
    )u_arbiter_tmr1(
        .clk                  ( clk ),
        .rst                  ( rst ),
        .request              ( request_tmr1 ),
        .acknowledge          ( acknowledge_tmr1 ),
        .grant                ( grant_tmr1 ),
        .grant_valid          ( grant_valid_tmr1 ),
        .grant_encoded        ( grant_encoded_tmr1 )
    );

    arbiter#(
        .PORTS                ( PORTS ),
        .ARB_TYPE_ROUND_ROBIN ( ARB_TYPE_ROUND_ROBIN ),
        .ARB_BLOCK            ( ARB_BLOCK ),
        .ARB_BLOCK_ACK        ( ARB_BLOCK_ACK ),
        .ARB_LSB_HIGH_PRIORITY ( ARB_LSB_HIGH_PRIORITY )
    )u_arbiter_tmr2(
        .clk                  ( clk ),
        .rst                  ( rst ),
        .request              ( request_tmr2 ),
        .acknowledge          ( acknowledge_tmr2 ),
        .grant                ( grant_tmr2 ),
        .grant_valid          ( grant_valid_tmr2 ),
        .grant_encoded        ( grant_encoded_tmr2 )
    );

endmodule

`resetall
