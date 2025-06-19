module axi_sft_tmr_crossbar_addr #
(
    // Slave interface index
    parameter S = 0,
    // Number of AXI inputs (slave interfaces)
    parameter S_COUNT = 4,
    // Number of AXI outputs (master interfaces)
    parameter M_COUNT = 4,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // ID field width
    parameter ID_WIDTH = 8,
    // Number of concurrent unique IDs
    parameter S_THREADS = 32'd2,
    // Number of concurrent operations
    parameter S_ACCEPT = 32'd16,
    // Number of regions per master interface
    parameter M_REGIONS = 1,
    // Master interface base addresses
    // M_COUNT concatenated fields of M_REGIONS concatenated fields of ADDR_WIDTH bits
    // set to zero for default addressing based on M_ADDR_WIDTH
    parameter M_BASE_ADDR = 0,
    // Master interface address widths
    // M_COUNT concatenated fields of M_REGIONS concatenated fields of 32 bits
    parameter M_ADDR_WIDTH = {M_COUNT{{M_REGIONS{32'd24}}}},
    // Connections between interfaces
    // M_COUNT concatenated fields of S_COUNT bits
    parameter M_CONNECT = {M_COUNT{{S_COUNT{1'b1}}}},
    // Secure master (fail operations based on awprot/arprot)
    // M_COUNT bits
    parameter M_SECURE = {M_COUNT{1'b0}},
    // Enable write command output
    parameter WC_OUTPUT = 0
)
(
    input  wire                       clk,
    input  wire                       rst,

    input  wire [ID_WIDTH-1:0]        s_axi_aid,
    input  wire [ADDR_WIDTH-1:0]      s_axi_aaddr,
    input  wire [2:0]                 s_axi_aprot,
    input  wire [3:0]                 s_axi_aqos,
    //input  wire                       s_axi_avalid,
    input  wire                       s_axi_avalid_tmr0,
    input  wire                       s_axi_avalid_tmr1,
    input  wire                       s_axi_avalid_tmr2,

    //output wire                     s_axi_aready,
    output wire                       s_axi_aready_tmr0,
    output wire                       s_axi_aready_tmr1,
    output wire                       s_axi_aready_tmr2,

    output wire [3:0]                 m_axi_aregion,
    output wire [$clog2(M_COUNT)-1:0] m_select_tmr0,
    output wire [$clog2(M_COUNT)-1:0] m_select_tmr1,
    output wire [$clog2(M_COUNT)-1:0] m_select_tmr2,
    output wire                       m_axi_avalid_tmr0,
    output wire                       m_axi_avalid_tmr1,
    output wire                       m_axi_avalid_tmr2,
    input  wire                       m_axi_aready_tmr0,
    input  wire                       m_axi_aready_tmr1,
    input  wire                       m_axi_aready_tmr2,

    output wire [$clog2(M_COUNT)-1:0] m_wc_select,
    output wire                       m_wc_decerr,
    output wire                       m_wc_valid,
    input wire                        m_wc_ready,

    output wire                       m_rc_decerr,
    output wire                       m_rc_valid,
    input wire                        m_rc_ready,

    input  wire [ID_WIDTH-1:0]        s_cpl_id,
    input  wire                       s_cpl_valid
);

    //tmr0
    wire [ID_WIDTH-1:0]        s_axi_aid_tmr0;
    wire [ADDR_WIDTH-1:0]      s_axi_aaddr_tmr0;
    wire [2:0]                 s_axi_aprot_tmr0;
    wire [3:0]                 s_axi_aqos_tmr0;

    wire [3:0]                 m_axi_aregion_tmr0;

    wire [ID_WIDTH-1:0]        s_cpl_id_tmr0;
    wire                       s_cpl_valid_tmr0;

    //tmr1
    wire [ID_WIDTH-1:0]        s_axi_aid_tmr1;
    wire [ADDR_WIDTH-1:0]      s_axi_aaddr_tmr1;
    wire [2:0]                 s_axi_aprot_tmr1;
    wire [3:0]                 s_axi_aqos_tmr1;


    wire [3:0]                 m_axi_aregion_tmr1;

    wire [ID_WIDTH-1:0]        s_cpl_id_tmr1;
    wire                       s_cpl_valid_tmr1;

    //tmr2
    wire [ID_WIDTH-1:0]        s_axi_aid_tmr2;
    wire [ADDR_WIDTH-1:0]      s_axi_aaddr_tmr2;
    wire [2:0]                 s_axi_aprot_tmr2;
    wire [3:0]                 s_axi_aqos_tmr2;

    wire [3:0]                 m_axi_aregion_tmr2;

    wire [ID_WIDTH-1:0]        s_cpl_id_tmr2;
    wire                       s_cpl_valid_tmr2;

    wire [$clog2(M_COUNT)-1:0] m_wc_select_tmr0;
    wire [$clog2(M_COUNT)-1:0] m_wc_select_tmr1;
    wire [$clog2(M_COUNT)-1:0] m_wc_select_tmr2;
    wire                       m_wc_decerr_tmr0;
    wire                       m_wc_decerr_tmr1;
    wire                       m_wc_decerr_tmr2;
    wire                       m_wc_valid_tmr0;
    wire                       m_wc_valid_tmr1;
    wire                       m_wc_valid_tmr2;
    wire                       m_wc_ready_tmr0;
    wire                       m_wc_ready_tmr1;
    wire                       m_wc_ready_tmr2;

    wire                       m_rc_decerr_tmr0;
    wire                       m_rc_decerr_tmr1;
    wire                       m_rc_decerr_tmr2;
    wire                       m_rc_valid_tmr0;
    wire                       m_rc_valid_tmr1;
    wire                       m_rc_valid_tmr2;
    wire                       m_rc_ready_tmr0;
    wire                       m_rc_ready_tmr1;
    wire                       m_rc_ready_tmr2;

    axi_tmr_simple_voter #($clog2(M_COUNT)) axi_tmr_simple_voter_m_wc_select (.d0(m_wc_select_tmr0), .d1(m_wc_select_tmr1), .d2(m_wc_select_tmr2), .q(m_wc_select));
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_m_wc_decerr (.d0(m_wc_decerr_tmr0), .d1(m_wc_decerr_tmr1), .d2(m_wc_decerr_tmr2), .q(m_wc_decerr));
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_m_wc_valid (.d0(m_wc_valid_tmr0), .d1(m_wc_valid_tmr1), .d2(m_wc_valid_tmr2), .q(m_wc_valid));

    assign m_wc_ready_tmr0 = m_wc_ready;
    assign m_wc_ready_tmr1 = m_wc_ready;
    assign m_wc_ready_tmr2 = m_wc_ready;

    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_m_rc_decerr (.d0(m_rc_decerr_tmr0), .d1(m_rc_decerr_tmr1), .d2(m_rc_decerr_tmr2), .q(m_rc_decerr));
    axi_tmr_simple_voter #(1) axi_tmr_simple_voter_m_rc_valid (.d0(m_rc_valid_tmr0), .d1(m_rc_valid_tmr1), .d2(m_rc_valid_tmr2), .q(m_rc_valid));

    assign m_rc_ready_tmr0 = m_rc_ready;
    assign m_rc_ready_tmr1 = m_rc_ready;
    assign m_rc_ready_tmr2 = m_rc_ready;



    assign s_axi_aid_tmr0 = s_axi_aid;
    assign s_axi_aid_tmr1 = s_axi_aid;
    assign s_axi_aid_tmr2 = s_axi_aid; 

    assign s_axi_aaddr_tmr0 = s_axi_aaddr;
    assign s_axi_aaddr_tmr1 = s_axi_aaddr;
    assign s_axi_aaddr_tmr2 = s_axi_aaddr;

    assign s_axi_aprot_tmr0 = s_axi_aprot;
    assign s_axi_aprot_tmr1 = s_axi_aprot;
    assign s_axi_aprot_tmr2 = s_axi_aprot;

    assign s_axi_aqos_tmr0 = s_axi_aqos;
    assign s_axi_aqos_tmr1 = s_axi_aqos;
    assign s_axi_aqos_tmr2 = s_axi_aqos;

    axi_tmr_simple_voter #(4) axi_tmr_simple_voter_m_axi_aregion(.d0(m_axi_aregion_tmr0), .d1(m_axi_aregion_tmr1), .d2(m_axi_aregion_tmr2), .q(m_axi_aregion));

    assign s_cpl_id_tmr0 = s_cpl_id;
    assign s_cpl_id_tmr1 = s_cpl_id;
    assign s_cpl_id_tmr2 = s_cpl_id;

    assign s_cpl_valid_tmr0 = s_cpl_valid;
    assign s_cpl_valid_tmr1 = s_cpl_valid;
    assign s_cpl_valid_tmr2 = s_cpl_valid;




axi_sft_crossbar_addr #(
    .S(S),
    .S_COUNT(S_COUNT),
    .M_COUNT(M_COUNT),
    .ADDR_WIDTH(ADDR_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .S_THREADS(S_THREADS),
    .S_ACCEPT(S_ACCEPT),
    .M_REGIONS(M_REGIONS),
    .M_BASE_ADDR(M_BASE_ADDR),
    .M_ADDR_WIDTH(M_ADDR_WIDTH),
    .M_CONNECT(M_CONNECT),
    .M_SECURE(M_SECURE),
    .WC_OUTPUT(WC_OUTPUT)
) u_axi_sft_crossbar_addr_inst_tmr0 (
    .clk(clk),
    .rst(rst),

    .s_axi_aid(s_axi_aid_tmr0),
    .s_axi_aaddr(s_axi_aaddr_tmr0),
    .s_axi_aprot(s_axi_aprot_tmr0),
    .s_axi_aqos(s_axi_aqos_tmr0),
    .s_axi_avalid(s_axi_avalid_tmr0),
    .s_axi_aready(s_axi_aready_tmr0),

    .m_axi_aregion(m_axi_aregion_tmr0),
    .m_select(m_select_tmr0),
    .m_axi_avalid(m_axi_avalid_tmr0),
    .m_axi_aready(m_axi_aready_tmr0),

    .m_wc_select(m_wc_select_tmr0),
    .m_wc_decerr(m_wc_decerr_tmr0),
    .m_wc_valid(m_wc_valid_tmr0),
    .m_wc_ready(m_wc_ready_tmr0),

    .m_rc_decerr(m_rc_decerr_tmr0),
    .m_rc_valid(m_rc_valid_tmr0),
    .m_rc_ready(m_rc_ready_tmr0),

    .s_cpl_id(s_cpl_id_tmr0),
    .s_cpl_valid(s_cpl_valid_tmr0)
);

axi_sft_crossbar_addr #(
    .S(S),
    .S_COUNT(S_COUNT),
    .M_COUNT(M_COUNT),
    .ADDR_WIDTH(ADDR_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .S_THREADS(S_THREADS),
    .S_ACCEPT(S_ACCEPT),
    .M_REGIONS(M_REGIONS),
    .M_BASE_ADDR(M_BASE_ADDR),
    .M_ADDR_WIDTH(M_ADDR_WIDTH),
    .M_CONNECT(M_CONNECT),
    .M_SECURE(M_SECURE),
    .WC_OUTPUT(WC_OUTPUT)
) u_axi_sft_crossbar_addr_inst_tmr1 (
    .clk(clk),
    .rst(rst),

    .s_axi_aid(s_axi_aid_tmr1),
    .s_axi_aaddr(s_axi_aaddr_tmr1),
    .s_axi_aprot(s_axi_aprot_tmr1),
    .s_axi_aqos(s_axi_aqos_tmr1),
    .s_axi_avalid(s_axi_avalid_tmr1),
    .s_axi_aready(s_axi_aready_tmr1),

    .m_axi_aregion(m_axi_aregion_tmr1),
    .m_select(m_select_tmr1),
    .m_axi_avalid(m_axi_avalid_tmr1),
    .m_axi_aready(m_axi_aready_tmr1),

    .m_wc_select(m_wc_select_tmr1),
    .m_wc_decerr(m_wc_decerr_tmr1),
    .m_wc_valid(m_wc_valid_tmr1),
    .m_wc_ready(m_wc_ready_tmr1),

    .m_rc_decerr(m_rc_decerr_tmr1),
    .m_rc_valid(m_rc_valid_tmr1),
    .m_rc_ready(m_rc_ready_tmr1),

    .s_cpl_id(s_cpl_id_tmr1),
    .s_cpl_valid(s_cpl_valid_tmr1)
);

axi_sft_crossbar_addr #(
    .S(S),
    .S_COUNT(S_COUNT),
    .M_COUNT(M_COUNT),
    .ADDR_WIDTH(ADDR_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .S_THREADS(S_THREADS),
    .S_ACCEPT(S_ACCEPT),
    .M_REGIONS(M_REGIONS),
    .M_BASE_ADDR(M_BASE_ADDR),
    .M_ADDR_WIDTH(M_ADDR_WIDTH),
    .M_CONNECT(M_CONNECT),
    .M_SECURE(M_SECURE),
    .WC_OUTPUT(WC_OUTPUT)
) u_axi_sft_crossbar_addr_inst_tmr2 (
    .clk(clk),
    .rst(rst),

    .s_axi_aid(s_axi_aid_tmr2),
    .s_axi_aaddr(s_axi_aaddr_tmr2),
    .s_axi_aprot(s_axi_aprot_tmr2),
    .s_axi_aqos(s_axi_aqos_tmr2),
    .s_axi_avalid(s_axi_avalid_tmr2),
    .s_axi_aready(s_axi_aready_tmr2),

    .m_axi_aregion(m_axi_aregion_tmr2),
    .m_select(m_select_tmr2),
    .m_axi_avalid(m_axi_avalid_tmr2),
    .m_axi_aready(m_axi_aready_tmr2),

    .m_wc_select(m_wc_select_tmr2),
    .m_wc_decerr(m_wc_decerr_tmr2),
    .m_wc_valid(m_wc_valid_tmr2),
    .m_wc_ready(m_wc_ready_tmr2),

    .m_rc_decerr(m_rc_decerr_tmr2),
    .m_rc_valid(m_rc_valid_tmr2),
    .m_rc_ready(m_rc_ready_tmr2),

    .s_cpl_id(s_cpl_id_tmr2),
    .s_cpl_valid(s_cpl_valid_tmr2)
);



endmodule