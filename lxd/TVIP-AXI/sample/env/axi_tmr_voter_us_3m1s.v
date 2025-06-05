//
`resetall
`timescale 1ns / 1ps
`default_nettype none
`include "axi_tmr_signal_define.vh"

module axi_tmr_voter_us_3m1s #(
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
    input  wire [S_ID_WIDTH-1:0]    s00_axi_awid,
    input  wire [ADDR_WIDTH-1:0]    s00_axi_awaddr,
    input  wire [7:0]               s00_axi_awlen,
    input  wire [2:0]               s00_axi_awsize,
    input  wire [1:0]               s00_axi_awburst,
    input  wire                     s00_axi_awlock,
    input  wire [3:0]               s00_axi_awcache,
    input  wire [2:0]               s00_axi_awprot,
    input  wire [3:0]               s00_axi_awqos,
    input  wire [AWUSER_WIDTH-1:0]  s00_axi_awuser,
    input  wire                     s00_axi_awvalid,
    output wire                     s00_axi_awready,
    input  wire [DATA_WIDTH-1:0]    s00_axi_wdata,
    input  wire [STRB_WIDTH-1:0]    s00_axi_wstrb,
    input  wire                     s00_axi_wlast,
    input  wire [WUSER_WIDTH-1:0]   s00_axi_wuser,
    input  wire                     s00_axi_wvalid,
    output wire                     s00_axi_wready,
    output wire [S_ID_WIDTH-1:0]    s00_axi_bid,
    output wire [1:0]               s00_axi_bresp,
    output wire [BUSER_WIDTH-1:0]   s00_axi_buser,
    output wire                     s00_axi_bvalid,
    input  wire                     s00_axi_bready,
    input  wire [S_ID_WIDTH-1:0]    s00_axi_arid,
    input  wire [ADDR_WIDTH-1:0]    s00_axi_araddr,
    input  wire [7:0]               s00_axi_arlen,
    input  wire [2:0]               s00_axi_arsize,
    input  wire [1:0]               s00_axi_arburst,
    input  wire                     s00_axi_arlock,
    input  wire [3:0]               s00_axi_arcache,
    input  wire [2:0]               s00_axi_arprot,
    input  wire [3:0]               s00_axi_arqos,
    input  wire [ARUSER_WIDTH-1:0]  s00_axi_aruser,
    input  wire                     s00_axi_arvalid,
    output wire                     s00_axi_arready,
    output wire [S_ID_WIDTH-1:0]    s00_axi_rid,
    output wire [DATA_WIDTH-1:0]    s00_axi_rdata,
    output wire [1:0]               s00_axi_rresp,
    output wire                     s00_axi_rlast,
    output wire [RUSER_WIDTH-1:0]   s00_axi_ruser,
    output wire                     s00_axi_rvalid,
    input  wire                     s00_axi_rready,

    //m00
    output wire [S_ID_WIDTH-1:0]   m00_axi_awid,
    output wire [ADDR_WIDTH-1:0]   m00_axi_awaddr,
    output wire [7:0]              m00_axi_awlen,
    output wire [2:0]              m00_axi_awsize,
    output wire [1:0]              m00_axi_awburst,
    output wire                    m00_axi_awlock,
    output wire [3:0]              m00_axi_awcache,
    output wire [2:0]              m00_axi_awprot,
    output wire [3:0]              m00_axi_awqos,
    output wire [AWUSER_WIDTH-1:0] m00_axi_awuser,
    output wire                    m00_axi_awvalid,
    input  wire                    m00_axi_awready,
    output wire [DATA_WIDTH-1:0]   m00_axi_wdata,
    output wire [STRB_WIDTH-1:0]   m00_axi_wstrb,
    output wire                    m00_axi_wlast,
    output wire [WUSER_WIDTH-1:0]  m00_axi_wuser,
    output wire                    m00_axi_wvalid,
    input  wire                    m00_axi_wready,
    input  wire [S_ID_WIDTH-1:0]   m00_axi_bid,
    input  wire [1:0]              m00_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]  m00_axi_buser,
    input  wire                    m00_axi_bvalid,
    output wire                    m00_axi_bready,
    output wire [S_ID_WIDTH-1:0]   m00_axi_arid,
    output wire [ADDR_WIDTH-1:0]   m00_axi_araddr,
    output wire [7:0]              m00_axi_arlen,
    output wire [2:0]              m00_axi_arsize,
    output wire [1:0]              m00_axi_arburst,
    output wire                    m00_axi_arlock,
    output wire [3:0]              m00_axi_arcache,
    output wire [2:0]              m00_axi_arprot,
    output wire [3:0]              m00_axi_arqos,
    output wire [ARUSER_WIDTH-1:0] m00_axi_aruser,
    output wire                    m00_axi_arvalid,
    input  wire                    m00_axi_arready,
    input  wire [S_ID_WIDTH-1:0]   m00_axi_rid,
    input  wire [DATA_WIDTH-1:0]   m00_axi_rdata,
    input  wire [1:0]              m00_axi_rresp,
    input  wire                    m00_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]  m00_axi_ruser,
    input  wire                    m00_axi_rvalid,
    output wire                    m00_axi_rready,

    //m01
    output wire [S_ID_WIDTH-1:0]   m01_axi_awid,
    output wire [ADDR_WIDTH-1:0]   m01_axi_awaddr,
    output wire [7:0]              m01_axi_awlen,
    output wire [2:0]              m01_axi_awsize,
    output wire [1:0]              m01_axi_awburst,
    output wire                    m01_axi_awlock,
    output wire [3:0]              m01_axi_awcache,
    output wire [2:0]              m01_axi_awprot,
    output wire [3:0]              m01_axi_awqos,
    output wire [AWUSER_WIDTH-1:0] m01_axi_awuser,
    output wire                    m01_axi_awvalid,
    input  wire                    m01_axi_awready,
    output wire [DATA_WIDTH-1:0]   m01_axi_wdata,
    output wire [STRB_WIDTH-1:0]   m01_axi_wstrb,
    output wire                    m01_axi_wlast,
    output wire [WUSER_WIDTH-1:0]  m01_axi_wuser,
    output wire                    m01_axi_wvalid,
    input  wire                    m01_axi_wready,
    input  wire [S_ID_WIDTH-1:0]   m01_axi_bid,
    input  wire [1:0]              m01_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]  m01_axi_buser,
    input  wire                    m01_axi_bvalid,
    output wire                    m01_axi_bready,
    output wire [S_ID_WIDTH-1:0]   m01_axi_arid,
    output wire [ADDR_WIDTH-1:0]   m01_axi_araddr,
    output wire [7:0]              m01_axi_arlen,
    output wire [2:0]              m01_axi_arsize,
    output wire [1:0]              m01_axi_arburst,
    output wire                    m01_axi_arlock,
    output wire [3:0]              m01_axi_arcache,
    output wire [2:0]              m01_axi_arprot,
    output wire [3:0]              m01_axi_arqos,
    output wire [ARUSER_WIDTH-1:0] m01_axi_aruser,
    output wire                    m01_axi_arvalid,
    input  wire                    m01_axi_arready,
    input  wire [S_ID_WIDTH-1:0]   m01_axi_rid,
    input  wire [DATA_WIDTH-1:0]   m01_axi_rdata,
    input  wire [1:0]              m01_axi_rresp,
    input  wire                    m01_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]  m01_axi_ruser,
    input  wire                    m01_axi_rvalid,
    output wire                    m01_axi_rready,

    //m02
    output wire [S_ID_WIDTH-1:0]   m02_axi_awid,
    output wire [ADDR_WIDTH-1:0]   m02_axi_awaddr,
    output wire [7:0]              m02_axi_awlen,
    output wire [2:0]              m02_axi_awsize,
    output wire [1:0]              m02_axi_awburst,
    output wire                    m02_axi_awlock,
    output wire [3:0]              m02_axi_awcache,
    output wire [2:0]              m02_axi_awprot,
    output wire [3:0]              m02_axi_awqos,
    output wire [AWUSER_WIDTH-1:0] m02_axi_awuser,
    output wire                    m02_axi_awvalid,
    input  wire                    m02_axi_awready,
    output wire [DATA_WIDTH-1:0]   m02_axi_wdata,
    output wire [STRB_WIDTH-1:0]   m02_axi_wstrb,
    output wire                    m02_axi_wlast,
    output wire [WUSER_WIDTH-1:0]  m02_axi_wuser,
    output wire                    m02_axi_wvalid,
    input  wire                    m02_axi_wready,
    input  wire [S_ID_WIDTH-1:0]   m02_axi_bid,
    input  wire [1:0]              m02_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]  m02_axi_buser,
    input  wire                    m02_axi_bvalid,
    output wire                    m02_axi_bready,
    output wire [S_ID_WIDTH-1:0]   m02_axi_arid,
    output wire [ADDR_WIDTH-1:0]   m02_axi_araddr,
    output wire [7:0]              m02_axi_arlen,
    output wire [2:0]              m02_axi_arsize,
    output wire [1:0]              m02_axi_arburst,
    output wire                    m02_axi_arlock,
    output wire [3:0]              m02_axi_arcache,
    output wire [2:0]              m02_axi_arprot,
    output wire [3:0]              m02_axi_arqos,
    output wire [ARUSER_WIDTH-1:0] m02_axi_aruser,
    output wire                    m02_axi_arvalid,
    input  wire                    m02_axi_arready,
    input  wire [S_ID_WIDTH-1:0]   m02_axi_rid,
    input  wire [DATA_WIDTH-1:0]   m02_axi_rdata,
    input  wire [1:0]              m02_axi_rresp,
    input  wire                    m02_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]  m02_axi_ruser,
    input  wire                    m02_axi_rvalid,
    output wire                    m02_axi_rready
);
    
    genvar i;

    reg [5:0] err_signal;
    reg [5:0] err_bit_index;
    reg [2:0] err_axi_connector;

    reg [5:0] err_signal_next;
    reg [5:0] err_bit_index_next;
    reg [2:0] err_axi_connector_next;

