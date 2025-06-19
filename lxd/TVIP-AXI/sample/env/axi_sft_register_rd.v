/*

Copyright (c) 2018 Alex Forencich

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
 * AXI4 register (read)
 */
module axi_sft_register_rd #
(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Width of ID signal
    parameter ID_WIDTH = 8,
    // Propagate aruser signal
    parameter ARUSER_ENABLE = 0,
    // Width of aruser signal
    parameter ARUSER_WIDTH = 1,
    // Propagate ruser signal
    parameter RUSER_ENABLE = 0,
    // Width of ruser signal
    parameter RUSER_WIDTH = 1,
    // AR channel register type
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter AR_REG_TYPE = 1,
    // R channel register type
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter R_REG_TYPE = 2
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * AXI slave interface
     */
    input  wire [ID_WIDTH-1:0]      s_axi_arid,
    input  wire [ADDR_WIDTH-1:0]    s_axi_araddr,
    input  wire [7:0]               s_axi_arlen,
    input  wire [2:0]               s_axi_arsize,
    input  wire [1:0]               s_axi_arburst,
    input  wire                     s_axi_arlock,
    input  wire [3:0]               s_axi_arcache,
    input  wire [2:0]               s_axi_arprot,
    input  wire [3:0]               s_axi_arqos,
    input  wire [3:0]               s_axi_arregion,
    input  wire [ARUSER_WIDTH-1:0]  s_axi_aruser,
    input  wire                     s_axi_arvalid,
    output wire                     s_axi_arready,
    output wire [ID_WIDTH-1:0]      s_axi_rid,
    output wire [DATA_WIDTH-1:0]    s_axi_rdata,
    output wire [1:0]               s_axi_rresp,
    output wire                     s_axi_rlast,
    output wire [RUSER_WIDTH-1:0]   s_axi_ruser,
    output wire                     s_axi_rvalid,
    input  wire                     s_axi_rready,

    /*
     * AXI master interface
     */
    output wire [ID_WIDTH-1:0]      m_axi_arid,
    output wire [ADDR_WIDTH-1:0]    m_axi_araddr,
    output wire [7:0]               m_axi_arlen,
    output wire [2:0]               m_axi_arsize,
    output wire [1:0]               m_axi_arburst,
    output wire                     m_axi_arlock,
    output wire [3:0]               m_axi_arcache,
    output wire [2:0]               m_axi_arprot,
    output wire [3:0]               m_axi_arqos,
    output wire [3:0]               m_axi_arregion,
    output wire [ARUSER_WIDTH-1:0]  m_axi_aruser,
    output wire                     m_axi_arvalid,
    input  wire                     m_axi_arready,
    input  wire [ID_WIDTH-1:0]      m_axi_rid,
    input  wire [DATA_WIDTH-1:0]    m_axi_rdata,
    input  wire [1:0]               m_axi_rresp,
    input  wire                     m_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]   m_axi_ruser,
    input  wire                     m_axi_rvalid,
    output wire                     m_axi_rready
);

    wire [ID_WIDTH-1:0]      s_axi_arid_tmr0;
    wire [ADDR_WIDTH-1:0]    s_axi_araddr_tmr0;
    wire [7:0]               s_axi_arlen_tmr0;
    wire [2:0]               s_axi_arsize_tmr0;
    wire [1:0]               s_axi_arburst_tmr0;
    wire                     s_axi_arlock_tmr0;
    wire [3:0]               s_axi_arcache_tmr0;
    wire [2:0]               s_axi_arprot_tmr0;
    wire [3:0]               s_axi_arqos_tmr0;
    wire [3:0]               s_axi_arregion_tmr0;
    wire [ARUSER_WIDTH-1:0]  s_axi_aruser_tmr0;
    wire                     s_axi_arvalid_tmr0;
    wire                     s_axi_arready_tmr0;
    wire [ID_WIDTH-1:0]      s_axi_rid_tmr0;
    wire [DATA_WIDTH-1:0]    s_axi_rdata_tmr0;
    wire [1:0]               s_axi_rresp_tmr0;
    wire                     s_axi_rlast_tmr0;
    wire [RUSER_WIDTH-1:0]   s_axi_ruser_tmr0;
    wire                     s_axi_rvalid_tmr0;
    wire                     s_axi_rready_tmr0;

    wire [ID_WIDTH-1:0]      s_axi_arid_tmr1;
    wire [ADDR_WIDTH-1:0]    s_axi_araddr_tmr1;
    wire [7:0]               s_axi_arlen_tmr1;
    wire [2:0]               s_axi_arsize_tmr1;
    wire [1:0]               s_axi_arburst_tmr1;
    wire                     s_axi_arlock_tmr1;
    wire [3:0]               s_axi_arcache_tmr1;
    wire [2:0]               s_axi_arprot_tmr1;
    wire [3:0]               s_axi_arqos_tmr1;
    wire [3:0]               s_axi_arregion_tmr1;
    wire [ARUSER_WIDTH-1:0]  s_axi_aruser_tmr1;
    wire                     s_axi_arvalid_tmr1;
    wire                     s_axi_arready_tmr1;
    wire [ID_WIDTH-1:0]      s_axi_rid_tmr1;
    wire [DATA_WIDTH-1:0]    s_axi_rdata_tmr1;
    wire [1:0]               s_axi_rresp_tmr1;
    wire                     s_axi_rlast_tmr1;
    wire [RUSER_WIDTH-1:0]   s_axi_ruser_tmr1;
    wire                     s_axi_rvalid_tmr1;
    wire                     s_axi_rready_tmr1;

    wire [ID_WIDTH-1:0]      s_axi_arid_tmr2;
    wire [ADDR_WIDTH-1:0]    s_axi_araddr_tmr2;
    wire [7:0]               s_axi_arlen_tmr2;
    wire [2:0]               s_axi_arsize_tmr2;
    wire [1:0]               s_axi_arburst_tmr2;
    wire                     s_axi_arlock_tmr2;
    wire [3:0]               s_axi_arcache_tmr2;
    wire [2:0]               s_axi_arprot_tmr2;
    wire [3:0]               s_axi_arqos_tmr2;
    wire [3:0]               s_axi_arregion_tmr2;
    wire [ARUSER_WIDTH-1:0]  s_axi_aruser_tmr2;
    wire                     s_axi_arvalid_tmr2;
    wire                     s_axi_arready_tmr2;
    wire [ID_WIDTH-1:0]      s_axi_rid_tmr2;
    wire [DATA_WIDTH-1:0]    s_axi_rdata_tmr2;
    wire [1:0]               s_axi_rresp_tmr2;
    wire                     s_axi_rlast_tmr2;
    wire [RUSER_WIDTH-1:0]   s_axi_ruser_tmr2;
    wire                     s_axi_rvalid_tmr2;
    wire                     s_axi_rready_tmr2;

    wire [ID_WIDTH-1:0]      m_axi_arid_tmr0;
    wire [ADDR_WIDTH-1:0]    m_axi_araddr_tmr0;
    wire [7:0]               m_axi_arlen_tmr0;
    wire [2:0]               m_axi_arsize_tmr0;
    wire [1:0]               m_axi_arburst_tmr0;
    wire                     m_axi_arlock_tmr0;
    wire [3:0]               m_axi_arcache_tmr0;
    wire [2:0]               m_axi_arprot_tmr0;
    wire [3:0]               m_axi_arqos_tmr0;
    wire [3:0]               m_axi_arregion_tmr0;
    wire [ARUSER_WIDTH-1:0]  m_axi_aruser_tmr0;
    wire                     m_axi_arvalid_tmr0;
    wire                     m_axi_arready_tmr0;
    wire [ID_WIDTH-1:0]      m_axi_rid_tmr0;
    wire [DATA_WIDTH-1:0]    m_axi_rdata_tmr0;
    wire [1:0]               m_axi_rresp_tmr0;
    wire                     m_axi_rlast_tmr0;
    wire [RUSER_WIDTH-1:0]   m_axi_ruser_tmr0;
    wire                     m_axi_rvalid_tmr0;
    wire                     m_axi_rready_tmr0;

    wire [ID_WIDTH-1:0]      m_axi_arid_tmr1;
    wire [ADDR_WIDTH-1:0]    m_axi_araddr_tmr1;
    wire [7:0]               m_axi_arlen_tmr1;
    wire [2:0]               m_axi_arsize_tmr1;
    wire [1:0]               m_axi_arburst_tmr1;
    wire                     m_axi_arlock_tmr1;
    wire [3:0]               m_axi_arcache_tmr1;
    wire [2:0]               m_axi_arprot_tmr1;
    wire [3:0]               m_axi_arqos_tmr1;
    wire [3:0]               m_axi_arregion_tmr1;
    wire [ARUSER_WIDTH-1:0]  m_axi_aruser_tmr1;
    wire                     m_axi_arvalid_tmr1;
    wire                     m_axi_arready_tmr1;
    wire [ID_WIDTH-1:0]      m_axi_rid_tmr1;
    wire [DATA_WIDTH-1:0]    m_axi_rdata_tmr1;
    wire [1:0]               m_axi_rresp_tmr1;
    wire                     m_axi_rlast_tmr1;
    wire [RUSER_WIDTH-1:0]   m_axi_ruser_tmr1;
    wire                     m_axi_rvalid_tmr1;
    wire                     m_axi_rready_tmr1;

    wire [ID_WIDTH-1:0]      m_axi_arid_tmr2;
    wire [ADDR_WIDTH-1:0]    m_axi_araddr_tmr2;
    wire [7:0]               m_axi_arlen_tmr2;
    wire [2:0]               m_axi_arsize_tmr2;
    wire [1:0]               m_axi_arburst_tmr2;
    wire                     m_axi_arlock_tmr2;
    wire [3:0]               m_axi_arcache_tmr2;
    wire [2:0]               m_axi_arprot_tmr2;
    wire [3:0]               m_axi_arqos_tmr2;
    wire [3:0]               m_axi_arregion_tmr2;
    wire [ARUSER_WIDTH-1:0]  m_axi_aruser_tmr2;
    wire                     m_axi_arvalid_tmr2;
    wire                     m_axi_arready_tmr2;
    wire [ID_WIDTH-1:0]      m_axi_rid_tmr2;
    wire [DATA_WIDTH-1:0]    m_axi_rdata_tmr2;
    wire [1:0]               m_axi_rresp_tmr2;
    wire                     m_axi_rlast_tmr2;
    wire [RUSER_WIDTH-1:0]   m_axi_ruser_tmr2;
    wire                     m_axi_rvalid_tmr2;
    wire                     m_axi_rready_tmr2;

    assign s_axi_arid_tmr0 = s_axi_arid;
    assign s_axi_arid_tmr1 = s_axi_arid;
    assign s_axi_arid_tmr2 = s_axi_arid;
    assign s_axi_araddr_tmr0 = s_axi_araddr;
    assign s_axi_araddr_tmr1 = s_axi_araddr;
    assign s_axi_araddr_tmr2 = s_axi_araddr;
    assign s_axi_arlen_tmr0 = s_axi_arlen;
    assign s_axi_arlen_tmr1 = s_axi_arlen;
    assign s_axi_arlen_tmr2 = s_axi_arlen;
    assign s_axi_arsize_tmr0 = s_axi_arsize;
    assign s_axi_arsize_tmr1 = s_axi_arsize;
    assign s_axi_arsize_tmr2 = s_axi_arsize;
    assign s_axi_arburst_tmr0 = s_axi_arburst;
    assign s_axi_arburst_tmr1 = s_axi_arburst;
    assign s_axi_arburst_tmr2 = s_axi_arburst;
    assign s_axi_arlock_tmr0 = s_axi_arlock;
    assign s_axi_arlock_tmr1 = s_axi_arlock;
    assign s_axi_arlock_tmr2 = s_axi_arlock;
    assign s_axi_arcache_tmr0 = s_axi_arcache;
    assign s_axi_arcache_tmr1 = s_axi_arcache;
    assign s_axi_arcache_tmr2 = s_axi_arcache;
    assign s_axi_arprot_tmr0 = s_axi_arprot;
    assign s_axi_arprot_tmr1 = s_axi_arprot;
    assign s_axi_arprot_tmr2 = s_axi_arprot;
    assign s_axi_arqos_tmr0 = s_axi_arqos;
    assign s_axi_arqos_tmr1 = s_axi_arqos;
    assign s_axi_arqos_tmr2 = s_axi_arqos;
    assign s_axi_arregion_tmr0 = s_axi_arregion;
    assign s_axi_arregion_tmr1 = s_axi_arregion;
    assign s_axi_arregion_tmr2 = s_axi_arregion;
    assign s_axi_aruser_tmr0 = s_axi_aruser;
    assign s_axi_aruser_tmr1 = s_axi_aruser;
    assign s_axi_aruser_tmr2 = s_axi_aruser;
    assign s_axi_arvalid_tmr0 = s_axi_arvalid;
    assign s_axi_arvalid_tmr1 = s_axi_arvalid;
    assign s_axi_arvalid_tmr2 = s_axi_arvalid;
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_s_axi_arready (.d0(s_axi_arready_tmr0),.d1(s_axi_arready_tmr1),.d2(s_axi_arready_tmr2),.q(s_axi_arready));

    axi_tmr_simple_voter #(ID_WIDTH) axi_tmr_simple_voter_s_axi_rid (.d0(s_axi_rid_tmr0),.d1(s_axi_rid_tmr1),.d2(s_axi_rid_tmr2),.q(s_axi_rid));
    axi_tmr_simple_voter #(DATA_WIDTH) axi_tmr_simple_voter_s_axi_rdata (.d0(s_axi_rdata_tmr0),.d1(s_axi_rdata_tmr1),.d2(s_axi_rdata_tmr2),.q(s_axi_rdata));
    axi_tmr_simple_voter #(2) axi_tmr_simple_voter_s_axi_rresp (.d0(s_axi_rresp_tmr0),.d1(s_axi_rresp_tmr1),.d2(s_axi_rresp_tmr2),.q(s_axi_rresp));
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_s_axi_rlast (.d0(s_axi_rlast_tmr0),.d1(s_axi_rlast_tmr1),.d2(s_axi_rlast_tmr2),.q(s_axi_rlast));
    axi_tmr_simple_voter #(RUSER_WIDTH) axi_tmr_simple_voter_s_axi_ruser (.d0(s_axi_ruser_tmr0),.d1(s_axi_ruser_tmr1),.d2(s_axi_ruser_tmr2),.q(s_axi_ruser));
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_s_axi_rvalid (.d0(s_axi_rvalid_tmr0),.d1(s_axi_rvalid_tmr1),.d2(s_axi_rvalid_tmr2),.q(s_axi_rvalid));
    assign s_axi_rready_tmr0 = s_axi_rready;
    assign s_axi_rready_tmr1 = s_axi_rready;
    assign s_axi_rready_tmr2 = s_axi_rready;

    axi_tmr_simple_voter #(ID_WIDTH) axi_tmr_simple_voter_m_axi_arid (.d0(m_axi_arid_tmr0),.d1(m_axi_arid_tmr1),.d2(m_axi_arid_tmr2),.q(m_axi_arid));
    axi_tmr_simple_voter #(ADDR_WIDTH) axi_tmr_simple_voter_m_axi_araddr (.d0(m_axi_araddr_tmr0),.d1(m_axi_araddr_tmr1),.d2(m_axi_araddr_tmr2),.q(m_axi_araddr));
    axi_tmr_simple_voter #(8) axi_tmr_simple_voter_m_axi_arlen (.d0(m_axi_arlen_tmr0),.d1(m_axi_arlen_tmr1),.d2(m_axi_arlen_tmr2),.q(m_axi_arlen));
    axi_tmr_simple_voter #(3) axi_tmr_simple_voter_m_axi_arsize (.d0(m_axi_arsize_tmr0),.d1(m_axi_arsize_tmr1),.d2(m_axi_arsize_tmr2),.q(m_axi_arsize));
    axi_tmr_simple_voter #(2) axi_tmr_simple_voter_m_axi_arburst (.d0(m_axi_arburst_tmr0),.d1(m_axi_arburst_tmr1),.d2(m_axi_arburst_tmr2),.q(m_axi_arburst));
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_m_axi_arlock (.d0(m_axi_arlock_tmr0),.d1(m_axi_arlock_tmr1),.d2(m_axi_arlock_tmr2),.q(m_axi_arlock));
    axi_tmr_simple_voter #(4) axi_tmr_simple_voter_m_axi_arcache (.d0(m_axi_arcache_tmr0),.d1(m_axi_arcache_tmr1),.d2(m_axi_arcache_tmr2),.q(m_axi_arcache));
    axi_tmr_simple_voter #(3) axi_tmr_simple_voter_m_axi_arprot (.d0(m_axi_arprot_tmr0),.d1(m_axi_arprot_tmr1),.d2(m_axi_arprot_tmr2),.q(m_axi_arprot));
    axi_tmr_simple_voter #(4) axi_tmr_simple_voter_m_axi_arqos (.d0(m_axi_arqos_tmr0),.d1(m_axi_arqos_tmr1),.d2(m_axi_arqos_tmr2),.q(m_axi_arqos));
    axi_tmr_simple_voter #(4) axi_tmr_simple_voter_m_axi_arregion (.d0(m_axi_arregion_tmr0),.d1(m_axi_arregion_tmr1),.d2(m_axi_arregion_tmr2),.q(m_axi_arregion));
    axi_tmr_simple_voter #(ARUSER_WIDTH) axi_tmr_simple_voter_m_axi_aruser (.d0(m_axi_aruser_tmr0),.d1(m_axi_aruser_tmr1),.d2(m_axi_aruser_tmr2),.q(m_axi_aruser));
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_m_axi_arvalid (.d0(m_axi_arvalid_tmr0),.d1(m_axi_arvalid_tmr1),.d2(m_axi_arvalid_tmr2),.q(m_axi_arvalid));
    assign m_axi_arready_tmr0 = m_axi_arready;
    assign m_axi_arready_tmr1 = m_axi_arready;
    assign m_axi_arready_tmr2 = m_axi_arready;

    assign m_axi_rid_tmr0 = m_axi_rid;
    assign m_axi_rid_tmr1 = m_axi_rid;
    assign m_axi_rid_tmr2 = m_axi_rid;
    assign m_axi_rdata_tmr0 = m_axi_rdata;
    assign m_axi_rdata_tmr1 = m_axi_rdata;
    assign m_axi_rdata_tmr2 = m_axi_rdata;
    assign m_axi_rresp_tmr0 = m_axi_rresp;
    assign m_axi_rresp_tmr1 = m_axi_rresp;
    assign m_axi_rresp_tmr2 = m_axi_rresp;
    assign m_axi_rlast_tmr0 = m_axi_rlast;
    assign m_axi_rlast_tmr1 = m_axi_rlast;
    assign m_axi_rlast_tmr2 = m_axi_rlast;
    assign m_axi_ruser_tmr0 = m_axi_ruser;
    assign m_axi_ruser_tmr1 = m_axi_ruser;
    assign m_axi_ruser_tmr2 = m_axi_ruser;
    assign m_axi_rvalid_tmr0 = m_axi_rvalid;
    assign m_axi_rvalid_tmr1 = m_axi_rvalid;
    assign m_axi_rvalid_tmr2 = m_axi_rvalid;
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_m_axi_rready (.d0(m_axi_rready_tmr0),.d1(m_axi_rready_tmr1),.d2(m_axi_rready_tmr2),.q(m_axi_rready));

