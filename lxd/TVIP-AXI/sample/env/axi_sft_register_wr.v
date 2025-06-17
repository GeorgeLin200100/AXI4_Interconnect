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
 * AXI4 register (write)
 */
module axi_sft_register_wr #
(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Width of ID signal
    parameter ID_WIDTH = 8,
    // Propagate awuser signal
    parameter AWUSER_ENABLE = 0,
    // Width of awuser signal
    parameter AWUSER_WIDTH = 1,
    // Propagate wuser signal
    parameter WUSER_ENABLE = 0,
    // Width of wuser signal
    parameter WUSER_WIDTH = 1,
    // Propagate buser signal
    parameter BUSER_ENABLE = 0,
    // Width of buser signal
    parameter BUSER_WIDTH = 1,
    // AW channel register type
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter AW_REG_TYPE = 1,
    // W channel register type
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter W_REG_TYPE = 2,
    // B channel register type
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter B_REG_TYPE = 1
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * AXI slave interface
     */
    input  wire [ID_WIDTH-1:0]      s_axi_awid,
    input  wire [ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire [7:0]               s_axi_awlen,
    input  wire [2:0]               s_axi_awsize,
    input  wire [1:0]               s_axi_awburst,
    input  wire                     s_axi_awlock,
    input  wire [3:0]               s_axi_awcache,
    input  wire [2:0]               s_axi_awprot,
    input  wire [3:0]               s_axi_awqos,
    input  wire [3:0]               s_axi_awregion,
    input  wire [AWUSER_WIDTH-1:0]  s_axi_awuser,
    //input  wire                     s_axi_awvalid,
    input  wire                     s_axi_awvalid_tmr0,
    input  wire                     s_axi_awvalid_tmr1,
    input  wire                     s_axi_awvalid_tmr2,
    //output wire                     s_axi_awready,
    output wire                     s_axi_awready_tmr0,
    output wire                     s_axi_awready_tmr1,
    output wire                     s_axi_awready_tmr2,

    input  wire [DATA_WIDTH-1:0]    s_axi_wdata,
    input  wire [STRB_WIDTH-1:0]    s_axi_wstrb,
    input  wire                     s_axi_wlast,
    input  wire [WUSER_WIDTH-1:0]   s_axi_wuser,
    input  wire                     s_axi_wvalid,
    output wire                     s_axi_wready,
    output wire [ID_WIDTH-1:0]      s_axi_bid,
    output wire [1:0]               s_axi_bresp,
    output wire [BUSER_WIDTH-1:0]   s_axi_buser,
    output wire                     s_axi_bvalid,
    input  wire                     s_axi_bready,

    /*
     * AXI master interface
     */
    output wire [ID_WIDTH-1:0]      m_axi_awid,
    output wire [ADDR_WIDTH-1:0]    m_axi_awaddr,
    output wire [7:0]               m_axi_awlen,
    output wire [2:0]               m_axi_awsize,
    output wire [1:0]               m_axi_awburst,
    output wire                     m_axi_awlock,
    output wire [3:0]               m_axi_awcache,
    output wire [2:0]               m_axi_awprot,
    output wire [3:0]               m_axi_awqos,
    output wire [3:0]               m_axi_awregion,
    output wire [AWUSER_WIDTH-1:0]  m_axi_awuser,
    //output wire                     m_axi_awvalid,
    output wire                     m_axi_awvalid_tmr0,
    output wire                     m_axi_awvalid_tmr1,
    output wire                     m_axi_awvalid_tmr2,
    //input  wire                     m_axi_awready,
    output wire                     m_axi_awready_tmr0,
    output wire                     m_axi_awready_tmr1,
    output wire                     m_axi_awready_tmr2,
    output wire [DATA_WIDTH-1:0]    m_axi_wdata,
    output wire [STRB_WIDTH-1:0]    m_axi_wstrb,
    output wire                     m_axi_wlast,
    output wire [WUSER_WIDTH-1:0]   m_axi_wuser,
    output wire                     m_axi_wvalid,
    input  wire                     m_axi_wready,
    input  wire [ID_WIDTH-1:0]      m_axi_bid,
    input  wire [1:0]               m_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]   m_axi_buser,
    input  wire                     m_axi_bvalid,
    output wire                     m_axi_bready
);

    wire [ID_WIDTH-1:0]      s_axi_awid_tmr0;
    wire [ADDR_WIDTH-1:0]    s_axi_awaddr_tmr0;
    wire [7:0]               s_axi_awlen_tmr0;
    wire [2:0]               s_axi_awsize_tmr0;
    wire [1:0]               s_axi_awburst_tmr0;
    wire                     s_axi_awlock_tmr0;
    wire [3:0]               s_axi_awcache_tmr0;
    wire [2:0]               s_axi_awprot_tmr0;
    wire [3:0]               s_axi_awqos_tmr0;
    wire [3:0]               s_axi_awregion_tmr0;
    wire [AWUSER_WIDTH-1:0]  s_axi_awuser_tmr0;
    wire [DATA_WIDTH-1:0]    s_axi_wdata_tmr0;
    wire [STRB_WIDTH-1:0]    s_axi_wstrb_tmr0;
    wire                     s_axi_wlast_tmr0;
    wire [WUSER_WIDTH-1:0]   s_axi_wuser_tmr0;
    wire                     s_axi_wvalid_tmr0;
    wire                     s_axi_wready_tmr0;
    wire [ID_WIDTH-1:0]      s_axi_bid_tmr0;
    wire [1:0]               s_axi_bresp_tmr0;
    wire [BUSER_WIDTH-1:0]   s_axi_buser_tmr0;
    wire                     s_axi_bvalid_tmr0;
    wire                     s_axi_bready_tmr0;

    wire [ID_WIDTH-1:0]      m_axi_awid_tmr0;
    wire [ADDR_WIDTH-1:0]    m_axi_awaddr_tmr0;
    wire [7:0]               m_axi_awlen_tmr0;
    wire [2:0]               m_axi_awsize_tmr0;
    wire [1:0]               m_axi_awburst_tmr0;
    wire                     m_axi_awlock_tmr0;
    wire [3:0]               m_axi_awcache_tmr0;
    wire [2:0]               m_axi_awprot_tmr0;
    wire [3:0]               m_axi_awqos_tmr0;
    wire [3:0]               m_axi_awregion_tmr0;
    wire [AWUSER_WIDTH-1:0]  m_axi_awuser_tmr0;
    wire [DATA_WIDTH-1:0]    m_axi_wdata_tmr0;
    wire [STRB_WIDTH-1:0]    m_axi_wstrb_tmr0;
    wire                     m_axi_wlast_tmr0;
    wire [WUSER_WIDTH-1:0]   m_axi_wuser_tmr0;
    wire                     m_axi_wvalid_tmr0;
    wire                     m_axi_wready_tmr0;
    wire [ID_WIDTH-1:0]      m_axi_bid_tmr0;
    wire [1:0]               m_axi_bresp_tmr0;
    wire [BUSER_WIDTH-1:0]   m_axi_buser_tmr0;
    wire                     m_axi_bvalid_tmr0;
    wire                     m_axi_bready_tmr0;

    wire [ID_WIDTH-1:0]      s_axi_awid_tmr1;
    wire [ADDR_WIDTH-1:0]    s_axi_awaddr_tmr1;
    wire [7:0]               s_axi_awlen_tmr1;
    wire [2:0]               s_axi_awsize_tmr1;
    wire [1:0]               s_axi_awburst_tmr1;
    wire                     s_axi_awlock_tmr1;
    wire [3:0]               s_axi_awcache_tmr1;
    wire [2:0]               s_axi_awprot_tmr1;
    wire [3:0]               s_axi_awqos_tmr1;
    wire [3:0]               s_axi_awregion_tmr1;
    wire [AWUSER_WIDTH-1:0]  s_axi_awuser_tmr1;
    wire [DATA_WIDTH-1:0]    s_axi_wdata_tmr1;
    wire [STRB_WIDTH-1:0]    s_axi_wstrb_tmr1;
    wire                     s_axi_wlast_tmr1;
    wire [WUSER_WIDTH-1:0]   s_axi_wuser_tmr1;
    wire                     s_axi_wvalid_tmr1;
    wire                     s_axi_wready_tmr1;
    wire [ID_WIDTH-1:0]      s_axi_bid_tmr1;
    wire [1:0]               s_axi_bresp_tmr1;
    wire [BUSER_WIDTH-1:0]   s_axi_buser_tmr1;
    wire                     s_axi_bvalid_tmr1;
    wire                     s_axi_bready_tmr1;

    wire [ID_WIDTH-1:0]      m_axi_awid_tmr1;
    wire [ADDR_WIDTH-1:0]    m_axi_awaddr_tmr1;
    wire [7:0]               m_axi_awlen_tmr1;
    wire [2:0]               m_axi_awsize_tmr1;
    wire [1:0]               m_axi_awburst_tmr1;
    wire                     m_axi_awlock_tmr1;
    wire [3:0]               m_axi_awcache_tmr1;
    wire [2:0]               m_axi_awprot_tmr1;
    wire [3:0]               m_axi_awqos_tmr1;
    wire [3:0]               m_axi_awregion_tmr1;
    wire [AWUSER_WIDTH-1:0]  m_axi_awuser_tmr1;
    wire [DATA_WIDTH-1:0]    m_axi_wdata_tmr1;
    wire [STRB_WIDTH-1:0]    m_axi_wstrb_tmr1;
    wire                     m_axi_wlast_tmr1;
    wire [WUSER_WIDTH-1:0]   m_axi_wuser_tmr1;
    wire                     m_axi_wvalid_tmr1;
    wire                     m_axi_wready_tmr1;
    wire [ID_WIDTH-1:0]      m_axi_bid_tmr1;
    wire [1:0]               m_axi_bresp_tmr1;
    wire [BUSER_WIDTH-1:0]   m_axi_buser_tmr1;
    wire                     m_axi_bvalid_tmr1;
    wire                     m_axi_bready_tmr1;

    wire [ID_WIDTH-1:0]      s_axi_awid_tmr2;
    wire [ADDR_WIDTH-1:0]    s_axi_awaddr_tmr2;
    wire [7:0]               s_axi_awlen_tmr2;
    wire [2:0]               s_axi_awsize_tmr2;
    wire [1:0]               s_axi_awburst_tmr2;
    wire                     s_axi_awlock_tmr2;
    wire [3:0]               s_axi_awcache_tmr2;
    wire [2:0]               s_axi_awprot_tmr2;
    wire [3:0]               s_axi_awqos_tmr2;
    wire [3:0]               s_axi_awregion_tmr2;
    wire [AWUSER_WIDTH-1:0]  s_axi_awuser_tmr2;
    wire [DATA_WIDTH-1:0]    s_axi_wdata_tmr2;
    wire [STRB_WIDTH-1:0]    s_axi_wstrb_tmr2;
    wire                     s_axi_wlast_tmr2;
    wire [WUSER_WIDTH-1:0]   s_axi_wuser_tmr2;
    wire                     s_axi_wvalid_tmr2;
    wire                     s_axi_wready_tmr2;
    wire [ID_WIDTH-1:0]      s_axi_bid_tmr2;
    wire [1:0]               s_axi_bresp_tmr2;
    wire [BUSER_WIDTH-1:0]   s_axi_buser_tmr2;
    wire                     s_axi_bvalid_tmr2;
    wire                     s_axi_bready_tmr2;

    wire [ID_WIDTH-1:0]      m_axi_awid_tmr2;
    wire [ADDR_WIDTH-1:0]    m_axi_awaddr_tmr2;
    wire [7:0]               m_axi_awlen_tmr2;
    wire [2:0]               m_axi_awsize_tmr2;
    wire [1:0]               m_axi_awburst_tmr2;
    wire                     m_axi_awlock_tmr2;
    wire [3:0]               m_axi_awcache_tmr2;
    wire [2:0]               m_axi_awprot_tmr2;
    wire [3:0]               m_axi_awqos_tmr2;
    wire [3:0]               m_axi_awregion_tmr2;
    wire [AWUSER_WIDTH-1:0]  m_axi_awuser_tmr2;
    wire [DATA_WIDTH-1:0]    m_axi_wdata_tmr2;
    wire [STRB_WIDTH-1:0]    m_axi_wstrb_tmr2;
    wire                     m_axi_wlast_tmr2;
    wire [WUSER_WIDTH-1:0]   m_axi_wuser_tmr2;
    wire                     m_axi_wvalid_tmr2;
    wire                     m_axi_wready_tmr2;
    wire [ID_WIDTH-1:0]      m_axi_bid_tmr2;
    wire [1:0]               m_axi_bresp_tmr2;
    wire [BUSER_WIDTH-1:0]   m_axi_buser_tmr2;
    wire                     m_axi_bvalid_tmr2;
    wire                     m_axi_bready_tmr2;

    assign s_axi_awid_tmr0 = s_axi_awid;
    assign s_axi_awid_tmr1 = s_axi_awid;
    assign s_axi_awid_tmr2 = s_axi_awid;
    assign s_axi_awaddr_tmr0 = s_axi_awaddr;
    assign s_axi_awaddr_tmr1 = s_axi_awaddr;
    assign s_axi_awaddr_tmr2 = s_axi_awaddr;
    assign s_axi_awlen_tmr0 = s_axi_awlen;
    assign s_axi_awlen_tmr1 = s_axi_awlen;
    assign s_axi_awlen_tmr2 = s_axi_awlen;
    assign s_axi_awsize_tmr0 = s_axi_awsize;
    assign s_axi_awsize_tmr1 = s_axi_awsize;
    assign s_axi_awsize_tmr2 = s_axi_awsize;
    assign s_axi_awburst_tmr0 = s_axi_awburst;
    assign s_axi_awburst_tmr1 = s_axi_awburst;
    assign s_axi_awburst_tmr2 = s_axi_awburst;
    assign s_axi_awlock_tmr0 = s_axi_awlock;
    assign s_axi_awlock_tmr1 = s_axi_awlock;
    assign s_axi_awlock_tmr2 = s_axi_awlock;
    assign s_axi_awcache_tmr0 = s_axi_awcache;
    assign s_axi_awcache_tmr1 = s_axi_awcache;
    assign s_axi_awcache_tmr2 = s_axi_awcache;
    assign s_axi_awprot_tmr0 = s_axi_awprot;
    assign s_axi_awprot_tmr1 = s_axi_awprot;
    assign s_axi_awprot_tmr2 = s_axi_awprot;
    assign s_axi_awqos_tmr0 = s_axi_awqos;
    assign s_axi_awqos_tmr1 = s_axi_awqos;
    assign s_axi_awqos_tmr2 = s_axi_awqos;
    assign s_axi_awregion_tmr0 = s_axi_awregion;
    assign s_axi_awregion_tmr1 = s_axi_awregion;
    assign s_axi_awregion_tmr2 = s_axi_awregion;
    assign s_axi_awuser_tmr0 = s_axi_awuser;
    assign s_axi_awuser_tmr1 = s_axi_awuser;
    assign s_axi_awuser_tmr2 = s_axi_awuser;

    assign s_axi_wdata_tmr0 = s_axi_wdata;
    assign s_axi_wdata_tmr1 = s_axi_wdata;
    assign s_axi_wdata_tmr2 = s_axi_wdata;
    assign s_axi_wstrb_tmr0 = s_axi_wstrb;
    assign s_axi_wstrb_tmr1 = s_axi_wstrb;
    assign s_axi_wstrb_tmr2 = s_axi_wstrb;
    assign s_axi_wlast_tmr0 = s_axi_wlast;
    assign s_axi_wlast_tmr1 = s_axi_wlast;
    assign s_axi_wlast_tmr2 = s_axi_wlast;
    assign s_axi_wuser_tmr0 = s_axi_wuser;
    assign s_axi_wuser_tmr1 = s_axi_wuser;
    assign s_axi_wuser_tmr2 = s_axi_wuser;
    assign s_axi_wvalid_tmr0 = s_axi_wvalid;
    assign s_axi_wvalid_tmr1 = s_axi_wvalid;
    assign s_axi_wvalid_tmr2 = s_axi_wvalid;
    axi_tmr_simple_voter #(1) (.d0(s_axi_wready_tmr0),.d1(s_axi_wready_tmr1),.d2(s_axi_wready_tmr2),.q(s_axi_wready));

    axi_tmr_simple_voter #(1) (.d0(s_axi_bvalid_tmr0),.d1(s_axi_bvalid_tmr1),.d2(s_axi_bvalid_tmr2),.q(s_axi_bvalid));
    axi_tmr_simple_voter #(2) (.d0(s_axi_bresp_tmr0),.d1(s_axi_bresp_tmr1),.d2(s_axi_bresp_tmr2),.q(s_axi_bresp));
    assign s_axi_bready_tmr0 = s_axi_bready;
    assign s_axi_bready_tmr1 = s_axi_bready;
    assign s_axi_bready_tmr2 = s_axi_bready;
    axi_tmr_simple_voter #(ID_WIDTH) (.d0(s_axi_bid_tmr0),.d1(s_axi_bid_tmr1),.d2(s_axi_bid_tmr2),.q(s_axi_bid));
    axi_tmr_simple_voter #(BUSER_WIDTH) (.d0(s_axi_buser_tmr0),.d1(s_axi_buser_tmr1),.d2(s_axi_buser_tmr2),.q(s_axi_buser));

    // M Side
    axi_tmr_simple_voter #(ID_WIDTH) (.d0(m_axi_awid_tmr0),.d1(m_axi_awid_tmr1),.d2(m_axi_awid_tmr2),.q(m_axi_awid));
    axi_tmr_simple_voter #(ADDR_WIDTH) (.d0(m_axi_awaddr_tmr0),.d1(m_axi_awaddr_tmr1),.d2(m_axi_awaddr_tmr2),.q(m_axi_awaddr));
    axi_tmr_simple_voter #(8) (.d0(m_axi_awlen_tmr0),.d1(m_axi_awlen_tmr1),.d2(m_axi_awlen_tmr2),.q(m_axi_awlen));
    axi_tmr_simple_voter #(3) (.d0(m_axi_awsize_tmr0),.d1(m_axi_awsize_tmr1),.d2(m_axi_awsize_tmr2),.q(m_axi_awsize));
    axi_tmr_simple_voter #(2) (.d0(m_axi_awburst_tmr0),.d1(m_axi_awburst_tmr1),.d2(m_axi_awburst_tmr2),.q(m_axi_awburst));
    axi_tmr_simple_voter #(1) (.d0(m_axi_awlock_tmr0),.d1(m_axi_awlock_tmr1),.d2(m_axi_awlock_tmr2),.q(m_axi_awlock));
    axi_tmr_simple_voter #(4) (.d0(m_axi_awcache_tmr0),.d1(m_axi_awcache_tmr1),.d2(m_axi_awcache_tmr2),.q(m_axi_awcache));
    axi_tmr_simple_voter #(3) (.d0(m_axi_awprot_tmr0),.d1(m_axi_awprot_tmr1),.d2(m_axi_awprot_tmr2),.q(m_axi_awprot));
    axi_tmr_simple_voter #(4) (.d0(m_axi_awqos_tmr0),.d1(m_axi_awqos_tmr1),.d2(m_axi_awqos_tmr2),.q(m_axi_awqos));
    axi_tmr_simple_voter #(4) (.d0(m_axi_awregion_tmr0),.d1(m_axi_awregion_tmr1),.d2(m_axi_awregion_tmr2),.q(m_axi_awregion));
    axi_tmr_simple_voter #(AWUSER_WIDTH) (.d0(m_axi_awuser_tmr0),.d1(m_axi_awuser_tmr1),.d2(m_axi_awuser_tmr2),.q(m_axi_awuser));

    axi_tmr_simple_voter #(1) (.d0(m_axi_wvalid_tmr0),.d1(m_axi_wvalid_tmr1),.d2(m_axi_wvalid_tmr2),.q(m_axi_wvalid));
    assign m_axi_wready_tmr0 = m_axi_wready;
    assign m_axi_wready_tmr1 = m_axi_wready;
    assign m_axi_wready_tmr2 = m_axi_wready;
    axi_tmr_simple_voter #(DATA_WIDTH) (.d0(m_axi_wdata_tmr0),.d1(m_axi_wdata_tmr1),.d2(m_axi_wdata_tmr2),.q(m_axi_wdata));
    axi_tmr_simple_voter #(STRB_WIDTH) (.d0(m_axi_wstrb_tmr0),.d1(m_axi_wstrb_tmr1),.d2(m_axi_wstrb_tmr2),.q(m_axi_wstrb));
    axi_tmr_simple_voter #(1) (.d0(m_axi_wlast_tmr0),.d1(m_axi_wlast_tmr1),.d2(m_axi_wlast_tmr2),.q(m_axi_wlast));
    axi_tmr_simple_voter #(WUSER_WIDTH) (.d0(m_axi_wuser_tmr0),.d1(m_axi_wuser_tmr1),.d2(m_axi_wuser_tmr2),.q(m_axi_wuser));

    assign m_axi_bid_tmr0 = m_axi_bid;
    assign m_axi_bid_tmr1 = m_axi_bid;
    assign m_axi_bid_tmr2 = m_axi_bid;
    assign m_axi_bvalid_tmr0 = m_axi_bvalid;
    assign m_axi_bvalid_tmr1 = m_axi_bvalid;
    assign m_axi_bvalid_tmr2 = m_axi_bvalid;
    assign m_axi_bresp_tmr0 = m_axi_bresp;
    assign m_axi_bresp_tmr1 = m_axi_bresp;
    assign m_axi_bresp_tmr2 = m_axi_bresp;
    assign m_axi_buser_tmr0 = m_axi_buser;
    assign m_axi_buser_tmr1 = m_axi_buser;
    assign m_axi_buser_tmr2 = m_axi_buser;
    axi_tmr_simple_voter #(1) (.d0(m_axi_bready_tmr0),.d1(m_axi_bready_tmr1),.d2(m_axi_bready_tmr2),.q(m_axi_bready));

