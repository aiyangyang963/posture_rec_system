//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
//Date        : Wed Aug 15 17:30:10 2018
//Host        : PK8W2TV3U66VGZI running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (AXI_CLK,
    AXI_TO_PL_araddr,
    AXI_TO_PL_arburst,
    AXI_TO_PL_arcache,
    AXI_TO_PL_arid,
    AXI_TO_PL_arlen,
    AXI_TO_PL_arlock,
    AXI_TO_PL_arprot,
    AXI_TO_PL_arqos,
    AXI_TO_PL_arready,
    AXI_TO_PL_arsize,
    AXI_TO_PL_aruser,
    AXI_TO_PL_arvalid,
    AXI_TO_PL_awaddr,
    AXI_TO_PL_awburst,
    AXI_TO_PL_awcache,
    AXI_TO_PL_awid,
    AXI_TO_PL_awlen,
    AXI_TO_PL_awlock,
    AXI_TO_PL_awprot,
    AXI_TO_PL_awqos,
    AXI_TO_PL_awready,
    AXI_TO_PL_awsize,
    AXI_TO_PL_awuser,
    AXI_TO_PL_awvalid,
    AXI_TO_PL_bid,
    AXI_TO_PL_bready,
    AXI_TO_PL_bresp,
    AXI_TO_PL_bvalid,
    AXI_TO_PL_rdata,
    AXI_TO_PL_rid,
    AXI_TO_PL_rlast,
    AXI_TO_PL_rready,
    AXI_TO_PL_rresp,
    AXI_TO_PL_rvalid,
    AXI_TO_PL_wdata,
    AXI_TO_PL_wlast,
    AXI_TO_PL_wready,
    AXI_TO_PL_wstrb,
    AXI_TO_PL_wvalid,
    DEAL_FINISH_INT,
    DEAL_START_INT_tri_o,
    GLOBAL_RESET_N);
  output AXI_CLK;
  input [48:0]AXI_TO_PL_araddr;
  input [1:0]AXI_TO_PL_arburst;
  input [3:0]AXI_TO_PL_arcache;
  input [5:0]AXI_TO_PL_arid;
  input [7:0]AXI_TO_PL_arlen;
  input AXI_TO_PL_arlock;
  input [2:0]AXI_TO_PL_arprot;
  input [3:0]AXI_TO_PL_arqos;
  output AXI_TO_PL_arready;
  input [2:0]AXI_TO_PL_arsize;
  input AXI_TO_PL_aruser;
  input AXI_TO_PL_arvalid;
  input [48:0]AXI_TO_PL_awaddr;
  input [1:0]AXI_TO_PL_awburst;
  input [3:0]AXI_TO_PL_awcache;
  input [5:0]AXI_TO_PL_awid;
  input [7:0]AXI_TO_PL_awlen;
  input AXI_TO_PL_awlock;
  input [2:0]AXI_TO_PL_awprot;
  input [3:0]AXI_TO_PL_awqos;
  output AXI_TO_PL_awready;
  input [2:0]AXI_TO_PL_awsize;
  input AXI_TO_PL_awuser;
  input AXI_TO_PL_awvalid;
  output [5:0]AXI_TO_PL_bid;
  input AXI_TO_PL_bready;
  output [1:0]AXI_TO_PL_bresp;
  output AXI_TO_PL_bvalid;
  output [63:0]AXI_TO_PL_rdata;
  output [5:0]AXI_TO_PL_rid;
  output AXI_TO_PL_rlast;
  input AXI_TO_PL_rready;
  output [1:0]AXI_TO_PL_rresp;
  output AXI_TO_PL_rvalid;
  input [63:0]AXI_TO_PL_wdata;
  input AXI_TO_PL_wlast;
  output AXI_TO_PL_wready;
  input [7:0]AXI_TO_PL_wstrb;
  input AXI_TO_PL_wvalid;
  input DEAL_FINISH_INT;
  output [0:0]DEAL_START_INT_tri_o;
  output GLOBAL_RESET_N;

  wire AXI_CLK;
  wire [48:0]AXI_TO_PL_araddr;
  wire [1:0]AXI_TO_PL_arburst;
  wire [3:0]AXI_TO_PL_arcache;
  wire [5:0]AXI_TO_PL_arid;
  wire [7:0]AXI_TO_PL_arlen;
  wire AXI_TO_PL_arlock;
  wire [2:0]AXI_TO_PL_arprot;
  wire [3:0]AXI_TO_PL_arqos;
  wire AXI_TO_PL_arready;
  wire [2:0]AXI_TO_PL_arsize;
  wire AXI_TO_PL_aruser;
  wire AXI_TO_PL_arvalid;
  wire [48:0]AXI_TO_PL_awaddr;
  wire [1:0]AXI_TO_PL_awburst;
  wire [3:0]AXI_TO_PL_awcache;
  wire [5:0]AXI_TO_PL_awid;
  wire [7:0]AXI_TO_PL_awlen;
  wire AXI_TO_PL_awlock;
  wire [2:0]AXI_TO_PL_awprot;
  wire [3:0]AXI_TO_PL_awqos;
  wire AXI_TO_PL_awready;
  wire [2:0]AXI_TO_PL_awsize;
  wire AXI_TO_PL_awuser;
  wire AXI_TO_PL_awvalid;
  wire [5:0]AXI_TO_PL_bid;
  wire AXI_TO_PL_bready;
  wire [1:0]AXI_TO_PL_bresp;
  wire AXI_TO_PL_bvalid;
  wire [63:0]AXI_TO_PL_rdata;
  wire [5:0]AXI_TO_PL_rid;
  wire AXI_TO_PL_rlast;
  wire AXI_TO_PL_rready;
  wire [1:0]AXI_TO_PL_rresp;
  wire AXI_TO_PL_rvalid;
  wire [63:0]AXI_TO_PL_wdata;
  wire AXI_TO_PL_wlast;
  wire AXI_TO_PL_wready;
  wire [7:0]AXI_TO_PL_wstrb;
  wire AXI_TO_PL_wvalid;
  wire DEAL_FINISH_INT;
  wire [0:0]DEAL_START_INT_tri_o;
  wire GLOBAL_RESET_N;

  system system_i
       (.AXI_CLK(AXI_CLK),
        .AXI_TO_PL_araddr(AXI_TO_PL_araddr),
        .AXI_TO_PL_arburst(AXI_TO_PL_arburst),
        .AXI_TO_PL_arcache(AXI_TO_PL_arcache),
        .AXI_TO_PL_arid(AXI_TO_PL_arid),
        .AXI_TO_PL_arlen(AXI_TO_PL_arlen),
        .AXI_TO_PL_arlock(AXI_TO_PL_arlock),
        .AXI_TO_PL_arprot(AXI_TO_PL_arprot),
        .AXI_TO_PL_arqos(AXI_TO_PL_arqos),
        .AXI_TO_PL_arready(AXI_TO_PL_arready),
        .AXI_TO_PL_arsize(AXI_TO_PL_arsize),
        .AXI_TO_PL_aruser(AXI_TO_PL_aruser),
        .AXI_TO_PL_arvalid(AXI_TO_PL_arvalid),
        .AXI_TO_PL_awaddr(AXI_TO_PL_awaddr),
        .AXI_TO_PL_awburst(AXI_TO_PL_awburst),
        .AXI_TO_PL_awcache(AXI_TO_PL_awcache),
        .AXI_TO_PL_awid(AXI_TO_PL_awid),
        .AXI_TO_PL_awlen(AXI_TO_PL_awlen),
        .AXI_TO_PL_awlock(AXI_TO_PL_awlock),
        .AXI_TO_PL_awprot(AXI_TO_PL_awprot),
        .AXI_TO_PL_awqos(AXI_TO_PL_awqos),
        .AXI_TO_PL_awready(AXI_TO_PL_awready),
        .AXI_TO_PL_awsize(AXI_TO_PL_awsize),
        .AXI_TO_PL_awuser(AXI_TO_PL_awuser),
        .AXI_TO_PL_awvalid(AXI_TO_PL_awvalid),
        .AXI_TO_PL_bid(AXI_TO_PL_bid),
        .AXI_TO_PL_bready(AXI_TO_PL_bready),
        .AXI_TO_PL_bresp(AXI_TO_PL_bresp),
        .AXI_TO_PL_bvalid(AXI_TO_PL_bvalid),
        .AXI_TO_PL_rdata(AXI_TO_PL_rdata),
        .AXI_TO_PL_rid(AXI_TO_PL_rid),
        .AXI_TO_PL_rlast(AXI_TO_PL_rlast),
        .AXI_TO_PL_rready(AXI_TO_PL_rready),
        .AXI_TO_PL_rresp(AXI_TO_PL_rresp),
        .AXI_TO_PL_rvalid(AXI_TO_PL_rvalid),
        .AXI_TO_PL_wdata(AXI_TO_PL_wdata),
        .AXI_TO_PL_wlast(AXI_TO_PL_wlast),
        .AXI_TO_PL_wready(AXI_TO_PL_wready),
        .AXI_TO_PL_wstrb(AXI_TO_PL_wstrb),
        .AXI_TO_PL_wvalid(AXI_TO_PL_wvalid),
        .DEAL_FINISH_INT(DEAL_FINISH_INT),
        .DEAL_START_INT_tri_o(DEAL_START_INT_tri_o),
        .GLOBAL_RESET_N(GLOBAL_RESET_N));
endmodule