axi_register_rd#(
    .DATA_WIDTH                                 ( DATA_WIDTH ),
    .ADDR_WIDTH                                 ( ADDR_WIDTH ),
    .STRB_WIDTH                                 ( STRB_WIDTH ),
    .ID_WIDTH                                   ( ID_WIDTH ),
    .ARUSER_ENABLE                              ( ARUSER_ENABLE ),
    .ARUSER_WIDTH                               ( ARUSER_WIDTH ),
    .RUSER_ENABLE                               ( RUSER_ENABLE ),
    .RUSER_WIDTH                                ( RUSER_WIDTH ),
    .AR_REG_TYPE                                ( AR_REG_TYPE ),
    .R_REG_TYPE                                 ( R_REG_TYPE )
)u_axi_register_rd_tmr0(
    .clk                                        ( clk ),
    .rst                                        ( rst ),
    .s_axi_arid                                 ( s_axi_arid_tmr0 ),
    .s_axi_araddr                               ( s_axi_araddr_tmr0 ),
    .s_axi_arlen                                ( s_axi_arlen_tmr0 ),
    .s_axi_arsize                               ( s_axi_arsize_tmr0 ),
    .s_axi_arburst                              ( s_axi_arburst_tmr0 ),
    .s_axi_arlock                               ( s_axi_arlock_tmr0 ),
    .s_axi_arcache                              ( s_axi_arcache_tmr0 ),
    .s_axi_arprot                               ( s_axi_arprot_tmr0 ),
    .s_axi_arqos                                ( s_axi_arqos_tmr0 ),
    .s_axi_arregion                             ( s_axi_arregion_tmr0 ),
    .s_axi_aruser                               ( s_axi_aruser_tmr0 ),
    .s_axi_arvalid                              ( s_axi_arvalid_tmr0 ),
    .s_axi_arready                              ( s_axi_arready_tmr0 ),
    .s_axi_rid                                  ( s_axi_rid_tmr0 ),
    .s_axi_rdata                                ( s_axi_rdata_tmr0 ),
    .s_axi_rresp                                ( s_axi_rresp_tmr0 ),
    .s_axi_rlast                                ( s_axi_rlast_tmr0 ),
    .s_axi_ruser                                ( s_axi_ruser_tmr0 ),
    .s_axi_rvalid                               ( s_axi_rvalid_tmr0 ),
    .s_axi_rready                               ( s_axi_rready_tmr0 ),
    .m_axi_arid                                 ( m_axi_arid_tmr0 ),
    .m_axi_araddr                               ( m_axi_araddr_tmr0 ),
    .m_axi_arlen                                ( m_axi_arlen_tmr0 ),
    .m_axi_arsize                               ( m_axi_arsize_tmr0 ),
    .m_axi_arburst                              ( m_axi_arburst_tmr0 ),
    .m_axi_arlock                               ( m_axi_arlock_tmr0 ),
    .m_axi_arcache                              ( m_axi_arcache_tmr0 ),
    .m_axi_arprot                               ( m_axi_arprot_tmr0 ),
    .m_axi_arqos                                ( m_axi_arqos_tmr0 ),
    .m_axi_arregion                             ( m_axi_arregion_tmr0 ),
    .m_axi_aruser                               ( m_axi_aruser_tmr0 ),
    .m_axi_arvalid                              ( m_axi_arvalid_tmr0 ),
    .m_axi_arready                              ( m_axi_arready_tmr0 ),
    .m_axi_rid                                  ( m_axi_rid_tmr0 ),
    .m_axi_rdata                                ( m_axi_rdata_tmr0 ),
    .m_axi_rresp                                ( m_axi_rresp_tmr0 ),
    .m_axi_rlast                                ( m_axi_rlast_tmr0 ),
    .m_axi_ruser                                ( m_axi_ruser_tmr0 ),
    .m_axi_rvalid                               ( m_axi_rvalid_tmr0 ),
    .m_axi_rready                               ( m_axi_rready_tmr0 )
);