axi_register_wr#(
    .DATA_WIDTH                                 ( DATA_WIDTH ),
    .ADDR_WIDTH                                 ( ADDR_WIDTH ),

    .STRB_WIDTH                                 ( STRB_WIDTH ),
    .ID_WIDTH                                   ( ID_WIDTH ),
    .AWUSER_ENABLE                              ( AWUSER_ENABLE ),
    .AWUSER_WIDTH                               ( AWUSER_WIDTH ),
    .WUSER_ENABLE                               ( WUSER_ENABLE ),
    .WUSER_WIDTH                                ( WUSER_WIDTH ),
    .BUSER_ENABLE                               ( BUSER_ENABLE ),
    .BUSER_WIDTH                                ( BUSER_WIDTH ),
    .AW_REG_TYPE                                ( AW_REG_TYPE ),
    .W_REG_TYPE                                 ( W_REG_TYPE ),
    .B_REG_TYPE                                 ( B_REG_TYPE )
)u_axi_register_wr_tmr0(
    .clk                                        ( clk                                        ),
    .rst                                        ( rst                                        ),
    .s_axi_awid                                 ( s_axi_awid_tmr0                                 ),
    .s_axi_awaddr                               ( s_axi_awaddr_tmr0                                ),
    .s_axi_awlen                                ( s_axi_awlen_tmr0                                 ),
    .s_axi_awsize                               ( s_axi_awsize_tmr0                                ),
    .s_axi_awburst                              ( s_axi_awburst_tmr0                               ),
    .s_axi_awlock                               ( s_axi_awlock_tmr0                                ),
    .s_axi_awcache                              ( s_axi_awcache_tmr0                               ),
    .s_axi_awprot                               ( s_axi_awprot_tmr0                                ),
    .s_axi_awqos                                ( s_axi_awqos_tmr0                                 ),
    .s_axi_awregion                             ( s_axi_awregion_tmr0                              ),
    .s_axi_awuser                               ( s_axi_awuser_tmr0                                ),
    .s_axi_awvalid                              ( s_axi_awvalid_tmr0                               ),
    .s_axi_awready                              ( s_axi_awready_tmr0                               ),
    .s_axi_wdata                                ( s_axi_wdata_tmr0                                 ),
    .s_axi_wstrb                                ( s_axi_wstrb_tmr0                                 ),
    .s_axi_wlast                                ( s_axi_wlast_tmr0                                 ),
    .s_axi_wuser                                ( s_axi_wuser_tmr0                                ),
    .s_axi_wvalid                               ( s_axi_wvalid_tmr0                              ),
    .s_axi_wready                               ( s_axi_wready_tmr0                              ),
    .s_axi_bid                                  ( s_axi_bid_tmr0                                ),
    .s_axi_bresp                                ( s_axi_bresp_tmr0                              ),
    .s_axi_buser                                ( s_axi_buser_tmr0                              ),
    .s_axi_bvalid                               ( s_axi_bvalid_tmr0                             ),
    .s_axi_bready                               ( s_axi_bready_tmr0                             ),
    .m_axi_awid                                 ( m_axi_awid_tmr0                                 ),
    .m_axi_awaddr                               ( m_axi_awaddr_tmr0                               ),
    .m_axi_awlen                                ( m_axi_awlen_tmr0                                ),
    .m_axi_awsize                               ( m_axi_awsize_tmr0                               ),
    .m_axi_awburst                              ( m_axi_awburst_tmr0                              ),
    .m_axi_awlock                               ( m_axi_awlock_tmr0                               ),
    .m_axi_awcache                              ( m_axi_awcache_tmr0                              ),
    .m_axi_awprot                               ( m_axi_awprot_tmr0                               ),
    .m_axi_awqos                                ( m_axi_awqos_tmr0                                ),
    .m_axi_awregion                             ( m_axi_awregion_tmr0                             ),
    .m_axi_awuser                               ( m_axi_awuser_tmr0                             ),
    .m_axi_awvalid                              ( m_axi_awvalid_tmr0                            ),
    .m_axi_awready                              ( m_axi_awready_tmr0                            ),
    .m_axi_wdata                                ( m_axi_wdata_tmr0                              ),
    .m_axi_wstrb                                ( m_axi_wstrb_tmr0                              ),
    .m_axi_wlast                                ( m_axi_wlast_tmr0                              ),
    .m_axi_wuser                                ( m_axi_wuser_tmr0                              ),
    .m_axi_wvalid                               ( m_axi_wvalid_tmr0                             ),
    .m_axi_wready                               ( m_axi_wready_tmr0                             ),
    .m_axi_bid                                  ( m_axi_bid_tmr0                               ),
    .m_axi_bresp                                ( m_axi_bresp_tmr0                             ),
    .m_axi_buser                                ( m_axi_buser_tmr0                             ),
    .m_axi_bvalid                               ( m_axi_bvalid_tmr0                            ),
    .m_axi_bready                               ( m_axi_bready_tmr0                            ),
    .s_axi_bready                               ( s_axi_bready_tmr0                            )
);