//gencode start here
    wire m_axi_awready_err_flag;
    wire m_axi_awready_err_d0;
    wire m_axi_awready_err_d1;
    wire m_axi_awready_err_d2;
    wire [2:0] m_axi_awready_err_dx;
    wire [5:0] m_axi_awready_err_bit_index;

    wire m_axi_wready_err_flag;
    wire m_axi_wready_err_d0;
    wire m_axi_wready_err_d1;
    wire m_axi_wready_err_d2;
    wire [2:0] m_axi_wready_err_dx;
    wire [5:0] m_axi_wready_err_bit_index;

    wire [S_ID_WIDTH-1:0] m_axi_bid_err_flag;
    wire [S_ID_WIDTH-1:0] m_axi_bid_err_d0;
    wire [S_ID_WIDTH-1:0] m_axi_bid_err_d1;
    wire [S_ID_WIDTH-1:0] m_axi_bid_err_d2;
    wire [2:0] m_axi_bid_err_dx;
    wire [5:0] m_axi_bid_err_bit_index;

    wire [1:0] m_axi_bresp_err_flag;
    wire [1:0] m_axi_bresp_err_d0;
    wire [1:0] m_axi_bresp_err_d1;
    wire [1:0] m_axi_bresp_err_d2;
    wire [2:0] m_axi_bresp_err_dx;
    wire [5:0] m_axi_bresp_err_bit_index;

    wire [BUSER_WIDTH-1:0] m_axi_buser_err_flag;
    wire [BUSER_WIDTH-1:0] m_axi_buser_err_d0;
    wire [BUSER_WIDTH-1:0] m_axi_buser_err_d1;
    wire [BUSER_WIDTH-1:0] m_axi_buser_err_d2;
    wire [2:0] m_axi_buser_err_dx;
    wire [5:0] m_axi_buser_err_bit_index;

    wire m_axi_bvalid_err_flag;
    wire m_axi_bvalid_err_d0;
    wire m_axi_bvalid_err_d1;
    wire m_axi_bvalid_err_d2;
    wire [2:0] m_axi_bvalid_err_dx;
    wire [5:0] m_axi_bvalid_err_bit_index;

    wire m_axi_arready_err_flag;
    wire m_axi_arready_err_d0;
    wire m_axi_arready_err_d1;
    wire m_axi_arready_err_d2;
    wire [2:0] m_axi_arready_err_dx;
    wire [5:0] m_axi_arready_err_bit_index;

    wire [S_ID_WIDTH-1:0] m_axi_rid_err_flag;
    wire [S_ID_WIDTH-1:0] m_axi_rid_err_d0;
    wire [S_ID_WIDTH-1:0] m_axi_rid_err_d1;
    wire [S_ID_WIDTH-1:0] m_axi_rid_err_d2;
    wire [2:0] m_axi_rid_err_dx;
    wire [5:0] m_axi_rid_err_bit_index;

    wire [DATA_WIDTH-1:0] m_axi_rdata_err_flag;
    wire [DATA_WIDTH-1:0] m_axi_rdata_err_d0;
    wire [DATA_WIDTH-1:0] m_axi_rdata_err_d1;
    wire [DATA_WIDTH-1:0] m_axi_rdata_err_d2;
    wire [2:0] m_axi_rdata_err_dx;
    wire [5:0] m_axi_rdata_err_bit_index;

    wire [1:0] m_axi_rresp_err_flag;
    wire [1:0] m_axi_rresp_err_d0;
    wire [1:0] m_axi_rresp_err_d1;
    wire [1:0] m_axi_rresp_err_d2;
    wire [2:0] m_axi_rresp_err_dx;
    wire [5:0] m_axi_rresp_err_bit_index;

    wire m_axi_rlast_err_flag;
    wire m_axi_rlast_err_d0;
    wire m_axi_rlast_err_d1;
    wire m_axi_rlast_err_d2;
    wire [2:0] m_axi_rlast_err_dx;
    wire [5:0] m_axi_rlast_err_bit_index;

    wire [RUSER_WIDTH-1:0] m_axi_ruser_err_flag;
    wire [RUSER_WIDTH-1:0] m_axi_ruser_err_d0;
    wire [RUSER_WIDTH-1:0] m_axi_ruser_err_d1;
    wire [RUSER_WIDTH-1:0] m_axi_ruser_err_d2;
    wire [2:0] m_axi_ruser_err_dx;
    wire [5:0] m_axi_ruser_err_bit_index;

    wire m_axi_rvalid_err_flag;
    wire m_axi_rvalid_err_d0;
    wire m_axi_rvalid_err_d1;
    wire m_axi_rvalid_err_d2;
    wire [2:0] m_axi_rvalid_err_dx;
    wire [5:0] m_axi_rvalid_err_bit_index;

    assign m00_axi_awid = s00_axi_awid;
    assign m01_axi_awid = s00_axi_awid;
    assign m02_axi_awid = s00_axi_awid;

    assign m00_axi_awaddr = s00_axi_awaddr;
    assign m01_axi_awaddr = s00_axi_awaddr;
    assign m02_axi_awaddr = s00_axi_awaddr;

    assign m00_axi_awlen = s00_axi_awlen;
    assign m01_axi_awlen = s00_axi_awlen;
    assign m02_axi_awlen = s00_axi_awlen;

    assign m00_axi_awsize = s00_axi_awsize;
    assign m01_axi_awsize = s00_axi_awsize;
    assign m02_axi_awsize = s00_axi_awsize;

    assign m00_axi_awburst = s00_axi_awburst;
    assign m01_axi_awburst = s00_axi_awburst;
    assign m02_axi_awburst = s00_axi_awburst;

    assign m00_axi_awlock = s00_axi_awlock;
    assign m01_axi_awlock = s00_axi_awlock;
    assign m02_axi_awlock = s00_axi_awlock;

    assign m00_axi_awcache = s00_axi_awcache;
    assign m01_axi_awcache = s00_axi_awcache;
    assign m02_axi_awcache = s00_axi_awcache;

    assign m00_axi_awprot = s00_axi_awprot;
    assign m01_axi_awprot = s00_axi_awprot;
    assign m02_axi_awprot = s00_axi_awprot;

    assign m00_axi_awqos = s00_axi_awqos;
    assign m01_axi_awqos = s00_axi_awqos;
    assign m02_axi_awqos = s00_axi_awqos;

    assign m00_axi_awuser = s00_axi_awuser;
    assign m01_axi_awuser = s00_axi_awuser;
    assign m02_axi_awuser = s00_axi_awuser;

    assign m00_axi_awvalid = s00_axi_awvalid;
    assign m01_axi_awvalid = s00_axi_awvalid;
    assign m02_axi_awvalid = s00_axi_awvalid;

    axi_tmr_voter_unit u_awready (
        .d0(m00_axi_awready),
        .d1(m01_axi_awready),
        .d2(m02_axi_awready),
        .d_out(s00_axi_awready),
        .err_flag(m_axi_awready_err_flag),
        .err_d0(m_axi_awready_err_d0),
        .err_d1(m_axi_awready_err_d1),
        .err_d2(m_axi_awready_err_d2)
    );

    assign m_axi_awready_err_dx = { m_axi_awready_err_d2, m_axi_awready_err_d1, m_axi_awready_err_d0 };
    assign m_axi_awready_err_bit_index = m_axi_awready_err_flag;

    assign m00_axi_wdata = s00_axi_wdata;
    assign m01_axi_wdata = s00_axi_wdata;
    assign m02_axi_wdata = s00_axi_wdata;

    assign m00_axi_wstrb = s00_axi_wstrb;
    assign m01_axi_wstrb = s00_axi_wstrb;
    assign m02_axi_wstrb = s00_axi_wstrb;

    assign m00_axi_wlast = s00_axi_wlast;
    assign m01_axi_wlast = s00_axi_wlast;
    assign m02_axi_wlast = s00_axi_wlast;

    assign m00_axi_wuser = s00_axi_wuser;
    assign m01_axi_wuser = s00_axi_wuser;
    assign m02_axi_wuser = s00_axi_wuser;

    assign m00_axi_wvalid = s00_axi_wvalid;
    assign m01_axi_wvalid = s00_axi_wvalid;
    assign m02_axi_wvalid = s00_axi_wvalid;

    axi_tmr_voter_unit u_wready (
        .d0(m00_axi_wready),
        .d1(m01_axi_wready),
        .d2(m02_axi_wready),
        .d_out(s00_axi_wready),
        .err_flag(m_axi_wready_err_flag),
        .err_d0(m_axi_wready_err_d0),
        .err_d1(m_axi_wready_err_d1),
        .err_d2(m_axi_wready_err_d2)
    );

    assign m_axi_wready_err_dx = { m_axi_wready_err_d2, m_axi_wready_err_d1, m_axi_wready_err_d0 };
    assign m_axi_wready_err_bit_index = m_axi_wready_err_flag;

    for(i=0; i<S_ID_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_bid (
            .d0(m00_axi_bid[i]),
            .d1(m01_axi_bid[i]),
            .d2(m02_axi_bid[i]),
            .d_out(s00_axi_bid[i]),
            .err_flag(m_axi_bid_err_flag[i]),
            .err_d0(m_axi_bid_err_d0[i]),
            .err_d1(m_axi_bid_err_d1[i]),
            .err_d2(m_axi_bid_err_d2[i])
        );
    end

    assign m_axi_bid_err_dx = { |m_axi_bid_err_d2, |m_axi_bid_err_d1, |m_axi_bid_err_d0 };
    assign m_axi_bid_err_bit_index = encode64_6(m_axi_bid_err_flag);

    for(i=0; i<1+1; i=i+1) begin
        axi_tmr_voter_unit u_bresp (
            .d0(m00_axi_bresp[i]),
            .d1(m01_axi_bresp[i]),
            .d2(m02_axi_bresp[i]),
            .d_out(s00_axi_bresp[i]),
            .err_flag(m_axi_bresp_err_flag[i]),
            .err_d0(m_axi_bresp_err_d0[i]),
            .err_d1(m_axi_bresp_err_d1[i]),
            .err_d2(m_axi_bresp_err_d2[i])
        );
    end

    assign m_axi_bresp_err_dx = { |m_axi_bresp_err_d2, |m_axi_bresp_err_d1, |m_axi_bresp_err_d0 };
    assign m_axi_bresp_err_bit_index = encode64_6(m_axi_bresp_err_flag);

    for(i=0; i<BUSER_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_buser (
            .d0(m00_axi_buser[i]),
            .d1(m01_axi_buser[i]),
            .d2(m02_axi_buser[i]),
            .d_out(s00_axi_buser[i]),
            .err_flag(m_axi_buser_err_flag[i]),
            .err_d0(m_axi_buser_err_d0[i]),
            .err_d1(m_axi_buser_err_d1[i]),
            .err_d2(m_axi_buser_err_d2[i])
        );
    end

    assign m_axi_buser_err_dx = { |m_axi_buser_err_d2, |m_axi_buser_err_d1, |m_axi_buser_err_d0 };
    assign m_axi_buser_err_bit_index = encode64_6(m_axi_buser_err_flag);

    axi_tmr_voter_unit u_bvalid (
        .d0(m00_axi_bvalid),
        .d1(m01_axi_bvalid),
        .d2(m02_axi_bvalid),
        .d_out(s00_axi_bvalid),
        .err_flag(m_axi_bvalid_err_flag),
        .err_d0(m_axi_bvalid_err_d0),
        .err_d1(m_axi_bvalid_err_d1),
        .err_d2(m_axi_bvalid_err_d2)
    );

    assign m_axi_bvalid_err_dx = { m_axi_bvalid_err_d2, m_axi_bvalid_err_d1, m_axi_bvalid_err_d0 };
    assign m_axi_bvalid_err_bit_index = m_axi_bvalid_err_flag;

    assign m00_axi_bready = s00_axi_bready;
    assign m01_axi_bready = s00_axi_bready;
    assign m02_axi_bready = s00_axi_bready;

    assign m00_axi_arid = s00_axi_arid;
    assign m01_axi_arid = s00_axi_arid;
    assign m02_axi_arid = s00_axi_arid;

    assign m00_axi_araddr = s00_axi_araddr;
    assign m01_axi_araddr = s00_axi_araddr;
    assign m02_axi_araddr = s00_axi_araddr;

    assign m00_axi_arlen = s00_axi_arlen;
    assign m01_axi_arlen = s00_axi_arlen;
    assign m02_axi_arlen = s00_axi_arlen;

    assign m00_axi_arsize = s00_axi_arsize;
    assign m01_axi_arsize = s00_axi_arsize;
    assign m02_axi_arsize = s00_axi_arsize;

    assign m00_axi_arburst = s00_axi_arburst;
    assign m01_axi_arburst = s00_axi_arburst;
    assign m02_axi_arburst = s00_axi_arburst;

    assign m00_axi_arlock = s00_axi_arlock;
    assign m01_axi_arlock = s00_axi_arlock;
    assign m02_axi_arlock = s00_axi_arlock;

    assign m00_axi_arcache = s00_axi_arcache;
    assign m01_axi_arcache = s00_axi_arcache;
    assign m02_axi_arcache = s00_axi_arcache;

    assign m00_axi_arprot = s00_axi_arprot;
    assign m01_axi_arprot = s00_axi_arprot;
    assign m02_axi_arprot = s00_axi_arprot;

    assign m00_axi_arqos = s00_axi_arqos;
    assign m01_axi_arqos = s00_axi_arqos;
    assign m02_axi_arqos = s00_axi_arqos;

    assign m00_axi_aruser = s00_axi_aruser;
    assign m01_axi_aruser = s00_axi_aruser;
    assign m02_axi_aruser = s00_axi_aruser;

    assign m00_axi_arvalid = s00_axi_arvalid;
    assign m01_axi_arvalid = s00_axi_arvalid;
    assign m02_axi_arvalid = s00_axi_arvalid;

    axi_tmr_voter_unit u_arready (
        .d0(m00_axi_arready),
        .d1(m01_axi_arready),
        .d2(m02_axi_arready),
        .d_out(s00_axi_arready),
        .err_flag(m_axi_arready_err_flag),
        .err_d0(m_axi_arready_err_d0),
        .err_d1(m_axi_arready_err_d1),
        .err_d2(m_axi_arready_err_d2)
    );

    assign m_axi_arready_err_dx = { m_axi_arready_err_d2, m_axi_arready_err_d1, m_axi_arready_err_d0 };
    assign m_axi_arready_err_bit_index = m_axi_arready_err_flag;

    for(i=0; i<S_ID_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_rid (
            .d0(m00_axi_rid[i]),
            .d1(m01_axi_rid[i]),
            .d2(m02_axi_rid[i]),
            .d_out(s00_axi_rid[i]),
            .err_flag(m_axi_rid_err_flag[i]),
            .err_d0(m_axi_rid_err_d0[i]),
            .err_d1(m_axi_rid_err_d1[i]),
            .err_d2(m_axi_rid_err_d2[i])
        );
    end

    assign m_axi_rid_err_dx = { |m_axi_rid_err_d2, |m_axi_rid_err_d1, |m_axi_rid_err_d0 };
    assign m_axi_rid_err_bit_index = encode64_6(m_axi_rid_err_flag);

    for(i=0; i<DATA_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_rdata (
            .d0(m00_axi_rdata[i]),
            .d1(m01_axi_rdata[i]),
            .d2(m02_axi_rdata[i]),
            .d_out(s00_axi_rdata[i]),
            .err_flag(m_axi_rdata_err_flag[i]),
            .err_d0(m_axi_rdata_err_d0[i]),
            .err_d1(m_axi_rdata_err_d1[i]),
            .err_d2(m_axi_rdata_err_d2[i])
        );
    end

    assign m_axi_rdata_err_dx = { |m_axi_rdata_err_d2, |m_axi_rdata_err_d1, |m_axi_rdata_err_d0 };
    assign m_axi_rdata_err_bit_index = encode64_6(m_axi_rdata_err_flag);

    for(i=0; i<1+1; i=i+1) begin
        axi_tmr_voter_unit u_rresp (
            .d0(m00_axi_rresp[i]),
            .d1(m01_axi_rresp[i]),
            .d2(m02_axi_rresp[i]),
            .d_out(s00_axi_rresp[i]),
            .err_flag(m_axi_rresp_err_flag[i]),
            .err_d0(m_axi_rresp_err_d0[i]),
            .err_d1(m_axi_rresp_err_d1[i]),
            .err_d2(m_axi_rresp_err_d2[i])
        );
    end

    assign m_axi_rresp_err_dx = { |m_axi_rresp_err_d2, |m_axi_rresp_err_d1, |m_axi_rresp_err_d0 };
    assign m_axi_rresp_err_bit_index = encode64_6(m_axi_rresp_err_flag);

    axi_tmr_voter_unit u_rlast (
        .d0(m00_axi_rlast),
        .d1(m01_axi_rlast),
        .d2(m02_axi_rlast),
        .d_out(s00_axi_rlast),
        .err_flag(m_axi_rlast_err_flag),
        .err_d0(m_axi_rlast_err_d0),
        .err_d1(m_axi_rlast_err_d1),
        .err_d2(m_axi_rlast_err_d2)
    );

    assign m_axi_rlast_err_dx = { m_axi_rlast_err_d2, m_axi_rlast_err_d1, m_axi_rlast_err_d0 };
    assign m_axi_rlast_err_bit_index = m_axi_rlast_err_flag;

    for(i=0; i<RUSER_WIDTH-1+1; i=i+1) begin
        axi_tmr_voter_unit u_ruser (
            .d0(m00_axi_ruser[i]),
            .d1(m01_axi_ruser[i]),
            .d2(m02_axi_ruser[i]),
            .d_out(s00_axi_ruser[i]),
            .err_flag(m_axi_ruser_err_flag[i]),
            .err_d0(m_axi_ruser_err_d0[i]),
            .err_d1(m_axi_ruser_err_d1[i]),
            .err_d2(m_axi_ruser_err_d2[i])
        );
    end

    assign m_axi_ruser_err_dx = { |m_axi_ruser_err_d2, |m_axi_ruser_err_d1, |m_axi_ruser_err_d0 };
    assign m_axi_ruser_err_bit_index = encode64_6(m_axi_ruser_err_flag);

    axi_tmr_voter_unit u_rvalid (
        .d0(m00_axi_rvalid),
        .d1(m01_axi_rvalid),
        .d2(m02_axi_rvalid),
        .d_out(s00_axi_rvalid),
        .err_flag(m_axi_rvalid_err_flag),
        .err_d0(m_axi_rvalid_err_d0),
        .err_d1(m_axi_rvalid_err_d1),
        .err_d2(m_axi_rvalid_err_d2)
    );

    assign m_axi_rvalid_err_dx = { m_axi_rvalid_err_d2, m_axi_rvalid_err_d1, m_axi_rvalid_err_d0 };
    assign m_axi_rvalid_err_bit_index = m_axi_rvalid_err_flag;

    assign m00_axi_rready = s00_axi_rready;
    assign m01_axi_rready = s00_axi_rready;
    assign m02_axi_rready = s00_axi_rready;

//gencode end

always@(*) begin
    if( |m_axi_awready_err_flag ) begin
        err_signal_next = `AXI_AWREADY_IDX;
        err_bit_index_next = m_axi_awready_err_bit_index;
        err_axi_connector_next = m_axi_awready_err_dx;
    end else if( |m_axi_wready_err_flag ) begin
        err_signal_next = `AXI_WREADY_IDX;
        err_bit_index_next = m_axi_wready_err_bit_index;
        err_axi_connector_next = m_axi_wready_err_dx;
    end else if( |m_axi_bid_err_flag ) begin
        err_signal_next = `AXI_BID_IDX;
        err_bit_index_next = m_axi_bid_err_bit_index;
        err_axi_connector_next = m_axi_bid_err_dx;
    end else if( |m_axi_bresp_err_flag ) begin
        err_signal_next = `AXI_BRESP_IDX;
        err_bit_index_next = m_axi_bresp_err_bit_index;
        err_axi_connector_next = m_axi_bresp_err_dx;
    end else if( |m_axi_buser_err_flag ) begin
        err_signal_next = `AXI_BUSER_IDX;
        err_bit_index_next = m_axi_buser_err_bit_index;
        err_axi_connector_next = m_axi_buser_err_dx;
    end else if( |m_axi_bvalid_err_flag ) begin
        err_signal_next = `AXI_BVALID_IDX;
        err_bit_index_next = m_axi_bvalid_err_bit_index;
        err_axi_connector_next = m_axi_bvalid_err_dx;
    end else if( |m_axi_arready_err_flag ) begin
        err_signal_next = `AXI_ARREADY_IDX;
        err_bit_index_next = m_axi_arready_err_bit_index;
        err_axi_connector_next = m_axi_arready_err_dx;
    end else if( |m_axi_rid_err_flag ) begin
        err_signal_next = `AXI_RID_IDX;
        err_bit_index_next = m_axi_rid_err_bit_index;
        err_axi_connector_next = m_axi_rid_err_dx;
    end else if( |m_axi_rdata_err_flag ) begin
        err_signal_next = `AXI_RDATA_IDX;
        err_bit_index_next = m_axi_rdata_err_bit_index;
        err_axi_connector_next = m_axi_rdata_err_dx;
    end else if( |m_axi_rresp_err_flag ) begin
        err_signal_next = `AXI_RRESP_IDX;
        err_bit_index_next = m_axi_rresp_err_bit_index;
        err_axi_connector_next = m_axi_rresp_err_dx;
    end else if( |m_axi_rlast_err_flag ) begin
        err_signal_next = `AXI_RLAST_IDX;
        err_bit_index_next = m_axi_rlast_err_bit_index;
        err_axi_connector_next = m_axi_rlast_err_dx;
    end else if( |m_axi_ruser_err_flag ) begin
        err_signal_next = `AXI_RUSER_IDX;
        err_bit_index_next = m_axi_ruser_err_bit_index;
        err_axi_connector_next = m_axi_ruser_err_dx;
    end else if( |m_axi_rvalid_err_flag ) begin
        err_signal_next = `AXI_RVALID_IDX;
        err_bit_index_next = m_axi_rvalid_err_bit_index;
        err_axi_connector_next = m_axi_rvalid_err_dx;
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
