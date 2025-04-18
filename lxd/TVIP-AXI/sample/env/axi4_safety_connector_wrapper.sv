`ifndef AXI4_SAFETY_CONNECTOR_WRAPPER_SV
`define AXI4_SAFETY_CONNECTOR_WRAPPER_SV

module axi4_safety_connector_wrapper #(
)(
  input var        aclk,
  input var        areset_n,
  tvip_axi_if  s0_axi,
  tvip_axi_if  s1_axi,
  tvip_axi_if  s2_axi,
  tvip_axi_if m0_axi,
  tvip_axi_if m1_axi,
  tvip_axi_if m2_axi,
  tvip_axi_if m3_axi
);
  import  tvip_axi_types_pkg::*;
  import  tvip_axi_pkg::*;

  axi4_safety_connector #(
  ) u_connector (
    .clk(aclk),
    .rst(!areset_n),

    //--------------------------------------------------
    // Slave 0 Interface
    //--------------------------------------------------
    // AW Channel
    .s00_axi_awvalid(s0_axi.awvalid),
    .s00_axi_awready(s0_axi.awready),
    .s00_axi_awid(s0_axi.awid),
    .s00_axi_awaddr(s0_axi.awaddr),
    .s00_axi_awlen(s0_axi.awlen),
    .s00_axi_awsize(s0_axi.awsize),
    .s00_axi_awburst(s0_axi.awburst),
    .s00_axi_awcache(s0_axi.awcache),
    .s00_axi_awprot(s0_axi.awprot),
    .s00_axi_awqos(s0_axi.awqos),
    
    // W Channel
    .s00_axi_wvalid(s0_axi.wvalid),
    .s00_axi_wready(s0_axi.wready),
    .s00_axi_wdata(s0_axi.wdata),
    .s00_axi_wstrb(s0_axi.wstrb),
    .s00_axi_wlast(s0_axi.wlast),
    
    // B Channel
    .s00_axi_bvalid(s0_axi.bvalid),
    .s00_axi_bready(s0_axi.bready),
    .s00_axi_bid(s0_axi.bid),
    .s00_axi_bresp(s0_axi.bresp),

    // AR Channel
    .s00_axi_arvalid(s0_axi.arvalid),
    .s00_axi_arready(s0_axi.arready),
    .s00_axi_arid(s0_axi.arid),
    .s00_axi_araddr(s0_axi.araddr),
    .s00_axi_arlen(s0_axi.arlen),
    .s00_axi_arsize(s0_axi.arsize),
    .s00_axi_arburst(s0_axi.arburst),
    .s00_axi_arcache(s0_axi.arcache),  
    .s00_axi_arprot(s0_axi.arprot),    
    .s00_axi_arqos(s0_axi.arqos),      
    
    // R Channel
    .s00_axi_rvalid(s0_axi.rvalid),
    .s00_axi_rready(s0_axi.rready),
    .s00_axi_rid(s0_axi.rid),
    .s00_axi_rdata(s0_axi.rdata),
    .s00_axi_rresp(s0_axi.rresp),
    .s00_axi_rlast(s0_axi.rlast),

    //--------------------------------------------------
    // Slave 1 Interface
    //--------------------------------------------------
    // AW Channel
    .s01_axi_awvalid(s1_axi.awvalid),
    .s01_axi_awready(s1_axi.awready),
    .s01_axi_awid(s1_axi.awid),
    .s01_axi_awaddr(s1_axi.awaddr),
    .s01_axi_awlen(s1_axi.awlen),
    .s01_axi_awsize(s1_axi.awsize),
    .s01_axi_awburst(s1_axi.awburst),
    
    // W Channel
    .s01_axi_wvalid(s1_axi.wvalid),
    .s01_axi_wready(s1_axi.wready),
    .s01_axi_wdata(s1_axi.wdata),
    .s01_axi_wstrb(s1_axi.wstrb),
    .s01_axi_wlast(s1_axi.wlast),
    
    // B Channel
    .s01_axi_bvalid(s1_axi.bvalid),
    .s01_axi_bready(s1_axi.bready),
    .s01_axi_bid(s1_axi.bid),
    .s01_axi_bresp(s1_axi.bresp),
    
    // AR Channel
    .s01_axi_arvalid(s1_axi.arvalid),
    .s01_axi_arready(s1_axi.arready),
    .s01_axi_arid(s1_axi.arid),
    .s01_axi_araddr(s1_axi.araddr),
    .s01_axi_arlen(s1_axi.arlen),
    .s01_axi_arsize(s1_axi.arsize),
    .s01_axi_arburst(s1_axi.arburst),
    .s01_axi_arcache(s1_axi.arcache),  
    .s01_axi_arprot(s1_axi.arprot),    
    .s01_axi_arqos(s1_axi.arqos),      
    
    // R Channel
    .s01_axi_rvalid(s1_axi.rvalid),
    .s01_axi_rready(s1_axi.rready),
    .s01_axi_rid(s1_axi.rid),
    .s01_axi_rdata(s1_axi.rdata),
    .s01_axi_rresp(s1_axi.rresp),
    .s01_axi_rlast(s1_axi.rlast),

    //--------------------------------------------------
    // Slave 2 Interface 
    //--------------------------------------------------
    // AW Channel
    .s02_axi_awvalid(s2_axi.awvalid),
    .s02_axi_awready(s2_axi.awready),
    .s02_axi_awid(s2_axi.awid),
    .s02_axi_awaddr(s2_axi.awaddr),
    .s02_axi_awlen(s2_axi.awlen),
    .s02_axi_awsize(s2_axi.awsize),
    .s02_axi_awburst(s2_axi.awburst),
    
    // W Channel
    .s02_axi_wvalid(s2_axi.wvalid),
    .s02_axi_wready(s2_axi.wready),
    .s02_axi_wdata(s2_axi.wdata),
    .s02_axi_wstrb(s2_axi.wstrb),
    .s02_axi_wlast(s2_axi.wlast),
    
    // B Channel
    .s02_axi_bvalid(s2_axi.bvalid),
    .s02_axi_bready(s2_axi.bready),
    .s02_axi_bid(s2_axi.bid),
    .s02_axi_bresp(s2_axi.bresp),
    
    // AR Channel
    .s02_axi_arvalid(s2_axi.arvalid),
    .s02_axi_arready(s2_axi.arready),
    .s02_axi_arid(s2_axi.arid),
    .s02_axi_araddr(s2_axi.araddr),
    .s02_axi_arlen(s2_axi.arlen),
    .s02_axi_arsize(s2_axi.arsize),
    .s02_axi_arburst(s2_axi.arburst),
    .s02_axi_arcache(s2_axi.arcache),  
    .s02_axi_arprot(s2_axi.arprot),    
    .s02_axi_arqos(s2_axi.arqos),      
    
    // R Channel
    .s02_axi_rvalid(s2_axi.rvalid),
    .s02_axi_rready(s2_axi.rready),
    .s02_axi_rid(s2_axi.rid),
    .s02_axi_rdata(s2_axi.rdata),
    .s02_axi_rresp(s2_axi.rresp),
    .s02_axi_rlast(s2_axi.rlast),

    //--------------------------------------------------
    // Master 0 Interface
    //--------------------------------------------------
    // AW Channel
    .m00_axi_awvalid(m0_axi.awvalid),
    .m00_axi_awready(m0_axi.awready),
    .m00_axi_awid(m0_axi.awid),
    .m00_axi_awaddr(m0_axi.awaddr),
    .m00_axi_awlen(m0_axi.awlen),
    .m00_axi_awsize(m0_axi.awsize),
    .m00_axi_awburst(m0_axi.awburst),
    .m00_axi_awcache(m0_axi.awcache),
    .m00_axi_awprot(m0_axi.awprot),
    .m00_axi_awqos(m0_axi.awqos),

    // W Channel
    .m00_axi_wvalid(m0_axi.wvalid),
    .m00_axi_wready(m0_axi.wready),
    .m00_axi_wdata(m0_axi.wdata),
    .m00_axi_wstrb(m0_axi.wstrb),
    .m00_axi_wlast(m0_axi.wlast),
    
    // B Channel
    .m00_axi_bvalid(m0_axi.bvalid),
    .m00_axi_bready(m0_axi.bready),
    .m00_axi_bid(m0_axi.bid),
    .m00_axi_bresp(tvip_axi_response'(m0_axi.bresp)),
    
    // AR Channel
    .m00_axi_arvalid(m0_axi.arvalid),
    .m00_axi_arready(m0_axi.arready),
    .m00_axi_arid(m0_axi.arid),
    .m00_axi_araddr(m0_axi.araddr),
    .m00_axi_arlen(m0_axi.arlen),
    .m00_axi_arsize(m0_axi.arsize),
    .m00_axi_arburst(m0_axi.arburst),
    .m00_axi_arcache(m0_axi.arcache),  
    .m00_axi_arprot(m0_axi.arprot),    
    .m00_axi_arqos(m0_axi.arqos),      
    
    // R Channel
    .m00_axi_rvalid(m0_axi.rvalid),
    .m00_axi_rready(m0_axi.rready),
    .m00_axi_rid(m0_axi.rid),
    .m00_axi_rdata(m0_axi.rdata),
    .m00_axi_rresp(m0_axi.rresp),
    .m00_axi_rlast(m0_axi.rlast),

    //--------------------------------------------------
    // Master 1 Interface
    //--------------------------------------------------
    // AW Channel
    .m01_axi_awvalid(m1_axi.awvalid),
    .m01_axi_awready(m1_axi.awready),
    .m01_axi_awid(m1_axi.awid),
    .m01_axi_awaddr(m1_axi.awaddr),
    .m01_axi_awlen(m1_axi.awlen),
    .m01_axi_awsize(m1_axi.awsize),
    .m01_axi_awburst(m1_axi.awburst),
    .m01_axi_awcache(m1_axi.awcache),
    .m01_axi_awprot(m1_axi.awprot),
    .m01_axi_awqos(m1_axi.awqos),

    // W Channel
    .m01_axi_wvalid(m1_axi.wvalid),
    .m01_axi_wready(m1_axi.wready),
    .m01_axi_wdata(m1_axi.wdata),
    .m01_axi_wstrb(m1_axi.wstrb),
    .m01_axi_wlast(m1_axi.wlast),
    
    // B Channel
    .m01_axi_bvalid(m1_axi.bvalid),
    .m01_axi_bready(m1_axi.bready),
    .m01_axi_bid(m1_axi.bid),
    .m01_axi_bresp(tvip_axi_response'(m1_axi.bresp)),
    
    // AR Channel
    .m01_axi_arvalid(m1_axi.arvalid),
    .m01_axi_arready(m1_axi.arready),
    .m01_axi_arid(m1_axi.arid),
    .m01_axi_araddr(m1_axi.araddr),
    .m01_axi_arlen(m1_axi.arlen),
    .m01_axi_arsize(m1_axi.arsize),
    .m01_axi_arburst(m1_axi.arburst),
    .m01_axi_arcache(m1_axi.arcache),  
    .m01_axi_arprot(m1_axi.arprot),    
    .m01_axi_arqos(m1_axi.arqos),      
    
    // R Channel
    .m01_axi_rvalid(m1_axi.rvalid),
    .m01_axi_rready(m1_axi.rready),
    .m01_axi_rid(m1_axi.rid),
    .m01_axi_rdata(m1_axi.rdata),
    .m01_axi_rresp(m1_axi.rresp),
    .m01_axi_rlast(m1_axi.rlast),

    //--------------------------------------------------
    // Master 2 Interface
    //--------------------------------------------------
    // AW Channel
    .m02_axi_awvalid(m2_axi.awvalid),
    .m02_axi_awready(m2_axi.awready),
    .m02_axi_awid(m2_axi.awid),
    .m02_axi_awaddr(m2_axi.awaddr),
    .m02_axi_awlen(m2_axi.awlen),
    .m02_axi_awsize(m2_axi.awsize),
    .m02_axi_awburst(m2_axi.awburst),
    .m02_axi_awcache(m2_axi.awcache),
    .m02_axi_awprot(m2_axi.awprot),
    .m02_axi_awqos(m2_axi.awqos),

    // W Channel
    .m02_axi_wvalid(m2_axi.wvalid),
    .m02_axi_wready(m2_axi.wready),
    .m02_axi_wdata(m2_axi.wdata),
    .m02_axi_wstrb(m2_axi.wstrb),
    .m02_axi_wlast(m2_axi.wlast),
    
    // B Channel
    .m02_axi_bvalid(m2_axi.bvalid),
    .m02_axi_bready(m2_axi.bready),
    .m02_axi_bid(m2_axi.bid),
    .m02_axi_bresp(tvip_axi_response'(m2_axi.bresp)),
    
    // AR Channel
    .m02_axi_arvalid(m2_axi.arvalid),
    .m02_axi_arready(m2_axi.arready),
    .m02_axi_arid(m2_axi.arid),
    .m02_axi_araddr(m2_axi.araddr),
    .m02_axi_arlen(m2_axi.arlen),
    .m02_axi_arsize(m2_axi.arsize),
    .m02_axi_arburst(m2_axi.arburst),
    .m02_axi_arcache(m2_axi.arcache),  
    .m02_axi_arprot(m2_axi.arprot),    
    .m02_axi_arqos(m2_axi.arqos),      
    
    // R Channel
    .m02_axi_rvalid(m2_axi.rvalid),
    .m02_axi_rready(m2_axi.rready),
    .m02_axi_rid(m2_axi.rid),
    .m02_axi_rdata(m2_axi.rdata),
    .m02_axi_rresp(m2_axi.rresp),
    .m02_axi_rlast(m2_axi.rlast),

    //--------------------------------------------------
    // Master 3 Interface
    //--------------------------------------------------
    // AW Channel
    .m03_axi_awvalid(m3_axi.awvalid),
    .m03_axi_awready(m3_axi.awready),
    .m03_axi_awid(m3_axi.awid),
    .m03_axi_awaddr(m3_axi.awaddr),
    .m03_axi_awlen(m3_axi.awlen),
    .m03_axi_awsize(m3_axi.awsize),
    .m03_axi_awburst(m3_axi.awburst),
    .m03_axi_awcache(m3_axi.awcache),
    .m03_axi_awprot(m3_axi.awprot),
    .m03_axi_awqos(m3_axi.awqos),

    // W Channel
    .m03_axi_wvalid(m3_axi.wvalid),
    .m03_axi_wready(m3_axi.wready),
    .m03_axi_wdata(m3_axi.wdata),
    .m03_axi_wstrb(m3_axi.wstrb),
    .m03_axi_wlast(m3_axi.wlast),
    
    // B Channel
    .m03_axi_bvalid(m3_axi.bvalid),
    .m03_axi_bready(m3_axi.bready),
    .m03_axi_bid(m3_axi.bid),
    .m03_axi_bresp(tvip_axi_response'(m3_axi.bresp)),
    
    // AR Channel
    .m03_axi_arvalid(m3_axi.arvalid),
    .m03_axi_arready(m3_axi.arready),
    .m03_axi_arid(m3_axi.arid),
    .m03_axi_araddr(m3_axi.araddr),
    .m03_axi_arlen(m3_axi.arlen),
    .m03_axi_arsize(m3_axi.arsize),
    .m03_axi_arburst(m3_axi.arburst),
    .m03_axi_arcache(m3_axi.arcache),  
    .m03_axi_arprot(m3_axi.arprot),    
    .m03_axi_arqos(m3_axi.arqos),      
    
    // R Channel
    .m03_axi_rvalid(m3_axi.rvalid),
    .m03_axi_rready(m3_axi.rready),
    .m03_axi_rid(m3_axi.rid),
    .m03_axi_rdata(m3_axi.rdata),
    .m03_axi_rresp(m3_axi.rresp),
    .m03_axi_rlast(m3_axi.rlast)
);

endmodule

`endif