axi_register_rd#(
    .DATA_WIDTH                                 ( DATA_WIDTH ),
    .ADDR_WIDTH                                 ( ADDR_WIDTH ),
    .STRB_WIDTH                                 ( STRB_WIDTH ),
    .ID_WIDTH                                   ( ID_WIDTH ),
    .ARUSER_ENABLE                              ( ARUSER_ENABLE ),
    .ARUSER_WIDTH                               ( ARUSER_WIDTH ),
    .RUSER_ENABLE                               ( RUSER_ENABLE ),
    .RUSER_WIDTH                                ( RUSER_WIDTH ),
    .AR_REG_TYPE                                ( AR_REG_TYPE ),
    .R_REG_TYPE                                 ( R_REG_TYPE )
)u_axi_register_rd_tmr1(
    .clk                                        ( clk ),
    .rst                                        ( rst ),
    .s_axi_arid                                 ( s_axi_arid_tmr1 ),
    .s_axi_araddr                               ( s_axi_araddr_tmr1 ),
    .s_axi_arlen                                ( s_axi_arlen_tmr1 ),
    .s_axi_arsize                               ( s_axi_arsize_tmr1 ),
    .s_axi_arburst                              ( s_axi_arburst_tmr1 ),
    .s_axi_arlock                               ( s_axi_arlock_tmr1 ),
    .s_axi_arcache                              ( s_axi_arcache_tmr1 ),
    .s_axi_arprot                               ( s_axi_arprot_tmr1 ),
    .s_axi_arqos                                ( s_axi_arqos_tmr1 ),
    .s_axi_arregion                             ( s_axi_arregion_tmr1 ),
    .s_axi_aruser                               ( s_axi_aruser_tmr1 ),
    .s_axi_arvalid                              ( s_axi_arvalid_tmr1 ),
    .s_axi_arready                              ( s_axi_arready_tmr1 ),
    .s_axi_rid                                  ( s_axi_rid_tmr1 ),
    .s_axi_rdata                                ( s_axi_rdata_tmr1 ),
    .s_axi_rresp                                ( s_axi_rresp_tmr1 ),
    .s_axi_rlast                                ( s_axi_rlast_tmr1 ),
    .s_axi_ruser                                ( s_axi_ruser_tmr1 ),
    .s_axi_rvalid                               ( s_axi_rvalid_tmr1 ),
    .s_axi_rready                               ( s_axi_rready_tmr1 ),
    .m_axi_arid                                 ( m_axi_arid_tmr1 ),
    .m_axi_araddr                               ( m_axi_araddr_tmr1 ),
    .m_axi_arlen                                ( m_axi_arlen_tmr1 ),
    .m_axi_arsize                               ( m_axi_arsize_tmr1 ),
    .m_axi_arburst                              ( m_axi_arburst_tmr1 ),
    .m_axi_arlock                               ( m_axi_arlock_tmr1 ),
    .m_axi_arcache                              ( m_axi_arcache_tmr1 ),
    .m_axi_arprot                               ( m_axi_arprot_tmr1 ),
    .m_axi_arqos                                ( m_axi_arqos_tmr1 ),
    .m_axi_arregion                             ( m_axi_arregion_tmr1 ),
    .m_axi_aruser                               ( m_axi_aruser_tmr1 ),
    .m_axi_arvalid                              ( m_axi_arvalid_tmr1 ),
    .m_axi_arready                              ( m_axi_arready_tmr1 ),
    .m_axi_rid                                  ( m_axi_rid_tmr1 ),
    .m_axi_rdata                                ( m_axi_rdata_tmr1 ),
    .m_axi_rresp                                ( m_axi_rresp_tmr1 ),
    .m_axi_rlast                                ( m_axi_rlast_tmr1 ),
    .m_axi_ruser                                ( m_axi_ruser_tmr1 ),
    .m_axi_rvalid                               ( m_axi_rvalid_tmr1 ),
    .m_axi_rready                               ( m_axi_rready_tmr1 )
);

