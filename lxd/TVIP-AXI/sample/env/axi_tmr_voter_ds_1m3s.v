//
`resetall
`timescale 1ns / 1ps
`default_nettype none
`include "axi_tmr_signal_define.vh"

module axi_tmr_voter_ds_1m3s #(
    // Width of data bus in bits
    parameter DATA_WIDTH = 64,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Input ID field width (from AXI masters)
    parameter S_ID_WIDTH = 8,
    // Output ID field width (towards AXI slaves)
    // Additional bits required for response routing
    parameter M_ID_WIDTH = S_ID_WIDTH+$clog2(3),
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
    // Propagate aruser signal
    parameter ARUSER_ENABLE = 0,
    // Width of aruser signal
    parameter ARUSER_WIDTH = 1,
    // Propagate ruser signal
    parameter RUSER_ENABLE = 0,
    // Width of ruser signal
    parameter RUSER_WIDTH = 1,
    // Number of concurrent unique IDs
    parameter S00_THREADS = 8,
    // Number of concurrent operations
    parameter S00_ACCEPT = 16,
    // Number of concurrent unique IDs
    parameter S01_THREADS = 8,
    // Number of concurrent operations
    parameter S01_ACCEPT = 16,
    // Number of concurrent unique IDs
    parameter S02_THREADS = 8,
    // Number of concurrent operations
    parameter S02_ACCEPT = 16,
    // Number of regions per master interface
    parameter M_REGIONS = 1,
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    parameter M00_BASE_ADDR = 0, // enable default mapping
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    parameter M00_ADDR_WIDTH = {M_REGIONS{32'd24}},
    // Read connections between interfaces
    // S_COUNT bits
    parameter M00_CONNECT_READ = 3'b100,  // Slave 0 only connect to Master 2
    // Write connections between interfaces
    // S_COUNT bits
    parameter M00_CONNECT_WRITE = 3'b100, // Slave 0 only connect to Master 2
    // Number of concurrent operations for each master interface
    parameter M00_ISSUE = 8,
    // Secure master (fail operations based on awprot/arprot)
    parameter M00_SECURE = 1, //Slave 0 is secure
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    parameter M01_BASE_ADDR = 0, // enable default mapping
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    parameter M01_ADDR_WIDTH = {M_REGIONS{32'd24}},
    // Read connections between interfaces
    // S_COUNT bits
    parameter M01_CONNECT_READ = 3'b011, // Slave 1 only connect to Master 0,1
    // Write connections between interfaces
    // S_COUNT bits
    parameter M01_CONNECT_WRITE = 3'b011, // Slave 1 only connect to Master 0,1
    // Number of concurrent operations for each master interface
    parameter M01_ISSUE = 8,
    // Secure master (fail operations based on awprot/arprot)
    parameter M01_SECURE = 0, // Slave 1 is unsecure
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    parameter M02_BASE_ADDR = 0, // enable default mapping
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    parameter M02_ADDR_WIDTH = {M_REGIONS{32'd24}},
    // Read connections between interfaces
    // S_COUNT bits
    parameter M02_CONNECT_READ = 3'b100, // Slave 2 only connect to Master 2
    // Write connections between interfaces
    // S_COUNT bits
    parameter M02_CONNECT_WRITE = 3'b100, // Slave 2 only connect to Master 2
    // Number of concurrent operations for each master interface
    parameter M02_ISSUE = 8,
    // Secure master (fail operations based on awprot/arprot)
    parameter M02_SECURE = 1,
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    parameter M03_BASE_ADDR = 0,
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    parameter M03_ADDR_WIDTH = {M_REGIONS{32'd24}},
    // Read connections between interfaces
    // S_COUNT bits
    parameter M03_CONNECT_READ = 3'b011,
    // Write connections between interfaces
    // S_COUNT bits
    parameter M03_CONNECT_WRITE = 3'b011,
    // Number of concurrent operations for each master interface
    parameter M03_ISSUE = 8,
    // Secure master (fail operations based on awprot/arprot)
    parameter M03_SECURE = 0,
    // Slave interface AW channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_AW_REG_TYPE = 0,
    // Slave interface W channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_W_REG_TYPE = 0,
    // Slave interface B channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_B_REG_TYPE = 1,
    // Slave interface AR channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_AR_REG_TYPE = 0,
    // Slave interface R channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_R_REG_TYPE = 2,
    // Slave interface AW channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_AW_REG_TYPE = 0,
    // Slave interface W channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_W_REG_TYPE = 0,
    // Slave interface B channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_B_REG_TYPE = 1,
    // Slave interface AR channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_AR_REG_TYPE = 0,
    // Slave interface R channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_R_REG_TYPE = 2,
    // Slave interface AW channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S02_AW_REG_TYPE = 0,
    // Slave interface W channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S02_W_REG_TYPE = 0,
    // Slave interface B channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S02_B_REG_TYPE = 1,
    // Slave interface AR channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S02_AR_REG_TYPE = 0,
    // Slave interface R channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S02_R_REG_TYPE = 2,
    // Master interface AW channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_AW_REG_TYPE = 1,
    // Master interface W channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_W_REG_TYPE = 2,
    // Master interface B channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_B_REG_TYPE = 0,
    // Master interface AR channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_AR_REG_TYPE = 1,
    // Master interface R channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_R_REG_TYPE = 0,
    // Master interface AW channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_AW_REG_TYPE = 1,
    // Master interface W channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_W_REG_TYPE = 2,
    // Master interface B channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_B_REG_TYPE = 0,
    // Master interface AR channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_AR_REG_TYPE = 1,
    // Master interface R channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_R_REG_TYPE = 0,
    // Master interface AW channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_AW_REG_TYPE = 1,
    // Master interface W channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_W_REG_TYPE = 2,
    // Master interface B channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_B_REG_TYPE = 0,
    // Master interface AR channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_AR_REG_TYPE = 1,
    // Master interface R channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_R_REG_TYPE = 0,
    // Master interface AW channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_AW_REG_TYPE = 1,
    // Master interface W channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_W_REG_TYPE = 2,
    // Master interface B channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_B_REG_TYPE = 0,
    // Master interface AR channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_AR_REG_TYPE = 1,
    // Master interface R channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_R_REG_TYPE = 0
)(
    
    input  wire                     clk,
    input  wire                     rst,

    //s00
    input  wire [M_ID_WIDTH-1:0]    s00_axi_awid,
    input  wire [ADDR_WIDTH-1:0]    s00_axi_awaddr,
    input  wire [7:0]               s00_axi_awlen,
    input  wire [2:0]               s00_axi_awsize,
    input  wire [1:0]               s00_axi_awburst,
    input  wire                     s00_axi_awlock,
    input  wire [3:0]               s00_axi_awcache,
    input  wire [2:0]               s00_axi_awprot,
    input  wire [3:0]               s00_axi_awqos,
    input  wire [3:0]               s00_axi_awregion,
    input  wire [AWUSER_WIDTH-1:0]  s00_axi_awuser,
    input  wire                     s00_axi_awvalid,
    output wire                     s00_axi_awready,
    input  wire [DATA_WIDTH-1:0]    s00_axi_wdata,
    input  wire [STRB_WIDTH-1:0]    s00_axi_wstrb,
    input  wire                     s00_axi_wlast,
    input  wire [WUSER_WIDTH-1:0]   s00_axi_wuser,
    input  wire                     s00_axi_wvalid,
    output wire                     s00_axi_wready,
    output wire [M_ID_WIDTH-1:0]    s00_axi_bid,
    output wire [1:0]               s00_axi_bresp,
    output wire [BUSER_WIDTH-1:0]   s00_axi_buser,
    output wire                     s00_axi_bvalid,
    input  wire                     s00_axi_bready,
    input  wire [M_ID_WIDTH-1:0]    s00_axi_arid,
    input  wire [ADDR_WIDTH-1:0]    s00_axi_araddr,
    input  wire [7:0]               s00_axi_arlen,
    input  wire [2:0]               s00_axi_arsize,
    input  wire [1:0]               s00_axi_arburst,
    input  wire                     s00_axi_arlock,
    input  wire [3:0]               s00_axi_arcache,
    input  wire [2:0]               s00_axi_arprot,
    input  wire [3:0]               s00_axi_arqos,
    input  wire [3:0]               s00_axi_arregion,
    input  wire [ARUSER_WIDTH-1:0]  s00_axi_aruser,
    input  wire                     s00_axi_arvalid,
    output wire                     s00_axi_arready,
    output wire [M_ID_WIDTH-1:0]    s00_axi_rid,
    output wire [DATA_WIDTH-1:0]    s00_axi_rdata,
    output wire [1:0]               s00_axi_rresp,
    output wire                     s00_axi_rlast,
    output wire [RUSER_WIDTH-1:0]   s00_axi_ruser,
    output wire                     s00_axi_rvalid,
    input  wire                     s00_axi_rready,


    //s01
    input  wire [M_ID_WIDTH-1:0]    s01_axi_awid,
    input  wire [ADDR_WIDTH-1:0]    s01_axi_awaddr,
    input  wire [7:0]               s01_axi_awlen,
    input  wire [2:0]               s01_axi_awsize,
    input  wire [1:0]               s01_axi_awburst,
    input  wire                     s01_axi_awlock,
    input  wire [3:0]               s01_axi_awcache,
    input  wire [2:0]               s01_axi_awprot,
    input  wire [3:0]               s01_axi_awqos,
    input  wire [3:0]               s01_axi_awregion,
    input  wire [AWUSER_WIDTH-1:0]  s01_axi_awuser,
    input  wire                     s01_axi_awvalid,
    output wire                     s01_axi_awready,
    input  wire [DATA_WIDTH-1:0]    s01_axi_wdata,
    input  wire [STRB_WIDTH-1:0]    s01_axi_wstrb,
    input  wire                     s01_axi_wlast,
    input  wire [WUSER_WIDTH-1:0]   s01_axi_wuser,
    input  wire                     s01_axi_wvalid,
    output wire                     s01_axi_wready,
    output wire [M_ID_WIDTH-1:0]    s01_axi_bid,
    output wire [1:0]               s01_axi_bresp,
    output wire [BUSER_WIDTH-1:0]   s01_axi_buser,
    output wire                     s01_axi_bvalid,
    input  wire                     s01_axi_bready,
    input  wire [M_ID_WIDTH-1:0]    s01_axi_arid,
    input  wire [ADDR_WIDTH-1:0]    s01_axi_araddr,
    input  wire [7:0]               s01_axi_arlen,
    input  wire [2:0]               s01_axi_arsize,
    input  wire [1:0]               s01_axi_arburst,
    input  wire                     s01_axi_arlock,
    input  wire [3:0]               s01_axi_arcache,
    input  wire [2:0]               s01_axi_arprot,
    input  wire [3:0]               s01_axi_arqos,
    input  wire [3:0]               s01_axi_arregion,
    input  wire [ARUSER_WIDTH-1:0]  s01_axi_aruser,
    input  wire                     s01_axi_arvalid,
    output wire                     s01_axi_arready,
    output wire [M_ID_WIDTH-1:0]    s01_axi_rid,
    output wire [DATA_WIDTH-1:0]    s01_axi_rdata,
    output wire [1:0]               s01_axi_rresp,
    output wire                     s01_axi_rlast,
    output wire [RUSER_WIDTH-1:0]   s01_axi_ruser,
    output wire                     s01_axi_rvalid,
    input  wire                     s01_axi_rready,

    
    //s02
    input  wire [M_ID_WIDTH-1:0]    s02_axi_awid,
    input  wire [ADDR_WIDTH-1:0]    s02_axi_awaddr,
    input  wire [7:0]               s02_axi_awlen,
    input  wire [2:0]               s02_axi_awsize,
    input  wire [1:0]               s02_axi_awburst,
    input  wire                     s02_axi_awlock,
    input  wire [3:0]               s02_axi_awcache,
    input  wire [2:0]               s02_axi_awprot,
    input  wire [3:0]               s02_axi_awqos,
    input  wire [3:0]               s02_axi_awregion,
    input  wire [AWUSER_WIDTH-1:0]  s02_axi_awuser,
    input  wire                     s02_axi_awvalid,
    output wire                     s02_axi_awready,
    input  wire [DATA_WIDTH-1:0]    s02_axi_wdata,
    input  wire [STRB_WIDTH-1:0]    s02_axi_wstrb,
    input  wire                     s02_axi_wlast,
    input  wire [WUSER_WIDTH-1:0]   s02_axi_wuser,
    input  wire                     s02_axi_wvalid,
    output wire                     s02_axi_wready,
    output wire [M_ID_WIDTH-1:0]    s02_axi_bid,
    output wire [1:0]               s02_axi_bresp,
    output wire [BUSER_WIDTH-1:0]   s02_axi_buser,
    output wire                     s02_axi_bvalid,
    input  wire                     s02_axi_bready,
    input  wire [M_ID_WIDTH-1:0]    s02_axi_arid,
    input  wire [ADDR_WIDTH-1:0]    s02_axi_araddr,
    input  wire [7:0]               s02_axi_arlen,
    input  wire [2:0]               s02_axi_arsize,
    input  wire [1:0]               s02_axi_arburst,
    input  wire                     s02_axi_arlock,
    input  wire [3:0]               s02_axi_arcache,
    input  wire [2:0]               s02_axi_arprot,
    input  wire [3:0]               s02_axi_arqos,
    input  wire [3:0]               s02_axi_arregion,
    input  wire [ARUSER_WIDTH-1:0]  s02_axi_aruser,
    input  wire                     s02_axi_arvalid,
    output wire                     s02_axi_arready,
    output wire [M_ID_WIDTH-1:0]    s02_axi_rid,
    output wire [DATA_WIDTH-1:0]    s02_axi_rdata,
    output wire [1:0]               s02_axi_rresp,
    output wire                     s02_axi_rlast,
    output wire [RUSER_WIDTH-1:0]   s02_axi_ruser,
    output wire                     s02_axi_rvalid,
    input  wire                     s02_axi_rready,

    //m00
    output wire [M_ID_WIDTH-1:0]    m00_axi_awid,
    output wire [ADDR_WIDTH-1:0]    m00_axi_awaddr,
    output wire [7:0]               m00_axi_awlen,
    output wire [2:0]               m00_axi_awsize,
    output wire [1:0]               m00_axi_awburst,
    output wire                     m00_axi_awlock,
    output wire [3:0]               m00_axi_awcache,
    output wire [2:0]               m00_axi_awprot,
    output wire [3:0]               m00_axi_awqos,
    output wire [3:0]               m00_axi_awregion,
    output wire [AWUSER_WIDTH-1:0]  m00_axi_awuser,
    output wire                     m00_axi_awvalid,
    input  wire                     m00_axi_awready,
    output wire [DATA_WIDTH-1:0]    m00_axi_wdata,
    output wire [STRB_WIDTH-1:0]    m00_axi_wstrb,
    output wire                     m00_axi_wlast,
    output wire [WUSER_WIDTH-1:0]   m00_axi_wuser,
    output wire                     m00_axi_wvalid,
    input  wire                     m00_axi_wready,
    input  wire [M_ID_WIDTH-1:0]    m00_axi_bid,
    input  wire [1:0]               m00_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]   m00_axi_buser,
    input  wire                     m00_axi_bvalid,
    output wire                     m00_axi_bready,
    output wire [M_ID_WIDTH-1:0]    m00_axi_arid,
    output wire [ADDR_WIDTH-1:0]    m00_axi_araddr,
    output wire [7:0]               m00_axi_arlen,
    output wire [2:0]               m00_axi_arsize,
    output wire [1:0]               m00_axi_arburst,
    output wire                     m00_axi_arlock,
    output wire [3:0]               m00_axi_arcache,
    output wire [2:0]               m00_axi_arprot,
    output wire [3:0]               m00_axi_arqos,
    output wire [3:0]               m00_axi_arregion,
    output wire [ARUSER_WIDTH-1:0]  m00_axi_aruser,
    output wire                     m00_axi_arvalid,
    input  wire                     m00_axi_arready,
    input  wire [M_ID_WIDTH-1:0]    m00_axi_rid,
    input  wire [DATA_WIDTH-1:0]    m00_axi_rdata,
    input  wire [1:0]               m00_axi_rresp,
    input  wire                     m00_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]   m00_axi_ruser,
    input  wire                     m00_axi_rvalid,
    output wire                     m00_axi_rready


);
    
    genvar i;

    reg [5:0] err_signal;
    reg [5:0] err_bit_index;
    reg [2:0] err_axi_connector;

    reg [5:0] err_signal_next;
    reg [5:0] err_bit_index_next;
    reg [2:0] err_axi_connector_next;

//gencode start here
    wire [M_ID_WIDTH-1:0] s_axi_awid_err_flag;
    wire [M_ID_WIDTH-1:0] s_axi_awid_err_d0;
    wire [M_ID_WIDTH-1:0] s_axi_awid_err_d1;
    wire [M_ID_WIDTH-1:0] s_axi_awid_err_d2;
    wire [2:0] s_axi_awid_err_dx;
    wire [5:0] s_axi_awid_err_bit_index;

    wire [ADDR_WIDTH-1:0] s_axi_awaddr_err_flag;
    wire [ADDR_WIDTH-1:0] s_axi_awaddr_err_d0;
    wire [ADDR_WIDTH-1:0] s_axi_awaddr_err_d1;
    wire [ADDR_WIDTH-1:0] s_axi_awaddr_err_d2;
    wire [2:0] s_axi_awaddr_err_dx;
    wire [5:0] s_axi_awaddr_err_bit_index;

    wire [7:0] s_axi_awlen_err_flag;
    wire [7:0] s_axi_awlen_err_d0;
    wire [7:0] s_axi_awlen_err_d1;
    wire [7:0] s_axi_awlen_err_d2;
    wire [2:0] s_axi_awlen_err_dx;
    wire [5:0] s_axi_awlen_err_bit_index;

    wire [2:0] s_axi_awsize_err_flag;
    wire [2:0] s_axi_awsize_err_d0;
    wire [2:0] s_axi_awsize_err_d1;
    wire [2:0] s_axi_awsize_err_d2;
    wire [2:0] s_axi_awsize_err_dx;
    wire [5:0] s_axi_awsize_err_bit_index;

    wire [1:0] s_axi_awburst_err_flag;
    wire [1:0] s_axi_awburst_err_d0;
    wire [1:0] s_axi_awburst_err_d1;
    wire [1:0] s_axi_awburst_err_d2;
    wire [2:0] s_axi_awburst_err_dx;
    wire [5:0] s_axi_awburst_err_bit_index;

    wire s_axi_awlock_err_flag;
    wire s_axi_awlock_err_d0;
    wire s_axi_awlock_err_d1;
    wire s_axi_awlock_err_d2;
    wire [2:0] s_axi_awlock_err_dx;
    wire [5:0] s_axi_awlock_err_bit_index;

    wire [3:0] s_axi_awcache_err_flag;
    wire [3:0] s_axi_awcache_err_d0;
    wire [3:0] s_axi_awcache_err_d1;
    wire [3:0] s_axi_awcache_err_d2;
    wire [2:0] s_axi_awcache_err_dx;
    wire [5:0] s_axi_awcache_err_bit_index;

    wire [2:0] s_axi_awprot_err_flag;
    wire [2:0] s_axi_awprot_err_d0;
    wire [2:0] s_axi_awprot_err_d1;
    wire [2:0] s_axi_awprot_err_d2;
    wire [2:0] s_axi_awprot_err_dx;
    wire [5:0] s_axi_awprot_err_bit_index;

    wire [3:0] s_axi_awqos_err_flag;
    wire [3:0] s_axi_awqos_err_d0;
    wire [3:0] s_axi_awqos_err_d1;
    wire [3:0] s_axi_awqos_err_d2;
    wire [2:0] s_axi_awqos_err_dx;
    wire [5:0] s_axi_awqos_err_bit_index;

    wire [3:0] s_axi_awregion_err_flag;
    wire [3:0] s_axi_awregion_err_d0;
    wire [3:0] s_axi_awregion_err_d1;
    wire [3:0] s_axi_awregion_err_d2;
    wire [2:0] s_axi_awregion_err_dx;
    wire [5:0] s_axi_awregion_err_bit_index;

    wire [AWUSER_WIDTH-1:0] s_axi_awuser_err_flag;
    wire [AWUSER_WIDTH-1:0] s_axi_awuser_err_d0;
    wire [AWUSER_WIDTH-1:0] s_axi_awuser_err_d1;
    wire [AWUSER_WIDTH-1:0] s_axi_awuser_err_d2;
    wire [2:0] s_axi_awuser_err_dx;
    wire [5:0] s_axi_awuser_err_bit_index;

    wire s_axi_awvalid_err_flag;
    wire s_axi_awvalid_err_d0;
    wire s_axi_awvalid_err_d1;
    wire s_axi_awvalid_err_d2;
    wire [2:0] s_axi_awvalid_err_dx;
    wire [5:0] s_axi_awvalid_err_bit_index;

    wire [DATA_WIDTH-1:0] s_axi_wdata_err_flag;
    wire [DATA_WIDTH-1:0] s_axi_wdata_err_d0;
    wire [DATA_WIDTH-1:0] s_axi_wdata_err_d1;
    wire [DATA_WIDTH-1:0] s_axi_wdata_err_d2;
    wire [2:0] s_axi_wdata_err_dx;
    wire [5:0] s_axi_wdata_err_bit_index;

    wire [STRB_WIDTH-1:0] s_axi_wstrb_err_flag;
    wire [STRB_WIDTH-1:0] s_axi_wstrb_err_d0;
    wire [STRB_WIDTH-1:0] s_axi_wstrb_err_d1;
    wire [STRB_WIDTH-1:0] s_axi_wstrb_err_d2;
    wire [2:0] s_axi_wstrb_err_dx;
    wire [5:0] s_axi_wstrb_err_bit_index;

    wire s_axi_wlast_err_flag;
    wire s_axi_wlast_err_d0;
    wire s_axi_wlast_err_d1;
    wire s_axi_wlast_err_d2;
    wire [2:0] s_axi_wlast_err_dx;
    wire [5:0] s_axi_wlast_err_bit_index;

    wire [WUSER_WIDTH-1:0] s_axi_wuser_err_flag;
    wire [WUSER_WIDTH-1:0] s_axi_wuser_err_d0;
    wire [WUSER_WIDTH-1:0] s_axi_wuser_err_d1;
    wire [WUSER_WIDTH-1:0] s_axi_wuser_err_d2;
    wire [2:0] s_axi_wuser_err_dx;
    wire [5:0] s_axi_wuser_err_bit_index;

    wire s_axi_wvalid_err_flag;
    wire s_axi_wvalid_err_d0;
    wire s_axi_wvalid_err_d1;
    wire s_axi_wvalid_err_d2;
    wire [2:0] s_axi_wvalid_err_dx;
    wire [5:0] s_axi_wvalid_err_bit_index;

    wire s_axi_bready_err_flag;
    wire s_axi_bready_err_d0;
    wire s_axi_bready_err_d1;
    wire s_axi_bready_err_d2;
    wire [2:0] s_axi_bready_err_dx;
    wire [5:0] s_axi_bready_err_bit_index;

    wire [M_ID_WIDTH-1:0] s_axi_arid_err_flag;
    wire [M_ID_WIDTH-1:0] s_axi_arid_err_d0;
    wire [M_ID_WIDTH-1:0] s_axi_arid_err_d1;
    wire [M_ID_WIDTH-1:0] s_axi_arid_err_d2;
    wire [2:0] s_axi_arid_err_dx;
    wire [5:0] s_axi_arid_err_bit_index;

    wire [ADDR_WIDTH-1:0] s_axi_araddr_err_flag;
    wire [ADDR_WIDTH-1:0] s_axi_araddr_err_d0;
    wire [ADDR_WIDTH-1:0] s_axi_araddr_err_d1;
    wire [ADDR_WIDTH-1:0] s_axi_araddr_err_d2;
    wire [2:0] s_axi_araddr_err_dx;
    wire [5:0] s_axi_araddr_err_bit_index;

    wire [7:0] s_axi_arlen_err_flag;
    wire [7:0] s_axi_arlen_err_d0;
    wire [7:0] s_axi_arlen_err_d1;
    wire [7:0] s_axi_arlen_err_d2;
    wire [2:0] s_axi_arlen_err_dx;
    wire [5:0] s_axi_arlen_err_bit_index;

    wire [2:0] s_axi_arsize_err_flag;
    wire [2:0] s_axi_arsize_err_d0;
    wire [2:0] s_axi_arsize_err_d1;
    wire [2:0] s_axi_arsize_err_d2;
    wire [2:0] s_axi_arsize_err_dx;
    wire [5:0] s_axi_arsize_err_bit_index;

    wire [1:0] s_axi_arburst_err_flag;
    wire [1:0] s_axi_arburst_err_d0;
    wire [1:0] s_axi_arburst_err_d1;
    wire [1:0] s_axi_arburst_err_d2;
    wire [2:0] s_axi_arburst_err_dx;
    wire [5:0] s_axi_arburst_err_bit_index;

    wire s_axi_arlock_err_flag;
    wire s_axi_arlock_err_d0;
    wire s_axi_arlock_err_d1;
    wire s_axi_arlock_err_d2;
    wire [2:0] s_axi_arlock_err_dx;
    wire [5:0] s_axi_arlock_err_bit_index;

    wire [3:0] s_axi_arcache_err_flag;
    wire [3:0] s_axi_arcache_err_d0;
    wire [3:0] s_axi_arcache_err_d1;
    wire [3:0] s_axi_arcache_err_d2;
    wire [2:0] s_axi_arcache_err_dx;
    wire [5:0] s_axi_arcache_err_bit_index;

    wire [2:0] s_axi_arprot_err_flag;
    wire [2:0] s_axi_arprot_err_d0;
    wire [2:0] s_axi_arprot_err_d1;
    wire [2:0] s_axi_arprot_err_d2;
    wire [2:0] s_axi_arprot_err_dx;
    wire [5:0] s_axi_arprot_err_bit_index;

    wire [3:0] s_axi_arqos_err_flag;
    wire [3:0] s_axi_arqos_err_d0;
    wire [3:0] s_axi_arqos_err_d1;
    wire [3:0] s_axi_arqos_err_d2;
    wire [2:0] s_axi_arqos_err_dx;
    wire [5:0] s_axi_arqos_err_bit_index;

    wire [3:0] s_axi_arregion_err_flag;
    wire [3:0] s_axi_arregion_err_d0;
    wire [3:0] s_axi_arregion_err_d1;
    wire [3:0] s_axi_arregion_err_d2;
    wire [2:0] s_axi_arregion_err_dx;
    wire [5:0] s_axi_arregion_err_bit_index;

    wire [ARUSER_WIDTH-1:0] s_axi_aruser_err_flag;
    wire [ARUSER_WIDTH-1:0] s_axi_aruser_err_d0;
    wire [ARUSER_WIDTH-1:0] s_axi_aruser_err_d1;
    wire [ARUSER_WIDTH-1:0] s_axi_aruser_err_d2;
    wire [2:0] s_axi_aruser_err_dx;
    wire [5:0] s_axi_aruser_err_bit_index;

    wire s_axi_arvalid_err_flag;
    wire s_axi_arvalid_err_d0;
    wire s_axi_arvalid_err_d1;
    wire s_axi_arvalid_err_d2;
    wire [2:0] s_axi_arvalid_err_dx;
    wire [5:0] s_axi_arvalid_err_bit_index;

    wire s_axi_rready_err_flag;
    wire s_axi_rready_err_d0;
    wire s_axi_rready_err_d1;
    wire s_axi_rready_err_d2;
    wire [2:0] s_axi_rready_err_dx;
    wire [5:0] s_axi_rready_err_bit_index;

    for(i=0; i<M_ID_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_awid (
            .d0(s00_axi_awid[i]),
            .d1(s01_axi_awid[i]),
            .d2(s02_axi_awid[i]),
            .d_out(m00_axi_awid[i]),
            .err_flag(s_axi_awid_err_flag[i]),
            .err_d0(s_axi_awid_err_d0[i]),
            .err_d1(s_axi_awid_err_d1[i]),
            .err_d2(s_axi_awid_err_d2[i])
        );
    end

    assign s_axi_awid_err_dx = { |s_axi_awid_err_d2, |s_axi_awid_err_d1, |s_axi_awid_err_d0 };
    assign s_axi_awid_err_bit_index = encode64_6(s_axi_awid_err_flag);

    for(i=0; i<ADDR_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_awaddr (
            .d0(s00_axi_awaddr[i]),
            .d1(s01_axi_awaddr[i]),
            .d2(s02_axi_awaddr[i]),
            .d_out(m00_axi_awaddr[i]),
            .err_flag(s_axi_awaddr_err_flag[i]),
            .err_d0(s_axi_awaddr_err_d0[i]),
            .err_d1(s_axi_awaddr_err_d1[i]),
            .err_d2(s_axi_awaddr_err_d2[i])
        );
    end

    assign s_axi_awaddr_err_dx = { |s_axi_awaddr_err_d2, |s_axi_awaddr_err_d1, |s_axi_awaddr_err_d0 };
    assign s_axi_awaddr_err_bit_index = encode64_6(s_axi_awaddr_err_flag);

    for(i=0; i<7+1; i=i+1) begin
        axi_tmr_voter_unit u_awlen (
            .d0(s00_axi_awlen[i]),
            .d1(s01_axi_awlen[i]),
            .d2(s02_axi_awlen[i]),
            .d_out(m00_axi_awlen[i]),
            .err_flag(s_axi_awlen_err_flag[i]),
            .err_d0(s_axi_awlen_err_d0[i]),
            .err_d1(s_axi_awlen_err_d1[i]),
            .err_d2(s_axi_awlen_err_d2[i])
        );
    end

    assign s_axi_awlen_err_dx = { |s_axi_awlen_err_d2, |s_axi_awlen_err_d1, |s_axi_awlen_err_d0 };
    assign s_axi_awlen_err_bit_index = encode64_6(s_axi_awlen_err_flag);

    for(i=0; i<2+1; i=i+1) begin
        axi_tmr_voter_unit u_awsize (
            .d0(s00_axi_awsize[i]),
            .d1(s01_axi_awsize[i]),
            .d2(s02_axi_awsize[i]),
            .d_out(m00_axi_awsize[i]),
            .err_flag(s_axi_awsize_err_flag[i]),
            .err_d0(s_axi_awsize_err_d0[i]),
            .err_d1(s_axi_awsize_err_d1[i]),
            .err_d2(s_axi_awsize_err_d2[i])
        );
    end

    assign s_axi_awsize_err_dx = { |s_axi_awsize_err_d2, |s_axi_awsize_err_d1, |s_axi_awsize_err_d0 };
    assign s_axi_awsize_err_bit_index = encode64_6(s_axi_awsize_err_flag);

    for(i=0; i<1+1; i=i+1) begin
        axi_tmr_voter_unit u_awburst (
            .d0(s00_axi_awburst[i]),
            .d1(s01_axi_awburst[i]),
            .d2(s02_axi_awburst[i]),
            .d_out(m00_axi_awburst[i]),
            .err_flag(s_axi_awburst_err_flag[i]),
            .err_d0(s_axi_awburst_err_d0[i]),
            .err_d1(s_axi_awburst_err_d1[i]),
            .err_d2(s_axi_awburst_err_d2[i])
        );
    end

    assign s_axi_awburst_err_dx = { |s_axi_awburst_err_d2, |s_axi_awburst_err_d1, |s_axi_awburst_err_d0 };
    assign s_axi_awburst_err_bit_index = encode64_6(s_axi_awburst_err_flag);

    axi_tmr_voter_unit u_awlock (
        .d0(s00_axi_awlock),
        .d1(s01_axi_awlock),
        .d2(s02_axi_awlock),
        .d_out(m00_axi_awlock),
        .err_flag(s_axi_awlock_err_flag),
        .err_d0(s_axi_awlock_err_d0),
        .err_d1(s_axi_awlock_err_d1),
        .err_d2(s_axi_awlock_err_d2)
    );

    assign s_axi_awlock_err_dx = { s_axi_awlock_err_d2, s_axi_awlock_err_d1, s_axi_awlock_err_d0 };
    assign s_axi_awlock_err_bit_index = s_axi_awlock_err_flag;

    for(i=0; i<3+1; i=i+1) begin
        axi_tmr_voter_unit u_awcache (
            .d0(s00_axi_awcache[i]),
            .d1(s01_axi_awcache[i]),
            .d2(s02_axi_awcache[i]),
            .d_out(m00_axi_awcache[i]),
            .err_flag(s_axi_awcache_err_flag[i]),
            .err_d0(s_axi_awcache_err_d0[i]),
            .err_d1(s_axi_awcache_err_d1[i]),
            .err_d2(s_axi_awcache_err_d2[i])
        );
    end

    assign s_axi_awcache_err_dx = { |s_axi_awcache_err_d2, |s_axi_awcache_err_d1, |s_axi_awcache_err_d0 };
    assign s_axi_awcache_err_bit_index = encode64_6(s_axi_awcache_err_flag);

    for(i=0; i<2+1; i=i+1) begin
        axi_tmr_voter_unit u_awprot (
            .d0(s00_axi_awprot[i]),
            .d1(s01_axi_awprot[i]),
            .d2(s02_axi_awprot[i]),
            .d_out(m00_axi_awprot[i]),
            .err_flag(s_axi_awprot_err_flag[i]),
            .err_d0(s_axi_awprot_err_d0[i]),
            .err_d1(s_axi_awprot_err_d1[i]),
            .err_d2(s_axi_awprot_err_d2[i])
        );
    end

    assign s_axi_awprot_err_dx = { |s_axi_awprot_err_d2, |s_axi_awprot_err_d1, |s_axi_awprot_err_d0 };
    assign s_axi_awprot_err_bit_index = encode64_6(s_axi_awprot_err_flag);

    for(i=0; i<3+1; i=i+1) begin
        axi_tmr_voter_unit u_awqos (
            .d0(s00_axi_awqos[i]),
            .d1(s01_axi_awqos[i]),
            .d2(s02_axi_awqos[i]),
            .d_out(m00_axi_awqos[i]),
            .err_flag(s_axi_awqos_err_flag[i]),
            .err_d0(s_axi_awqos_err_d0[i]),
            .err_d1(s_axi_awqos_err_d1[i]),
            .err_d2(s_axi_awqos_err_d2[i])
        );
    end

    assign s_axi_awqos_err_dx = { |s_axi_awqos_err_d2, |s_axi_awqos_err_d1, |s_axi_awqos_err_d0 };
    assign s_axi_awqos_err_bit_index = encode64_6(s_axi_awqos_err_flag);

    for(i=0; i<3+1; i=i+1) begin
        axi_tmr_voter_unit u_awregion (
            .d0(s00_axi_awregion[i]),
            .d1(s01_axi_awregion[i]),
            .d2(s02_axi_awregion[i]),
            .d_out(m00_axi_awregion[i]),
            .err_flag(s_axi_awregion_err_flag[i]),
            .err_d0(s_axi_awregion_err_d0[i]),
            .err_d1(s_axi_awregion_err_d1[i]),
            .err_d2(s_axi_awregion_err_d2[i])
        );
    end

    assign s_axi_awregion_err_dx = { |s_axi_awregion_err_d2, |s_axi_awregion_err_d1, |s_axi_awregion_err_d0 };
    assign s_axi_awregion_err_bit_index = encode64_6(s_axi_awregion_err_flag);

    for(i=0; i<AWUSER_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_awuser (
            .d0(s00_axi_awuser[i]),
            .d1(s01_axi_awuser[i]),
            .d2(s02_axi_awuser[i]),
            .d_out(m00_axi_awuser[i]),
            .err_flag(s_axi_awuser_err_flag[i]),
            .err_d0(s_axi_awuser_err_d0[i]),
            .err_d1(s_axi_awuser_err_d1[i]),
            .err_d2(s_axi_awuser_err_d2[i])
        );
    end

    assign s_axi_awuser_err_dx = { |s_axi_awuser_err_d2, |s_axi_awuser_err_d1, |s_axi_awuser_err_d0 };
    assign s_axi_awuser_err_bit_index = encode64_6(s_axi_awuser_err_flag);

    axi_tmr_voter_unit u_awvalid (
        .d0(s00_axi_awvalid),
        .d1(s01_axi_awvalid),
        .d2(s02_axi_awvalid),
        .d_out(m00_axi_awvalid),
        .err_flag(s_axi_awvalid_err_flag),
        .err_d0(s_axi_awvalid_err_d0),
        .err_d1(s_axi_awvalid_err_d1),
        .err_d2(s_axi_awvalid_err_d2)
    );

    assign s_axi_awvalid_err_dx = { s_axi_awvalid_err_d2, s_axi_awvalid_err_d1, s_axi_awvalid_err_d0 };
    assign s_axi_awvalid_err_bit_index = s_axi_awvalid_err_flag;

    assign s00_axi_awready = m00_axi_awready;
    assign s01_axi_awready = m00_axi_awready;
    assign s02_axi_awready = m00_axi_awready;

    for(i=0; i<DATA_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_wdata (
            .d0(s00_axi_wdata[i]),
            .d1(s01_axi_wdata[i]),
            .d2(s02_axi_wdata[i]),
            .d_out(m00_axi_wdata[i]),
            .err_flag(s_axi_wdata_err_flag[i]),
            .err_d0(s_axi_wdata_err_d0[i]),
            .err_d1(s_axi_wdata_err_d1[i]),
            .err_d2(s_axi_wdata_err_d2[i])
        );
    end

    assign s_axi_wdata_err_dx = { |s_axi_wdata_err_d2, |s_axi_wdata_err_d1, |s_axi_wdata_err_d0 };
    assign s_axi_wdata_err_bit_index = encode64_6(s_axi_wdata_err_flag);

    for(i=0; i<STRB_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_wstrb (
            .d0(s00_axi_wstrb[i]),
            .d1(s01_axi_wstrb[i]),
            .d2(s02_axi_wstrb[i]),
            .d_out(m00_axi_wstrb[i]),
            .err_flag(s_axi_wstrb_err_flag[i]),
            .err_d0(s_axi_wstrb_err_d0[i]),
            .err_d1(s_axi_wstrb_err_d1[i]),
            .err_d2(s_axi_wstrb_err_d2[i])
        );
    end

    assign s_axi_wstrb_err_dx = { |s_axi_wstrb_err_d2, |s_axi_wstrb_err_d1, |s_axi_wstrb_err_d0 };
    assign s_axi_wstrb_err_bit_index = encode64_6(s_axi_wstrb_err_flag);

    axi_tmr_voter_unit u_wlast (
        .d0(s00_axi_wlast),
        .d1(s01_axi_wlast),
        .d2(s02_axi_wlast),
        .d_out(m00_axi_wlast),
        .err_flag(s_axi_wlast_err_flag),
        .err_d0(s_axi_wlast_err_d0),
        .err_d1(s_axi_wlast_err_d1),
        .err_d2(s_axi_wlast_err_d2)
    );

    assign s_axi_wlast_err_dx = { s_axi_wlast_err_d2, s_axi_wlast_err_d1, s_axi_wlast_err_d0 };
    assign s_axi_wlast_err_bit_index = s_axi_wlast_err_flag;

    for(i=0; i<WUSER_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_wuser (
            .d0(s00_axi_wuser[i]),
            .d1(s01_axi_wuser[i]),
            .d2(s02_axi_wuser[i]),
            .d_out(m00_axi_wuser[i]),
            .err_flag(s_axi_wuser_err_flag[i]),
            .err_d0(s_axi_wuser_err_d0[i]),
            .err_d1(s_axi_wuser_err_d1[i]),
            .err_d2(s_axi_wuser_err_d2[i])
        );
    end

    assign s_axi_wuser_err_dx = { |s_axi_wuser_err_d2, |s_axi_wuser_err_d1, |s_axi_wuser_err_d0 };
    assign s_axi_wuser_err_bit_index = encode64_6(s_axi_wuser_err_flag);

    axi_tmr_voter_unit u_wvalid (
        .d0(s00_axi_wvalid),
        .d1(s01_axi_wvalid),
        .d2(s02_axi_wvalid),
        .d_out(m00_axi_wvalid),
        .err_flag(s_axi_wvalid_err_flag),
        .err_d0(s_axi_wvalid_err_d0),
        .err_d1(s_axi_wvalid_err_d1),
        .err_d2(s_axi_wvalid_err_d2)
    );

    assign s_axi_wvalid_err_dx = { s_axi_wvalid_err_d2, s_axi_wvalid_err_d1, s_axi_wvalid_err_d0 };
    assign s_axi_wvalid_err_bit_index = s_axi_wvalid_err_flag;

    assign s00_axi_wready = m00_axi_wready;
    assign s01_axi_wready = m00_axi_wready;
    assign s02_axi_wready = m00_axi_wready;

    assign s00_axi_bid = m00_axi_bid;
    assign s01_axi_bid = m00_axi_bid;
    assign s02_axi_bid = m00_axi_bid;

    assign s00_axi_bresp = m00_axi_bresp;
    assign s01_axi_bresp = m00_axi_bresp;
    assign s02_axi_bresp = m00_axi_bresp;

    assign s00_axi_buser = m00_axi_buser;
    assign s01_axi_buser = m00_axi_buser;
    assign s02_axi_buser = m00_axi_buser;

    assign s00_axi_bvalid = m00_axi_bvalid;
    assign s01_axi_bvalid = m00_axi_bvalid;
    assign s02_axi_bvalid = m00_axi_bvalid;

    axi_tmr_voter_unit u_bready (
        .d0(s00_axi_bready),
        .d1(s01_axi_bready),
        .d2(s02_axi_bready),
        .d_out(m00_axi_bready),
        .err_flag(s_axi_bready_err_flag),
        .err_d0(s_axi_bready_err_d0),
        .err_d1(s_axi_bready_err_d1),
        .err_d2(s_axi_bready_err_d2)
    );

    assign s_axi_bready_err_dx = { s_axi_bready_err_d2, s_axi_bready_err_d1, s_axi_bready_err_d0 };
    assign s_axi_bready_err_bit_index = s_axi_bready_err_flag;

    for(i=0; i<M_ID_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_arid (
            .d0(s00_axi_arid[i]),
            .d1(s01_axi_arid[i]),
            .d2(s02_axi_arid[i]),
            .d_out(m00_axi_arid[i]),
            .err_flag(s_axi_arid_err_flag[i]),
            .err_d0(s_axi_arid_err_d0[i]),
            .err_d1(s_axi_arid_err_d1[i]),
            .err_d2(s_axi_arid_err_d2[i])
        );
    end

    assign s_axi_arid_err_dx = { |s_axi_arid_err_d2, |s_axi_arid_err_d1, |s_axi_arid_err_d0 };
    assign s_axi_arid_err_bit_index = encode64_6(s_axi_arid_err_flag);

    for(i=0; i<ADDR_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_araddr (
            .d0(s00_axi_araddr[i]),
            .d1(s01_axi_araddr[i]),
            .d2(s02_axi_araddr[i]),
            .d_out(m00_axi_araddr[i]),
            .err_flag(s_axi_araddr_err_flag[i]),
            .err_d0(s_axi_araddr_err_d0[i]),
            .err_d1(s_axi_araddr_err_d1[i]),
            .err_d2(s_axi_araddr_err_d2[i])
        );
    end

    assign s_axi_araddr_err_dx = { |s_axi_araddr_err_d2, |s_axi_araddr_err_d1, |s_axi_araddr_err_d0 };
    assign s_axi_araddr_err_bit_index = encode64_6(s_axi_araddr_err_flag);

    for(i=0; i<7+1; i=i+1) begin
        axi_tmr_voter_unit u_arlen (
            .d0(s00_axi_arlen[i]),
            .d1(s01_axi_arlen[i]),
            .d2(s02_axi_arlen[i]),
            .d_out(m00_axi_arlen[i]),
            .err_flag(s_axi_arlen_err_flag[i]),
            .err_d0(s_axi_arlen_err_d0[i]),
            .err_d1(s_axi_arlen_err_d1[i]),
            .err_d2(s_axi_arlen_err_d2[i])
        );
    end

    assign s_axi_arlen_err_dx = { |s_axi_arlen_err_d2, |s_axi_arlen_err_d1, |s_axi_arlen_err_d0 };
    assign s_axi_arlen_err_bit_index = encode64_6(s_axi_arlen_err_flag);

    for(i=0; i<2+1; i=i+1) begin
        axi_tmr_voter_unit u_arsize (
            .d0(s00_axi_arsize[i]),
            .d1(s01_axi_arsize[i]),
            .d2(s02_axi_arsize[i]),
            .d_out(m00_axi_arsize[i]),
            .err_flag(s_axi_arsize_err_flag[i]),
            .err_d0(s_axi_arsize_err_d0[i]),
            .err_d1(s_axi_arsize_err_d1[i]),
            .err_d2(s_axi_arsize_err_d2[i])
        );
    end

    assign s_axi_arsize_err_dx = { |s_axi_arsize_err_d2, |s_axi_arsize_err_d1, |s_axi_arsize_err_d0 };
    assign s_axi_arsize_err_bit_index = encode64_6(s_axi_arsize_err_flag);

    for(i=0; i<1+1; i=i+1) begin
        axi_tmr_voter_unit u_arburst (
            .d0(s00_axi_arburst[i]),
            .d1(s01_axi_arburst[i]),
            .d2(s02_axi_arburst[i]),
            .d_out(m00_axi_arburst[i]),
            .err_flag(s_axi_arburst_err_flag[i]),
            .err_d0(s_axi_arburst_err_d0[i]),
            .err_d1(s_axi_arburst_err_d1[i]),
            .err_d2(s_axi_arburst_err_d2[i])
        );
    end

    assign s_axi_arburst_err_dx = { |s_axi_arburst_err_d2, |s_axi_arburst_err_d1, |s_axi_arburst_err_d0 };
    assign s_axi_arburst_err_bit_index = encode64_6(s_axi_arburst_err_flag);

    axi_tmr_voter_unit u_arlock (
        .d0(s00_axi_arlock),
        .d1(s01_axi_arlock),
        .d2(s02_axi_arlock),
        .d_out(m00_axi_arlock),
        .err_flag(s_axi_arlock_err_flag),
        .err_d0(s_axi_arlock_err_d0),
        .err_d1(s_axi_arlock_err_d1),
        .err_d2(s_axi_arlock_err_d2)
    );

    assign s_axi_arlock_err_dx = { s_axi_arlock_err_d2, s_axi_arlock_err_d1, s_axi_arlock_err_d0 };
    assign s_axi_arlock_err_bit_index = s_axi_arlock_err_flag;

    for(i=0; i<3+1; i=i+1) begin
        axi_tmr_voter_unit u_arcache (
            .d0(s00_axi_arcache[i]),
            .d1(s01_axi_arcache[i]),
            .d2(s02_axi_arcache[i]),
            .d_out(m00_axi_arcache[i]),
            .err_flag(s_axi_arcache_err_flag[i]),
            .err_d0(s_axi_arcache_err_d0[i]),
            .err_d1(s_axi_arcache_err_d1[i]),
            .err_d2(s_axi_arcache_err_d2[i])
        );
    end

    assign s_axi_arcache_err_dx = { |s_axi_arcache_err_d2, |s_axi_arcache_err_d1, |s_axi_arcache_err_d0 };
    assign s_axi_arcache_err_bit_index = encode64_6(s_axi_arcache_err_flag);

    for(i=0; i<2+1; i=i+1) begin
        axi_tmr_voter_unit u_arprot (
            .d0(s00_axi_arprot[i]),
            .d1(s01_axi_arprot[i]),
            .d2(s02_axi_arprot[i]),
            .d_out(m00_axi_arprot[i]),
            .err_flag(s_axi_arprot_err_flag[i]),
            .err_d0(s_axi_arprot_err_d0[i]),
            .err_d1(s_axi_arprot_err_d1[i]),
            .err_d2(s_axi_arprot_err_d2[i])
        );
    end

    assign s_axi_arprot_err_dx = { |s_axi_arprot_err_d2, |s_axi_arprot_err_d1, |s_axi_arprot_err_d0 };
    assign s_axi_arprot_err_bit_index = encode64_6(s_axi_arprot_err_flag);

    for(i=0; i<3+1; i=i+1) begin
        axi_tmr_voter_unit u_arqos (
            .d0(s00_axi_arqos[i]),
            .d1(s01_axi_arqos[i]),
            .d2(s02_axi_arqos[i]),
            .d_out(m00_axi_arqos[i]),
            .err_flag(s_axi_arqos_err_flag[i]),
            .err_d0(s_axi_arqos_err_d0[i]),
            .err_d1(s_axi_arqos_err_d1[i]),
            .err_d2(s_axi_arqos_err_d2[i])
        );
    end

    assign s_axi_arqos_err_dx = { |s_axi_arqos_err_d2, |s_axi_arqos_err_d1, |s_axi_arqos_err_d0 };
    assign s_axi_arqos_err_bit_index = encode64_6(s_axi_arqos_err_flag);

    for(i=0; i<3+1; i=i+1) begin
        axi_tmr_voter_unit u_arregion (
            .d0(s00_axi_arregion[i]),
            .d1(s01_axi_arregion[i]),
            .d2(s02_axi_arregion[i]),
            .d_out(m00_axi_arregion[i]),
            .err_flag(s_axi_arregion_err_flag[i]),
            .err_d0(s_axi_arregion_err_d0[i]),
            .err_d1(s_axi_arregion_err_d1[i]),
            .err_d2(s_axi_arregion_err_d2[i])
        );
    end

    assign s_axi_arregion_err_dx = { |s_axi_arregion_err_d2, |s_axi_arregion_err_d1, |s_axi_arregion_err_d0 };
    assign s_axi_arregion_err_bit_index = encode64_6(s_axi_arregion_err_flag);

    for(i=0; i<ARUSER_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_aruser (
            .d0(s00_axi_aruser[i]),
            .d1(s01_axi_aruser[i]),
            .d2(s02_axi_aruser[i]),
            .d_out(m00_axi_aruser[i]),
            .err_flag(s_axi_aruser_err_flag[i]),
            .err_d0(s_axi_aruser_err_d0[i]),
            .err_d1(s_axi_aruser_err_d1[i]),
            .err_d2(s_axi_aruser_err_d2[i])
        );
    end

    assign s_axi_aruser_err_dx = { |s_axi_aruser_err_d2, |s_axi_aruser_err_d1, |s_axi_aruser_err_d0 };
    assign s_axi_aruser_err_bit_index = encode64_6(s_axi_aruser_err_flag);

    axi_tmr_voter_unit u_arvalid (
        .d0(s00_axi_arvalid),
        .d1(s01_axi_arvalid),
        .d2(s02_axi_arvalid),
        .d_out(m00_axi_arvalid),
        .err_flag(s_axi_arvalid_err_flag),
        .err_d0(s_axi_arvalid_err_d0),
        .err_d1(s_axi_arvalid_err_d1),
        .err_d2(s_axi_arvalid_err_d2)
    );

    assign s_axi_arvalid_err_dx = { s_axi_arvalid_err_d2, s_axi_arvalid_err_d1, s_axi_arvalid_err_d0 };
    assign s_axi_arvalid_err_bit_index = s_axi_arvalid_err_flag;

    assign s00_axi_arready = m00_axi_arready;
    assign s01_axi_arready = m00_axi_arready;
    assign s02_axi_arready = m00_axi_arready;

    assign s00_axi_rid = m00_axi_rid;
    assign s01_axi_rid = m00_axi_rid;
    assign s02_axi_rid = m00_axi_rid;

    assign s00_axi_rdata = m00_axi_rdata;
    assign s01_axi_rdata = m00_axi_rdata;
    assign s02_axi_rdata = m00_axi_rdata;

    assign s00_axi_rresp = m00_axi_rresp;
    assign s01_axi_rresp = m00_axi_rresp;
    assign s02_axi_rresp = m00_axi_rresp;

    assign s00_axi_rlast = m00_axi_rlast;
    assign s01_axi_rlast = m00_axi_rlast;
    assign s02_axi_rlast = m00_axi_rlast;

    assign s00_axi_ruser = m00_axi_ruser;
    assign s01_axi_ruser = m00_axi_ruser;
    assign s02_axi_ruser = m00_axi_ruser;

    assign s00_axi_rvalid = m00_axi_rvalid;
    assign s01_axi_rvalid = m00_axi_rvalid;
    assign s02_axi_rvalid = m00_axi_rvalid;

    axi_tmr_voter_unit u_rready (
        .d0(s00_axi_rready),
        .d1(s01_axi_rready),
        .d2(s02_axi_rready),
        .d_out(m00_axi_rready),
        .err_flag(s_axi_rready_err_flag),
        .err_d0(s_axi_rready_err_d0),
        .err_d1(s_axi_rready_err_d1),
        .err_d2(s_axi_rready_err_d2)
    );

    assign s_axi_rready_err_dx = { s_axi_rready_err_d2, s_axi_rready_err_d1, s_axi_rready_err_d0 };
    assign s_axi_rready_err_bit_index = s_axi_rready_err_flag;

//gencode end

always@(*) begin
    if( |s_axi_awid_err_flag ) begin
        err_signal_next = `AXI_AWID_IDX;
        err_bit_index_next = s_axi_awid_err_bit_index;
        err_axi_connector_next = s_axi_awid_err_dx;
    end else if( |s_axi_awaddr_err_flag ) begin
        err_signal_next = `AXI_AWADDR_IDX;
        err_bit_index_next = s_axi_awaddr_err_bit_index;
        err_axi_connector_next = s_axi_awaddr_err_dx;
    end else if( |s_axi_awlen_err_flag ) begin
        err_signal_next = `AXI_AWLEN_IDX;
        err_bit_index_next = s_axi_awlen_err_bit_index;
        err_axi_connector_next = s_axi_awlen_err_dx;
    end else if( |s_axi_awsize_err_flag ) begin
        err_signal_next = `AXI_AWSIZE_IDX;
        err_bit_index_next = s_axi_awsize_err_bit_index;
        err_axi_connector_next = s_axi_awsize_err_dx;
    end else if( |s_axi_awburst_err_flag ) begin
        err_signal_next = `AXI_AWBURST_IDX;
        err_bit_index_next = s_axi_awburst_err_bit_index;
        err_axi_connector_next = s_axi_awburst_err_dx;
    end else if( |s_axi_awlock_err_flag ) begin
        err_signal_next = `AXI_AWLOCK_IDX;
        err_bit_index_next = s_axi_awlock_err_bit_index;
        err_axi_connector_next = s_axi_awlock_err_dx;
    end else if( |s_axi_awcache_err_flag ) begin
        err_signal_next = `AXI_AWCACHE_IDX;
        err_bit_index_next = s_axi_awcache_err_bit_index;
        err_axi_connector_next = s_axi_awcache_err_dx;
    end else if( |s_axi_awprot_err_flag ) begin
        err_signal_next = `AXI_AWPROT_IDX;
        err_bit_index_next = s_axi_awprot_err_bit_index;
        err_axi_connector_next = s_axi_awprot_err_dx;
    end else if( |s_axi_awqos_err_flag ) begin
        err_signal_next = `AXI_AWQOS_IDX;
        err_bit_index_next = s_axi_awqos_err_bit_index;
        err_axi_connector_next = s_axi_awqos_err_dx;
    end else if( |s_axi_awregion_err_flag ) begin
        err_signal_next = `AXI_AWREGION_IDX;
        err_bit_index_next = s_axi_awregion_err_bit_index;
        err_axi_connector_next = s_axi_awregion_err_dx;
    end else if( |s_axi_awuser_err_flag ) begin
        err_signal_next = `AXI_AWUSER_IDX;
        err_bit_index_next = s_axi_awuser_err_bit_index;
        err_axi_connector_next = s_axi_awuser_err_dx;
    end else if( |s_axi_awvalid_err_flag ) begin
        err_signal_next = `AXI_AWVALID_IDX;
        err_bit_index_next = s_axi_awvalid_err_bit_index;
        err_axi_connector_next = s_axi_awvalid_err_dx;
    end else if( |s_axi_wdata_err_flag ) begin
        err_signal_next = `AXI_WDATA_IDX;
        err_bit_index_next = s_axi_wdata_err_bit_index;
        err_axi_connector_next = s_axi_wdata_err_dx;
    end else if( |s_axi_wstrb_err_flag ) begin
        err_signal_next = `AXI_WSTRB_IDX;
        err_bit_index_next = s_axi_wstrb_err_bit_index;
        err_axi_connector_next = s_axi_wstrb_err_dx;
    end else if( |s_axi_wlast_err_flag ) begin
        err_signal_next = `AXI_WLAST_IDX;
        err_bit_index_next = s_axi_wlast_err_bit_index;
        err_axi_connector_next = s_axi_wlast_err_dx;
    end else if( |s_axi_wuser_err_flag ) begin
        err_signal_next = `AXI_WUSER_IDX;
        err_bit_index_next = s_axi_wuser_err_bit_index;
        err_axi_connector_next = s_axi_wuser_err_dx;
    end else if( |s_axi_wvalid_err_flag ) begin
        err_signal_next = `AXI_WVALID_IDX;
        err_bit_index_next = s_axi_wvalid_err_bit_index;
        err_axi_connector_next = s_axi_wvalid_err_dx;
    end else if( |s_axi_bready_err_flag ) begin
        err_signal_next = `AXI_BREADY_IDX;
        err_bit_index_next = s_axi_bready_err_bit_index;
        err_axi_connector_next = s_axi_bready_err_dx;
    end else if( |s_axi_arid_err_flag ) begin
        err_signal_next = `AXI_ARID_IDX;
        err_bit_index_next = s_axi_arid_err_bit_index;
        err_axi_connector_next = s_axi_arid_err_dx;
    end else if( |s_axi_araddr_err_flag ) begin
        err_signal_next = `AXI_ARADDR_IDX;
        err_bit_index_next = s_axi_araddr_err_bit_index;
        err_axi_connector_next = s_axi_araddr_err_dx;
    end else if( |s_axi_arlen_err_flag ) begin
        err_signal_next = `AXI_ARLEN_IDX;
        err_bit_index_next = s_axi_arlen_err_bit_index;
        err_axi_connector_next = s_axi_arlen_err_dx;
    end else if( |s_axi_arsize_err_flag ) begin
        err_signal_next = `AXI_ARSIZE_IDX;
        err_bit_index_next = s_axi_arsize_err_bit_index;
        err_axi_connector_next = s_axi_arsize_err_dx;
    end else if( |s_axi_arburst_err_flag ) begin
        err_signal_next = `AXI_ARBURST_IDX;
        err_bit_index_next = s_axi_arburst_err_bit_index;
        err_axi_connector_next = s_axi_arburst_err_dx;
    end else if( |s_axi_arlock_err_flag ) begin
        err_signal_next = `AXI_ARLOCK_IDX;
        err_bit_index_next = s_axi_arlock_err_bit_index;
        err_axi_connector_next = s_axi_arlock_err_dx;
    end else if( |s_axi_arcache_err_flag ) begin
        err_signal_next = `AXI_ARCACHE_IDX;
        err_bit_index_next = s_axi_arcache_err_bit_index;
        err_axi_connector_next = s_axi_arcache_err_dx;
    end else if( |s_axi_arprot_err_flag ) begin
        err_signal_next = `AXI_ARPROT_IDX;
        err_bit_index_next = s_axi_arprot_err_bit_index;
        err_axi_connector_next = s_axi_arprot_err_dx;
    end else if( |s_axi_arqos_err_flag ) begin
        err_signal_next = `AXI_ARQOS_IDX;
        err_bit_index_next = s_axi_arqos_err_bit_index;
        err_axi_connector_next = s_axi_arqos_err_dx;
    end else if( |s_axi_arregion_err_flag ) begin
        err_signal_next = `AXI_ARREGION_IDX;
        err_bit_index_next = s_axi_arregion_err_bit_index;
        err_axi_connector_next = s_axi_arregion_err_dx;
    end else if( |s_axi_aruser_err_flag ) begin
        err_signal_next = `AXI_ARUSER_IDX;
        err_bit_index_next = s_axi_aruser_err_bit_index;
        err_axi_connector_next = s_axi_aruser_err_dx;
    end else if( |s_axi_arvalid_err_flag ) begin
        err_signal_next = `AXI_ARVALID_IDX;
        err_bit_index_next = s_axi_arvalid_err_bit_index;
        err_axi_connector_next = s_axi_arvalid_err_dx;
    end else if( |s_axi_rready_err_flag ) begin
        err_signal_next = `AXI_RREADY_IDX;
        err_bit_index_next = s_axi_rready_err_bit_index;
        err_axi_connector_next = s_axi_rready_err_dx;
    end 
end

always@(posedge clk, posedge rst) begin
    if (rst) begin
        err_signal <= 0;
        err_bit_index <= 0;
        err_axi_connector <= 0;
    end else if ((err_signal == 0) && (err_signal_next != 0)) begin
        err_signal <= err_signal_next;
        err_bit_index <= err_bit_index_next;
        err_axi_connector <= err_axi_connector_next;
    end
end

//
function [5:0] encode64_6;
    input [63:0] value;
    begin
        value = value - 1;
        for (encode64_6=0; value > 0; encode64_6=encode64_6+1)
            value = value >> 1;
    end
endfunction

endmodule

`resetall