axi_register_wr#(
    .DATA_WIDTH                                 ( DATA_WIDTH ),
    .ADDR_WIDTH                                 ( ADDR_WIDTH ),
    .STRB_WIDTH                                 ( STRB_WIDTH ),
    .ID_WIDTH                                   ( ID_WIDTH ),
    .AWUSER_ENABLE                              ( AWUSER_ENABLE ),
    .AWUSER_WIDTH                               ( AWUSER_WIDTH ),
    .WUSER_ENABLE                               ( WUSER_ENABLE ),
    .WUSER_WIDTH                                ( WUSER_WIDTH ),
    .BUSER_ENABLE                               ( BUSER_ENABLE ),
    .BUSER_WIDTH                                ( BUSER_WIDTH ),
    .AW_REG_TYPE                                ( AW_REG_TYPE ),
    .W_REG_TYPE                                 ( W_REG_TYPE ),
    .B_REG_TYPE                                 ( B_REG_TYPE )
)u_axi_register_wr_tmr1(
    .clk                                        ( clk                                        ),
    .rst                                        ( rst                                        ),
    .s_axi_awid                                 ( s_axi_awid_tmr1                                 ),
    .s_axi_awaddr                               ( s_axi_awaddr_tmr1                                ),
    .s_axi_awlen                                ( s_axi_awlen_tmr1                                 ),
    .s_axi_awsize                               ( s_axi_awsize_tmr1                                ),
    .s_axi_awburst                              ( s_axi_awburst_tmr1                               ),
    .s_axi_awlock                               ( s_axi_awlock_tmr1                                ),
    .s_axi_awcache                              ( s_axi_awcache_tmr1                               ),
    .s_axi_awprot                               ( s_axi_awprot_tmr1                                ),
    .s_axi_awqos                                ( s_axi_awqos_tmr1                                 ),
    .s_axi_awregion                             ( s_axi_awregion_tmr1                              ),
    .s_axi_awuser                               ( s_axi_awuser_tmr1                                ),
    .s_axi_awvalid                              ( s_axi_awvalid_tmr1                               ),
    .s_axi_awready                              ( s_axi_awready_tmr1                               ),
    .s_axi_wdata                                ( s_axi_wdata_tmr1                                 ),
    .s_axi_wstrb                                ( s_axi_wstrb_tmr1                                 ),
    .s_axi_wlast                                ( s_axi_wlast_tmr1                                 ),
    .s_axi_wuser                                ( s_axi_wuser_tmr1                                ),
    .s_axi_wvalid                               ( s_axi_wvalid_tmr1                              ),
    .s_axi_wready                               ( s_axi_wready_tmr1                              ),
    .s_axi_bid                                  ( s_axi_bid_tmr1                                ),
    .s_axi_bresp                                ( s_axi_bresp_tmr1                              ),
    .s_axi_buser                                ( s_axi_buser_tmr1                              ),
    .s_axi_bvalid                               ( s_axi_bvalid_tmr1                             ),
    .s_axi_bready                               ( s_axi_bready_tmr1                             ),
    .m_axi_awid                                 ( m_axi_awid_tmr1                                 ),
    .m_axi_awaddr                               ( m_axi_awaddr_tmr1                               ),
    .m_axi_awlen                                ( m_axi_awlen_tmr1                                ),
    .m_axi_awsize                               ( m_axi_awsize_tmr1                               ),
    .m_axi_awburst                              ( m_axi_awburst_tmr1                              ),
    .m_axi_awlock                               ( m_axi_awlock_tmr1                               ),
    .m_axi_awcache                              ( m_axi_awcache_tmr1                              ),
    .m_axi_awprot                               ( m_axi_awprot_tmr1                               ),
    .m_axi_awqos                                ( m_axi_awqos_tmr1                                ),
    .m_axi_awregion                             ( m_axi_awregion_tmr1                             ),
    .m_axi_awuser                               ( m_axi_awuser_tmr1                             ),
    .m_axi_awvalid                              ( m_axi_awvalid_tmr1                            ),
    .m_axi_awready                              ( m_axi_awready_tmr1                            ),
    .m_axi_wdata                                ( m_axi_wdata_tmr1                              ),
    .m_axi_wstrb                                ( m_axi_wstrb_tmr1                              ),
    .m_axi_wlast                                ( m_axi_wlast_tmr1                              ),
    .m_axi_wuser                                ( m_axi_wuser_tmr1                              ),
    .m_axi_wvalid                               ( m_axi_wvalid_tmr1                             ),
    .m_axi_wready                               ( m_axi_wready_tmr1                             ),
    .m_axi_bid                                  ( m_axi_bid_tmr1                               ),
    .m_axi_bresp                                ( m_axi_bresp_tmr1                             ),
    .m_axi_buser                                ( m_axi_buser_tmr1                             ),
    .m_axi_bvalid                               ( m_axi_bvalid_tmr1                            ),
    .m_axi_bready                               ( m_axi_bready_tmr1                            ),
    .s_axi_bready                               ( s_axi_bready_tmr1                            )
);