axi_register_rd#(
    .DATA_WIDTH                                 ( DATA_WIDTH ),
    .ADDR_WIDTH                                 ( ADDR_WIDTH ),
    .STRB_WIDTH                                 ( STRB_WIDTH ),
    .ID_WIDTH                                   ( ID_WIDTH ),
    .ARUSER_ENABLE                              ( ARUSER_ENABLE ),
    .ARUSER_WIDTH                               ( ARUSER_WIDTH ),
    .RUSER_ENABLE                               ( RUSER_ENABLE ),
    .RUSER_WIDTH                                ( RUSER_WIDTH ),
    .AR_REG_TYPE                                ( AR_REG_TYPE ),
    .R_REG_TYPE                                 ( R_REG_TYPE )
)u_axi_register_rd_tmr2(
    .clk                                        ( clk ),
    .rst                                        ( rst ),
    .s_axi_arid                                 ( s_axi_arid_tmr2 ),
    .s_axi_araddr                               ( s_axi_araddr_tmr2 ),
    .s_axi_arlen                                ( s_axi_arlen_tmr2 ),
    .s_axi_arsize                               ( s_axi_arsize_tmr2 ),
    .s_axi_arburst                              ( s_axi_arburst_tmr2 ),
    .s_axi_arlock                               ( s_axi_arlock_tmr2 ),
    .s_axi_arcache                              ( s_axi_arcache_tmr2 ),
    .s_axi_arprot                               ( s_axi_arprot_tmr2 ),
    .s_axi_arqos                                ( s_axi_arqos_tmr2 ),
    .s_axi_arregion                             ( s_axi_arregion_tmr2 ),
    .s_axi_aruser                               ( s_axi_aruser_tmr2 ),
    .s_axi_arvalid                              ( s_axi_arvalid_tmr2 ),
    .s_axi_arready                              ( s_axi_arready_tmr2 ),
    .s_axi_rid                                  ( s_axi_rid_tmr2 ),
    .s_axi_rdata                                ( s_axi_rdata_tmr2 ),
    .s_axi_rresp                                ( s_axi_rresp_tmr2 ),
    .s_axi_rlast                                ( s_axi_rlast_tmr2 ),
    .s_axi_ruser                                ( s_axi_ruser_tmr2 ),
    .s_axi_rvalid                               ( s_axi_rvalid_tmr2 ),
    .s_axi_rready                               ( s_axi_rready_tmr2 ),
    .m_axi_arid                                 ( m_axi_arid_tmr2 ),
    .m_axi_araddr                               ( m_axi_araddr_tmr2 ),
    .m_axi_arlen                                ( m_axi_arlen_tmr2 ),
    .m_axi_arsize                               ( m_axi_arsize_tmr2 ),
    .m_axi_arburst                              ( m_axi_arburst_tmr2 ),
    .m_axi_arlock                               ( m_axi_arlock_tmr2 ),
    .m_axi_arcache                              ( m_axi_arcache_tmr2 ),
    .m_axi_arprot                               ( m_axi_arprot_tmr2 ),
    .m_axi_arqos                                ( m_axi_arqos_tmr2 ),
    .m_axi_arregion                             ( m_axi_arregion_tmr2 ),
    .m_axi_aruser                               ( m_axi_aruser_tmr2 ),
    .m_axi_arvalid                              ( m_axi_arvalid_tmr2 ),
    .m_axi_arready                              ( m_axi_arready_tmr2 ),
    .m_axi_rid                                  ( m_axi_rid_tmr2 ),
    .m_axi_rdata                                ( m_axi_rdata_tmr2 ),
    .m_axi_rresp                                ( m_axi_rresp_tmr2 ),
    .m_axi_rlast                                ( m_axi_rlast_tmr2 ),
    .m_axi_ruser                                ( m_axi_ruser_tmr2 ),
    .m_axi_rvalid                               ( m_axi_rvalid_tmr2 ),
    .m_axi_rready                               ( m_axi_rready_tmr2 )
);

endmodule

`resetall
