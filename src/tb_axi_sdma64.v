`timescale 1ns / 1ps
module tb_aq_axi_sdma64;
   // --------------------------------------------------
   // AXI4 Lite Interface
   // --------------------------------------------------
   // Reset; Clock
   reg         S_AXI_ARESETN;
   reg         S_AXI_ACLK;

   // Write Address Channel
   wire [15:0] S_AXI_AWADDR;
   wire [3:0]  S_AXI_AWCACHE;
   wire [2:0]  S_AXI_AWPROT;
   wire        S_AXI_AWVALID;
   wire        S_AXI_AWREADY;

   // Write Data Channel
   wire [31:0] S_AXI_WDATA;
   wire [3:0]  S_AXI_WSTRB;
   wire        S_AXI_WVALID;
   wire        S_AXI_WREADY;

   // Write Response Channel
   wire        S_AXI_BVALID;
   wire        S_AXI_BREADY;
   wire [1:0]  S_AXI_BRESP;

   // Read Address Channel
   wire [15:0] S_AXI_ARADDR;
   wire [3:0]  S_AXI_ARCACHE;
   wire [2:0]  S_AXI_ARPROT;
   wire        S_AXI_ARVALID;
   wire        S_AXI_ARREADY;

   // Read Data Channel
   wire [31:0] S_AXI_RDATA;
   wire [1:0]  S_AXI_RRESP;
   wire        S_AXI_RVALID;
   wire        S_AXI_RREADY;

   // --------------------------------------------------
   // AXI4 Interface(Master)
   // --------------------------------------------------
   // Reset; Clock
   reg         M_AXI_ARESETN;
   reg         M_AXI_ACLK;

   // Master Write Address
   wire [0:0]  M_AXI_AWID;
   wire [31:0] M_AXI_AWADDR;
   wire [7:0]  M_AXI_AWLEN;
   wire [2:0]  M_AXI_AWSIZE;
   wire [1:0]  M_AXI_AWBURST;
   wire        M_AXI_AWLOCK;
   wire [3:0]  M_AXI_AWCACHE;
   wire [2:0]  M_AXI_AWPROT;
   wire [3:0]  M_AXI_AWQOS;
   wire [0:0]  M_AXI_AWUSER;
   wire        M_AXI_AWVALID;
   wire        M_AXI_AWREADY;

   // Master Write Data
   wire [63:0] M_AXI_WDATA;
   wire [7:0]  M_AXI_WSTRB;
   wire        M_AXI_WLAST;
   wire [0:0]  M_AXI_WUSER;
   wire        M_AXI_WVALID;
   wire        M_AXI_WREADY;

   // Master Write Response
   wire [0:0]  M_AXI_BID;
   wire [1:0]  M_AXI_BRESP;
   wire [0:0]  M_AXI_BUSER;
   wire        M_AXI_BVALID;
   wire        M_AXI_BREADY;

   // Master Read Address
   wire [0:0]  M_AXI_ARID;
   wire [31:0] M_AXI_ARADDR;
   wire [7:0]  M_AXI_ARLEN;
   wire [2:0]  M_AXI_ARSIZE;
   wire [1:0]  M_AXI_ARBURST;
   wire [1:0]  M_AXI_ARLOCK;
   wire [3:0]  M_AXI_ARCACHE;
   wire [2:0]  M_AXI_ARPROT;
   wire [3:0]  M_AXI_ARQOS;
   wire [0:0]  M_AXI_ARUSER;
   wire        M_AXI_ARVALID;
   wire        M_AXI_ARREADY;

   // Master Read Data
   wire [0:0]  M_AXI_RID;
   wire [63:0] M_AXI_RDATA;
   wire [1:0]  M_AXI_RRESP;
   wire        M_AXI_RLAST;
   wire [0:0]  M_AXI_RUSER;
   wire        M_AXI_RVALID;
   wire        M_AXI_RREADY;

   // --------------------------------------------------
   // AXI4 Streame Interface
   // --------------------------------------------------
   reg         W_AXIS_TCLK;
   wire [63:0] W_AXIS_TDATA;
   wire        W_AXIS_TVALID;
   wire        W_AXIS_TREADY;
   wire [7:0]  W_AXIS_TSTRB;
   wire        W_AXIS_TKEEP;
   wire        W_AXIS_TLAST;

   reg         R_AXIS_TCLK;
   wire [63:0] R_AXIS_TDATA;
   wire        R_AXIS_TVALID;
   wire        R_AXIS_TREADY;
   wire [7:0]  R_AXIS_TSTRB;
   wire        R_AXIS_TKEEP;
   wire        R_AXIS_TLAST;

   // Frame Sync
   reg         W_FRAME_SYNC;
   reg         R_FRAME_SYNC;

   wire        INTERRUPT;

   wire [31:0] DEBUG;


   localparam CLK100M = 10;
   localparam CLK200M = 5;
   localparam CLK74M  = 13.184;

   // Initialize and Free for Reset
   initial begin
      S_AXI_ARESETN <= 1'b0;
      S_AXI_ACLK    <= 1'b0;
      M_AXI_ARESETN <= 1'b0;
      M_AXI_ACLK    <= 1'b0;
      W_AXIS_TCLK   <= 1'b0;
      R_AXIS_TCLK   <= 1'b0;

	  #100;

	  @(posedge S_AXI_ACLK);
      S_AXI_ARESETN <= 1'b1;
      M_AXI_ARESETN <= 1'b1;
	  $display("============================================================");
	  $display("Simulatin Start");
	  $display("============================================================");
   end

   // Clock
   always  begin
	  #(CLK100M/2) S_AXI_ACLK <= ~S_AXI_ACLK;
   end

   always  begin
	  #(CLK200M/2) M_AXI_ACLK <= ~M_AXI_ACLK;
   end

   always  begin
	  #(CLK74M/2) W_AXIS_TCLK <= ~W_AXIS_TCLK;
   end

   always  begin
	  #(CLK74M/2) R_AXIS_TCLK <= ~R_AXIS_TCLK;
   end

   // Finish
   initial begin
	  wait(S_AXI_ARADDR == 16'hFFFF);
	  $display("============================================================");
	  $display("Simulatin Finish");
	  $display("============================================================");
	  $finish();
   end

   // Fidex signal
   initial begin
      W_FRAME_SYNC = 1'b1;
      R_FRAME_SYNC = 1'b1;
   end

   reg [31:0] rdata;

   integer    i;

   reg [31:0] count;

   // Sinario
   initial begin
      count = 0;
	  wait(S_AXI_ARESETN);

	  @(posedge S_AXI_ACLK);

	  $display("============================================================");
	  $display("Process Start");
	  $display("============================================================");

      // Master Reset
      axi_ls_master.wrdata(32'h0000_0000, 32'h8000_0000);
      axi_ls_master.wrdata(32'h0000_0000, 32'h0000_0000);

      // Interrupt Mask
      axi_ls_master.wrdata(32'h0000_0008, 32'h0000_000F);

      // Start Write DMA
      axi_ls_master.wrdata(32'h0000_0010, 32'hFF00_0000);
      axi_ls_master.wrdata(32'h0000_0014, 32'h0000_1000);
      axi_ls_master.wrdata(32'h0000_000C, 32'h0000_0002);

      for (i = 0; i < 512; i = i + 1) begin
         axis_master.wrdata((64'h0011_2233_0000_0000 | count), 1'b0);
         @(posedge S_AXI_ACLK);
         count <= count +1;
         @(posedge S_AXI_ACLK);
      end
      axis_master.wrdata(64'h0011_2233_FFFF_FFFF, 1'b1);

      axis_slave.rdenable();

      // Start Read DMA
      axi_ls_master.wrdata(32'h0000_001C, 32'hFF00_0000);
      axi_ls_master.wrdata(32'h0000_0020, 32'h0000_1000);
      axi_ls_master.wrdata(32'h0000_0018, 32'h0000_0002);


	  //wait(M_AXI_RLAST);

	  repeat (1000) @(posedge S_AXI_ACLK);

      axi_ls_master.rddata(32'h0000_0004, rdata);
	  $display("============================================================");
	  $display("Interrupt: %08x", rdata);
	  $display("============================================================");

      // Finish Simulation
	  axi_ls_master.rddata(32'hFFFF_FFFF, rdata);
   end

   aq_axi_sdma64 u_aq_axi_sdma64
     (
      // --------------------------------------------------
      // AXI4 Lite Interface
      // --------------------------------------------------
      // Reset, Clock
      .S_AXI_ARESETN ( S_AXI_ARESETN ),
      .S_AXI_ACLK    ( S_AXI_ACLK    ),

      // Write Address Channel
      .S_AXI_AWADDR  ( S_AXI_AWADDR  ),
      .S_AXI_AWCACHE ( S_AXI_AWCACHE ),
      .S_AXI_AWPROT  ( S_AXI_AWPROT  ),
      .S_AXI_AWVALID ( S_AXI_AWVALID ),
      .S_AXI_AWREADY ( S_AXI_AWREADY ),

      // Write Data Channel
      .S_AXI_WDATA   ( S_AXI_WDATA   ),
      .S_AXI_WSTRB   ( S_AXI_WSTRB   ),
      .S_AXI_WVALID  ( S_AXI_WVALID  ),
      .S_AXI_WREADY  ( S_AXI_WREADY  ),

      // Write Response Channel
      .S_AXI_BVALID  ( S_AXI_BVALID  ),
      .S_AXI_BREADY  ( S_AXI_BREADY  ),
      .S_AXI_BRESP   ( S_AXI_BRESP   ),

      // Read Address Channel
      .S_AXI_ARADDR  ( S_AXI_ARADDR  ),
      .S_AXI_ARCACHE ( S_AXI_ARCACHE ),
      .S_AXI_ARPROT  ( S_AXI_ARPROT  ),
      .S_AXI_ARVALID ( S_AXI_ARVALID ),
      .S_AXI_ARREADY ( S_AXI_ARREADY ),

      // Read Data Channel
      .S_AXI_RDATA   ( S_AXI_RDATA   ),
      .S_AXI_RRESP   ( S_AXI_RRESP   ),
      .S_AXI_RVALID  ( S_AXI_RVALID  ),
      .S_AXI_RREADY  ( S_AXI_RREADY  ),

      // --------------------------------------------------
      // AXI4 Interface(Master)
      // --------------------------------------------------
      // Reset, Clock
      .M_AXI_ARESETN ( M_AXI_ARESETN ),
      .M_AXI_ACLK    ( M_AXI_ACLK    ),

      // Master Write Address
      .M_AXI_AWID    ( M_AXI_AWID    ),
      .M_AXI_AWADDR  ( M_AXI_AWADDR  ),
      .M_AXI_AWLEN   ( M_AXI_AWLEN   ),
      .M_AXI_AWSIZE  ( M_AXI_AWSIZE  ),
      .M_AXI_AWBURST ( M_AXI_AWBURST ),
      .M_AXI_AWLOCK  ( M_AXI_AWLOCK  ),
      .M_AXI_AWCACHE ( M_AXI_AWCACHE ),
      .M_AXI_AWPROT  ( M_AXI_AWPROT  ),
      .M_AXI_AWQOS   ( M_AXI_AWQOS   ),
      .M_AXI_AWUSER  ( M_AXI_AWUSER  ),
      .M_AXI_AWVALID ( M_AXI_AWVALID ),
      .M_AXI_AWREADY ( M_AXI_AWREADY ),

      // Master Write Data
      .M_AXI_WDATA   ( M_AXI_WDATA   ),
      .M_AXI_WSTRB   ( M_AXI_WSTRB   ),
      .M_AXI_WLAST   ( M_AXI_WLAST   ),
      .M_AXI_WUSER   ( M_AXI_WUSER   ),
      .M_AXI_WVALID  ( M_AXI_WVALID  ),
      .M_AXI_WREADY  ( M_AXI_WREADY  ),

      // Master Write Response
      .M_AXI_BID     ( M_AXI_BID     ),
      .M_AXI_BRESP   ( M_AXI_BRESP   ),
      .M_AXI_BUSER   ( M_AXI_BUSER   ),
      .M_AXI_BVALID  ( M_AXI_BVALID  ),
      .M_AXI_BREADY  ( M_AXI_BREADY  ),

      // Master Read Address
      .M_AXI_ARID    ( M_AXI_ARID    ),
      .M_AXI_ARADDR  ( M_AXI_ARADDR  ),
      .M_AXI_ARLEN   ( M_AXI_ARLEN   ),
      .M_AXI_ARSIZE  ( M_AXI_ARSIZE  ),
      .M_AXI_ARBURST ( M_AXI_ARBURST ),
      .M_AXI_ARLOCK  ( M_AXI_ARLOCK  ),
      .M_AXI_ARCACHE ( M_AXI_ARCACHE ),
      .M_AXI_ARPROT  ( M_AXI_ARPROT  ),
      .M_AXI_ARQOS   ( M_AXI_ARQOS   ),
      .M_AXI_ARUSER  ( M_AXI_ARUSER  ),
      .M_AXI_ARVALID ( M_AXI_ARVALID ),
      .M_AXI_ARREADY ( M_AXI_ARREADY ),

      // Master Read Data
      .M_AXI_RID     ( M_AXI_RID     ),
      .M_AXI_RDATA   ( M_AXI_RDATA   ),
      .M_AXI_RRESP   ( M_AXI_RRESP   ),
      .M_AXI_RLAST   ( M_AXI_RLAST   ),
      .M_AXI_RUSER   ( M_AXI_RUSER   ),
      .M_AXI_RVALID  ( M_AXI_RVALID  ),
      .M_AXI_RREADY  ( M_AXI_RREADY  ),

      // --------------------------------------------------
      // AXI4 Streame Interface
      // --------------------------------------------------
      .W_AXIS_TCLK   ( W_AXIS_TCLK   ),
      .W_AXIS_TDATA  ( W_AXIS_TDATA  ),
      .W_AXIS_TVALID ( W_AXIS_TVALID ),
      .W_AXIS_TREADY ( W_AXIS_TREADY ),
      .W_AXIS_TSTRB  ( W_AXIS_TSTRB  ),
      .W_AXIS_TKEEP  ( W_AXIS_TKEEP  ),
      .W_AXIS_TLAST  ( W_AXIS_TLAST  ),

      .R_AXIS_TCLK   ( R_AXIS_TCLK   ),
      .R_AXIS_TDATA  ( R_AXIS_TDATA  ),
      .R_AXIS_TVALID ( R_AXIS_TVALID ),
      .R_AXIS_TREADY ( R_AXIS_TREADY ),
      .R_AXIS_TSTRB  ( R_AXIS_TSTRB  ),
      .R_AXIS_TKEEP  ( R_AXIS_TKEEP  ),
      .R_AXIS_TLAST  ( R_AXIS_TLAST  ),

      // Frame Sync
      .W_FRAME_SYNC  ( W_FRAME_SYNC  ),
      .R_FRAME_SYNC  ( R_FRAME_SYNC  ),

      .INTERRUPT     ( INTERRUPT     ),

      .DEBUG         ( DEBUG         )
   );

   tb_axi_ls_master_model axi_ls_master
     (
      // Reset, Clock
      .ARESETN       ( S_AXI_ARESETN ),
      .ACLK          ( S_AXI_ACLK    ),

      // Write Address Channel
      .S_AXI_AWADDR  ( S_AXI_AWADDR  ),
      .S_AXI_AWCACHE ( S_AXI_AWCACHE ),
      .S_AXI_AWPROT  ( S_AXI_AWPROT  ),
      .S_AXI_AWVALID ( S_AXI_AWVALID ),
      .S_AXI_AWREADY ( S_AXI_AWREADY ),

      // Write Data Channel
      .S_AXI_WDATA   ( S_AXI_WDATA   ),
      .S_AXI_WSTRB   ( S_AXI_WSTRB   ),
      .S_AXI_WVALID  ( S_AXI_WVALID  ),
      .S_AXI_WREADY  ( S_AXI_WREADY  ),

      // Write Response Channel
      .S_AXI_BVALID  ( S_AXI_BVALID  ),
      .S_AXI_BREADY  ( S_AXI_BREADY  ),
      .S_AXI_BRESP   ( S_AXI_BRESP   ),

      // Read Address Channe
      .S_AXI_ARADDR  ( S_AXI_ARADDR  ),
      .S_AXI_ARCACHE ( S_AXI_ARCACHE ),
      .S_AXI_ARPROT  ( S_AXI_ARPROT  ),
      .S_AXI_ARVALID ( S_AXI_ARVALID ),
      .S_AXI_ARREADY ( S_AXI_ARREADY ),

      // Read Data Channel
      .S_AXI_RDATA   ( S_AXI_RDATA   ),
      .S_AXI_RRESP   ( S_AXI_RRESP   ),
      .S_AXI_RVALID  ( S_AXI_RVALID  ),
      .S_AXI_RREADY  ( S_AXI_RREADY  )
      );

   tb_axi_slave_model axi_slave
     (
      // Reset, Clock
      .ARESETN       ( M_AXI_ARESETN ),
      .ACLK          ( M_AXI_ACLK    ),

      // Master Write Address
      .M_AXI_AWID    ( M_AXI_AWID    ),
      .M_AXI_AWADDR  ( M_AXI_AWADDR  ),
      .M_AXI_AWLEN   ( M_AXI_AWLEN   ),
      .M_AXI_AWSIZE  ( M_AXI_AWSIZE  ),
      .M_AXI_AWBURST ( M_AXI_AWBURST ),
      .M_AXI_AWLOCK  ( M_AXI_AWLOCK  ),
      .M_AXI_AWCACHE ( M_AXI_AWCACHE ),
      .M_AXI_AWPROT  ( M_AXI_AWPROT  ),
      .M_AXI_AWQOS   ( M_AXI_AWQOS   ),
      .M_AXI_AWUSER  ( M_AXI_AWUSER  ),
      .M_AXI_AWVALID ( M_AXI_AWVALID ),
      .M_AXI_AWREADY ( M_AXI_AWREADY ),

      // Master Write Data
      .M_AXI_WDATA   ( M_AXI_WDATA   ),
      .M_AXI_WSTRB   ( M_AXI_WSTRB   ),
      .M_AXI_WLAST   ( M_AXI_WLAST   ),
      .M_AXI_WUSER   ( M_AXI_WUSER   ),
      .M_AXI_WVALID  ( M_AXI_WVALID  ),
      .M_AXI_WREADY  ( M_AXI_WREADY  ),

      // Master Write Response
      .M_AXI_BID     ( M_AXI_BID     ),
      .M_AXI_BRESP   ( M_AXI_BRESP   ),
      .M_AXI_BUSER   ( M_AXI_BUSER   ),
      .M_AXI_BVALID  ( M_AXI_BVALID  ),
      .M_AXI_BREADY  ( M_AXI_BREADY  ),

      // Master Read Address
      .M_AXI_ARID    ( M_AXI_ARID    ),
      .M_AXI_ARADDR  ( M_AXI_ARADDR  ),
      .M_AXI_ARLEN   ( M_AXI_ARLEN   ),
      .M_AXI_ARSIZE  ( M_AXI_ARSIZE  ),
      .M_AXI_ARBURST ( M_AXI_ARBURST ),
      // .M_AXI_ARLOCK(),
      .M_AXI_ARLOCK  ( M_AXI_ARLOCK  ),
      .M_AXI_ARCACHE ( M_AXI_ARCACHE ),
      .M_AXI_ARPROT  ( M_AXI_ARPROT  ),
      .M_AXI_ARQOS   ( M_AXI_ARQOS   ),
      .M_AXI_ARUSER  ( M_AXI_ARUSER  ),
      .M_AXI_ARVALID ( M_AXI_ARVALID ),
      .M_AXI_ARREADY ( M_AXI_ARREADY ),

      // Master Read Data
      .M_AXI_RID     ( M_AXI_RID     ),
      .M_AXI_RDATA   ( M_AXI_RDATA   ),
      .M_AXI_RRESP   ( M_AXI_RRESP   ),
      .M_AXI_RLAST   ( M_AXI_RLAST   ),
      .M_AXI_RUSER   ( M_AXI_RUSER   ),
      .M_AXI_RVALID  ( M_AXI_RVALID  ),
      .M_AXI_RREADY  ( M_AXI_RREADY  )
      );

   axis_master_model axis_master
     (
      .W_AXIS_TCLK   ( W_AXIS_TCLK   ),
      .W_AXIS_TDATA  ( W_AXIS_TDATA  ),
      .W_AXIS_TVALID ( W_AXIS_TVALID ),
      .W_AXIS_TREADY ( W_AXIS_TREADY ),
      .W_AXIS_TSTRB  ( W_AXIS_TSTRB  ),
      .W_AXIS_TKEEP  ( W_AXIS_TKEEP  ),
      .W_AXIS_TLAST  ( W_AXIS_TLAST  )
   );

   axis_slave_model axis_slave
     (
      .R_AXIS_TCLK   ( R_AXIS_TCLK   ),
      .R_AXIS_TDATA  ( R_AXIS_TDATA  ),
      .R_AXIS_TVALID ( R_AXIS_TVALID ),
      .R_AXIS_TREADY ( R_AXIS_TREADY ),
      .R_AXIS_TSTRB  ( R_AXIS_TSTRB  ),
      .R_AXIS_TKEEP  ( R_AXIS_TKEEP  ),
      .R_AXIS_TLAST  ( R_AXIS_TLAST  )
      );

endmodule