axi_register_wr#(
    .DATA_WIDTH                                 ( DATA_WIDTH ),
    .ADDR_WIDTH                                 ( ADDR_WIDTH ),
    .STRB_WIDTH                                 ( STRB_WIDTH ),
    .ID_WIDTH                                   ( ID_WIDTH ),
    .AWUSER_ENABLE                              ( AWUSER_ENABLE ),
    .AWUSER_WIDTH                               ( AWUSER_WIDTH ),
    .WUSER_ENABLE                               ( WUSER_ENABLE ),
    .WUSER_WIDTH                                ( WUSER_WIDTH ),
    .BUSER_ENABLE                               ( BUSER_ENABLE ),
    .BUSER_WIDTH                                ( BUSER_WIDTH ),
    .AW_REG_TYPE                                ( AW_REG_TYPE ),
    .W_REG_TYPE                                 ( W_REG_TYPE ),
    .B_REG_TYPE                                 ( B_REG_TYPE )

)u_axi_register_wr_tmr2(
    .clk                                        ( clk                                        ),
    .rst                                        ( rst                                        ),
    .s_axi_awid                                 ( s_axi_awid_tmr2                                 ),
    .s_axi_awaddr                               ( s_axi_awaddr_tmr2                                ),
    .s_axi_awlen                                ( s_axi_awlen_tmr2                                 ),
    .s_axi_awsize                               ( s_axi_awsize_tmr2                                ),
    .s_axi_awburst                              ( s_axi_awburst_tmr2                               ),
    .s_axi_awlock                               ( s_axi_awlock_tmr2                                ),
    .s_axi_awcache                              ( s_axi_awcache_tmr2                               ),
    .s_axi_awprot                               ( s_axi_awprot_tmr2                                ),
    .s_axi_awqos                                ( s_axi_awqos_tmr2                                 ),
    .s_axi_awregion                             ( s_axi_awregion_tmr2                              ),
    .s_axi_awuser                               ( s_axi_awuser_tmr2                                ),
    .s_axi_awvalid                              ( s_axi_awvalid_tmr2                               ),
    .s_axi_awready                              ( s_axi_awready_tmr2                               ),
    .s_axi_wdata                                ( s_axi_wdata_tmr2                                 ),
    .s_axi_wstrb                                ( s_axi_wstrb_tmr2                                 ),
    .s_axi_wlast                                ( s_axi_wlast_tmr2                                 ),
    .s_axi_wuser                                ( s_axi_wuser_tmr2                                ),
    .s_axi_wvalid                               ( s_axi_wvalid_tmr2                              ),
    .s_axi_wready                               ( s_axi_wready_tmr2                              ),
    .s_axi_bid                                  ( s_axi_bid_tmr2                                ),
    .s_axi_bresp                                ( s_axi_bresp_tmr2                              ),
    .s_axi_buser                                ( s_axi_buser_tmr2                              ),
    .s_axi_bvalid                               ( s_axi_bvalid_tmr2                             ),
    .s_axi_bready                               ( s_axi_bready_tmr2                             ),
    .m_axi_awid                                 ( m_axi_awid_tmr2                                 ),
    .m_axi_awaddr                               ( m_axi_awaddr_tmr2                               ),
    .m_axi_awlen                                ( m_axi_awlen_tmr2                                ),
    .m_axi_awsize                               ( m_axi_awsize_tmr2                               ),
    .m_axi_awburst                              ( m_axi_awburst_tmr2                              ),
    .m_axi_awlock                               ( m_axi_awlock_tmr2                               ),
    .m_axi_awcache                              ( m_axi_awcache_tmr2                              ),
    .m_axi_awprot                               ( m_axi_awprot_tmr2                               ),
    .m_axi_awqos                                ( m_axi_awqos_tmr2                                ),
    .m_axi_awregion                             ( m_axi_awregion_tmr2                             ),
    .m_axi_awuser                               ( m_axi_awuser_tmr2                             ),
    .m_axi_awvalid                              ( m_axi_awvalid_tmr2                            ),
    .m_axi_awready                              ( m_axi_awready_tmr2                            ),
    .m_axi_wdata                                ( m_axi_wdata_tmr2                              ),
    .m_axi_wstrb                                ( m_axi_wstrb_tmr2                              ),
    .m_axi_wlast                                ( m_axi_wlast_tmr2                              ),
    .m_axi_wuser                                ( m_axi_wuser_tmr2                              ),
    .m_axi_wvalid                               ( m_axi_wvalid_tmr2                             ),
    .m_axi_wready                               ( m_axi_wready_tmr2                             ),
    .m_axi_bid                                  ( m_axi_bid_tmr2                               ),
    .m_axi_bresp                                ( m_axi_bresp_tmr2                             ),
    .m_axi_buser                                ( m_axi_buser_tmr2                             ),
    .m_axi_bvalid                               ( m_axi_bvalid_tmr2                            ),
    .m_axi_bready                               ( m_axi_bready_tmr2                            ),
    .s_axi_bready                               ( s_axi_bready_tmr2                            )
);

endmodule

`resetall
