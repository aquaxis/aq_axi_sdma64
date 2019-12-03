/*
 * Copyright (C)2014-2017 AQUAXIS TECHNOLOGY.
 *  Don't remove this header.
 * When you use this source, there is a need to inherit this header.
 *
 * License
 *  For no commercial -
 *   License:     The Open Software License 3.0
 *   License URI: http://www.opensource.org/licenses/OSL-3.0
 *
 *  For commmercial -
 *   License:     AQUAXIS License 1.0
 *   License URI: http://www.aquaxis.com/licenses
 *
 * For further information please contact.
 *	URI:    http://www.aquaxis.com/
 *	E-Mail: info(at)aquaxis.com
 */
module aq_axi_sdma64
  (
   // --------------------------------------------------
   // AXI4 Lite Interface
   // --------------------------------------------------
   // Reset, Clock
   input         S_AXI_ARESETN,
   input         S_AXI_ACLK,

   // Write Address Channel
   input [15:0]  S_AXI_AWADDR,
   input [3:0]   S_AXI_AWCACHE, // 4'b0011
   input [2:0]   S_AXI_AWPROT, // 3'b000
   input         S_AXI_AWVALID,
   output        S_AXI_AWREADY,

   // Write Data Channel
   input [31:0]  S_AXI_WDATA,
   input [3:0]   S_AXI_WSTRB,
   input         S_AXI_WVALID,
   output        S_AXI_WREADY,

   // Write Response Channel
   output        S_AXI_BVALID,
   input         S_AXI_BREADY,
   output [1:0]  S_AXI_BRESP,

   // Read Address Channel
   input [15:0]  S_AXI_ARADDR,
   input [3:0]   S_AXI_ARCACHE, // 4'b0011
   input [2:0]   S_AXI_ARPROT, // 3'b000
   input         S_AXI_ARVALID,
   output        S_AXI_ARREADY,

   // Read Data Channel
   output [31:0] S_AXI_RDATA,
   output [1:0]  S_AXI_RRESP,
   output        S_AXI_RVALID,
   input         S_AXI_RREADY,

   // --------------------------------------------------
   // AXI4 Interface(Master)
   // --------------------------------------------------
   // Reset, Clock
   input         M_AXI_ARESETN,
   input         M_AXI_ACLK,

   // Master Write Address
   output [0:0]  M_AXI_AWID,
   output [31:0] M_AXI_AWADDR,
   output [7:0]  M_AXI_AWLEN,
   output [2:0]  M_AXI_AWSIZE,
   output [1:0]  M_AXI_AWBURST,
   output        M_AXI_AWLOCK,
   output [3:0]  M_AXI_AWCACHE,
   output [2:0]  M_AXI_AWPROT,
   output [3:0]  M_AXI_AWQOS,
   output [0:0]  M_AXI_AWUSER,
   output        M_AXI_AWVALID,
   input         M_AXI_AWREADY,

   // Master Write Data
   output [63:0] M_AXI_WDATA,
   output [7:0]  M_AXI_WSTRB,
   output        M_AXI_WLAST,
   output [0:0]  M_AXI_WUSER,
   output        M_AXI_WVALID,
   input         M_AXI_WREADY,

   // Master Write Response
   input [0:0]   M_AXI_BID,
   input [1:0]   M_AXI_BRESP,
   input [0:0]   M_AXI_BUSER,
   input         M_AXI_BVALID,
   output        M_AXI_BREADY,

   // Master Read Address
   output [0:0]  M_AXI_ARID,
   output [31:0] M_AXI_ARADDR,
   output [7:0]  M_AXI_ARLEN,
   output [2:0]  M_AXI_ARSIZE,
   output [1:0]  M_AXI_ARBURST,
   output [1:0]  M_AXI_ARLOCK,
   output [3:0]  M_AXI_ARCACHE,
   output [2:0]  M_AXI_ARPROT,
   output [3:0]  M_AXI_ARQOS,
   output [0:0]  M_AXI_ARUSER,
   output        M_AXI_ARVALID,
   input         M_AXI_ARREADY,

   // Master Read Data
   input [0:0]   M_AXI_RID,
   input [63:0]  M_AXI_RDATA,
   input [1:0]   M_AXI_RRESP,
   input         M_AXI_RLAST,
   input [0:0]   M_AXI_RUSER,
   input         M_AXI_RVALID,
   output        M_AXI_RREADY,

   // --------------------------------------------------
   // AXI4 Streame Interface
   // --------------------------------------------------
   input         W_AXIS_TCLK,
   input [63:0]  W_AXIS_TDATA,
   input         W_AXIS_TVALID,
   output        W_AXIS_TREADY,
   input [7:0]   W_AXIS_TSTRB,
   input         W_AXIS_TKEEP,
   input         W_AXIS_TLAST,

   input         R_AXIS_TCLK,
   output [63:0] R_AXIS_TDATA,
   output        R_AXIS_TVALID,
   input         R_AXIS_TREADY,
   output [7:0]  R_AXIS_TSTRB,
   output        R_AXIS_TKEEP,
   output        R_AXIS_TLAST,

   // Frame Sync
   input         W_FRAME_SYNC,
   input         R_FRAME_SYNC,

   // Intertrupt
   output        INTERRUPT,

   output [31:0] DEBUG
   );

   wire [31:0]   debug_ls, debug_slave, debug_ctl, debug_master;

   wire          aq_local_clk;
   wire          aq_local_cs;
   wire          aq_local_rnw;
   wire          aq_local_ack;
   wire [15:0]   aq_local_addr;
   wire [3:0]    aq_local_be;
   wire [31:0]   aq_local_wdata;
   wire [31:0]   aq_local_rdata;

   // AXI Lite Slave Interface
   aq_axi_sdma64_ls u_aq_axi_sdma64_ls
     (
      // AXI4 Lite Interface
      .ARESETN        ( S_AXI_ARESETN  ),
      .ACLK           ( S_AXI_ACLK     ),

      // Write Address Channel
      .S_AXI_AWADDR   ( S_AXI_AWADDR   ),
      .S_AXI_AWCACHE  ( S_AXI_AWCACHE  ),
      .S_AXI_AWPROT   ( S_AXI_AWPROT   ),
      .S_AXI_AWVALID  ( S_AXI_AWVALID  ),
      .S_AXI_AWREADY  ( S_AXI_AWREADY  ),

      // Write Data Channel
      .S_AXI_WDATA    ( S_AXI_WDATA    ),
      .S_AXI_WSTRB    ( S_AXI_WSTRB    ),
      .S_AXI_WVALID   ( S_AXI_WVALID   ),
      .S_AXI_WREADY   ( S_AXI_WREADY   ),

      // Write Response Channel
      .S_AXI_BVALID   ( S_AXI_BVALID   ),
      .S_AXI_BREADY   ( S_AXI_BREADY   ),
      .S_AXI_BRESP    ( S_AXI_BRESP    ),

      // Read Address Channel
      .S_AXI_ARADDR   ( S_AXI_ARADDR   ),
      .S_AXI_ARCACHE  ( S_AXI_ARCACHE  ),
      .S_AXI_ARPROT   ( S_AXI_ARPROT   ),
      .S_AXI_ARVALID  ( S_AXI_ARVALID  ),
      .S_AXI_ARREADY  ( S_AXI_ARREADY  ),

      // Read Data Channel
      .S_AXI_RDATA    ( S_AXI_RDATA    ),
      .S_AXI_RRESP    ( S_AXI_RRESP    ),
      .S_AXI_RVALID   ( S_AXI_RVALID   ),
      .S_AXI_RREADY   ( S_AXI_RREADY   ),

      // Local Interface
      .AQ_LOCAL_CLK   ( aq_local_clk   ),
      .AQ_LOCAL_CS    ( aq_local_cs    ),
      .AQ_LOCAL_RNW   ( aq_local_rnw   ),
      .AQ_LOCAL_ACK   ( aq_local_ack   ),
      .AQ_LOCAL_ADDR  ( aq_local_addr  ),
      .AQ_LOCAL_BE    ( aq_local_be    ),
      .AQ_LOCAL_WDATA ( aq_local_wdata ),
      .AQ_LOCAL_RDATA ( aq_local_rdata ),

      .DEBUG          ( debug_ls       )
      );

   wire          wr_start;
   wire [31:0]   wr_adrs;
   wire [31:0]   wr_len;
   wire          wr_ready;
   wire          wr_last;
   wire          wr_int;
   wire          wr_fifo_re;
   wire          wr_fifo_empty;
   wire          wr_fifo_aempty;
   wire [63:0]   wr_fifo_data;

   wire          rd_start;
   wire [31:0]   rd_adrs;
   wire [31:0]   rd_len;
   wire          rd_ready;
   wire          rd_last;
   wire          rd_int;
   wire          rd_fifo_we;
   wire          rd_fifo_full;
   wire          rd_fifo_afull;
   wire [63:0]   rd_fifo_data;

   wire          master_rst;
   wire [31:0]   master_status;

   reg [31:0]    wr_fifo_wrcnt, wr_fifo_rdcnt, rd_fifo_wrcnt, rd_fifo_rdcnt;

   wire          wr_fsync_start;
   wire          rd_fsync_start;

   assign wr_fsync_start = (wr_start & W_FRAME_SYNC);
   assign rd_fsync_start = (rd_start & R_FRAME_SYNC);

   aq_axi_sdma64_intreg u_aq_axi_sdma64_intreg
     (
      .RST_N ( M_AXI_ARESETN ),

      .CLKA  ( W_AXIS_TCLK   ),
      .DIN   ( W_AXIS_TLAST  ),

      .CLKB  ( M_AXI_ACLK    ),
      .DOUT  ( wr_last       )
      );

   wire          wr_int_r, rd_int_r;
   aq_axi_sdma64_intreg u_aq_axi_sdma64_wr_int
     (
      .RST_N ( M_AXI_ARESETN ),

      .CLKA  ( M_AXI_ACLK    ),
      .DIN   ( wr_int        ),

      .CLKB  ( S_AXI_ACLK    ),
      .DOUT  ( wr_int_r      )
      );
   aq_axi_sdma64_intreg u_aq_axi_sdma64_rd_int
     (
      .RST_N ( M_AXI_ARESETN ),

      .CLKA  ( M_AXI_ACLK    ),
      .DIN   ( rd_int        ),

      .CLKB  ( S_AXI_ACLK    ),
      .DOUT  ( rd_int_r      )
      );

   aq_axi_sdma64_master u_aq_axi_sdma64_master
     (
      .ARESETN       ( M_AXI_ARESETN  ),
      .ACLK          ( M_AXI_ACLK     ),

      .M_AXI_AWID    ( M_AXI_AWID     ),
      .M_AXI_AWADDR  ( M_AXI_AWADDR   ),
      .M_AXI_AWLEN   ( M_AXI_AWLEN    ),
      .M_AXI_AWSIZE  ( M_AXI_AWSIZE   ),
      .M_AXI_AWBURST ( M_AXI_AWBURST  ),
      .M_AXI_AWLOCK  ( M_AXI_AWLOCK   ),
      .M_AXI_AWCACHE ( M_AXI_AWCACHE  ),
      .M_AXI_AWPROT  ( M_AXI_AWPROT   ),
      .M_AXI_AWQOS   ( M_AXI_AWQOS    ),
      .M_AXI_AWUSER  ( M_AXI_AWUSER   ),
      .M_AXI_AWVALID ( M_AXI_AWVALID  ),
      .M_AXI_AWREADY ( M_AXI_AWREADY  ),

      .M_AXI_WDATA   ( M_AXI_WDATA    ),
      .M_AXI_WSTRB   ( M_AXI_WSTRB    ),
      .M_AXI_WLAST   ( M_AXI_WLAST    ),
      .M_AXI_WUSER   ( M_AXI_WUSER    ),
      .M_AXI_WVALID  ( M_AXI_WVALID   ),
      .M_AXI_WREADY  ( M_AXI_WREADY   ),

      .M_AXI_BID     ( M_AXI_BID      ),
      .M_AXI_BRESP   ( M_AXI_BRESP    ),
      .M_AXI_BUSER   ( M_AXI_BUSER    ),
      .M_AXI_BVALID  ( M_AXI_BVALID   ),
      .M_AXI_BREADY  ( M_AXI_BREADY   ),

      .M_AXI_ARID    ( M_AXI_ARID     ),
      .M_AXI_ARADDR  ( M_AXI_ARADDR   ),
      .M_AXI_ARLEN   ( M_AXI_ARLEN    ),
      .M_AXI_ARSIZE  ( M_AXI_ARSIZE   ),
      .M_AXI_ARBURST ( M_AXI_ARBURST  ),
      .M_AXI_ARLOCK  ( M_AXI_ARLOCK   ),
      .M_AXI_ARCACHE ( M_AXI_ARCACHE  ),
      .M_AXI_ARPROT  ( M_AXI_ARPROT   ),
      .M_AXI_ARQOS   ( M_AXI_ARQOS    ),
      .M_AXI_ARUSER  ( M_AXI_ARUSER   ),
      .M_AXI_ARVALID ( M_AXI_ARVALID  ),
      .M_AXI_ARREADY ( M_AXI_ARREADY  ),

      .M_AXI_RID     ( M_AXI_RID      ),
      .M_AXI_RDATA   ( M_AXI_RDATA    ),
      .M_AXI_RRESP   ( M_AXI_RRESP    ),
      .M_AXI_RLAST   ( M_AXI_RLAST    ),
      .M_AXI_RUSER   ( M_AXI_RUSER    ),
      .M_AXI_RVALID  ( M_AXI_RVALID   ),
      .M_AXI_RREADY  ( M_AXI_RREADY   ),

      .MASTER_RST    ( master_rst     ),

      .WR_START      ( wr_fsync_start ),
      .WR_ADRS       ( wr_adrs        ),
      .WR_LEN        ( wr_len         ),
      .WR_READY      ( wr_ready       ),
      .WR_LAST       ( wr_last        ),
      .WR_INT        ( wr_int         ),
      .WR_FIFO_RE    ( wr_fifo_re     ),
      .WR_FIFO_EMPTY ( wr_fifo_empty  ),
      .WR_FIFO_AEMPTY( wr_fifo_aempty ),
      .WR_FIFO_DATA  ( wr_fifo_data   ),

      .RD_START      ( rd_fsync_start ),
      .RD_ADRS       ( rd_adrs        ),
      .RD_LEN        ( rd_len         ),
      .RD_READY      ( rd_ready       ),
      .RD_LAST       ( rd_last        ),
      .RD_INT        ( rd_int         ),
      .RD_FIFO_WE    ( rd_fifo_we     ),
      .RD_FIFO_FULL  ( rd_fifo_full   ),
      .RD_FIFO_AFULL ( rd_fifo_afull  ),
      .RD_FIFO_DATA  ( rd_fifo_data   ),

      .DEBUG         ( debug_master   )
    );

   // Read FIFO
   wire          rfifo_enable, rfifo_empty;
   aq_axi_sdma64_fifo u_aq_axi_sdma64_rfifo
     (
      .RST     ( master_rst    ),

      .WRCLK   ( M_AXI_ACLK    ),
      .WREN    ( rd_fifo_we    ),
      .DI      ( {rd_last, rd_fifo_data} ),
      .FULL    ( rd_fifo_full  ),
      .AFULL   ( rd_fifo_afull ),
      .WRCOUNT (),

      .RDCLK   ( R_AXIS_TCLK   ),
      .RDEN    ( rfifo_enable  ),
      .DO      ( {R_AXIS_TLAST, R_AXIS_TDATA} ),
      .EMPTY   ( rfifo_empty   ),
      .AEMPTY  (),
      .RDCOUNT ()
    );
   assign rfifo_enable  = (R_AXIS_TREADY & ~rfifo_empty);
   assign R_AXIS_TVALID = rfifo_enable;

   // Write FIFO
   wire wfifo_full;
   aq_axi_sdma64_fifo u_aq_axi_sdma64_wfifo
     (
      .RST     ( master_rst     ),

      .WRCLK   ( W_AXIS_TCLK    ),
      .WREN    ( W_AXIS_TVALID  ),
      .DI      ( {W_AXIS_TLAST, W_AXIS_TDATA} ),
      .FULL    ( wfifo_full     ),
      .AFULL   (),
      .WRCOUNT (),

      .RDCLK   ( M_AXI_ACLK     ),
      .RDEN    ( wr_fifo_re     ),
      .DO      ( {wr_fifo_last, wr_fifo_data} ),
      .EMPTY   ( wr_fifo_empty  ),
      .AEMPTY  ( wr_fifo_aempty ),
      .RDCOUNT ()
    );
   assign W_AXIS_TREADY = ~wfifo_full;

   // Control(Local Register)
   aq_axi_dma64_ctrl u_aq_axi_sdma64_ctrl
     (
      .RST_N          ( S_AXI_ARESETN    ),

      .AQ_LOCAL_CLK   ( aq_local_clk     ),
      .AQ_LOCAL_CS    ( aq_local_cs      ),
      .AQ_LOCAL_RNW   ( aq_local_rnw     ),
      .AQ_LOCAL_ACK   ( aq_local_ack     ),
      .AQ_LOCAL_ADDR  ( aq_local_addr    ),
      .AQ_LOCAL_BE    ( aq_local_be      ),
      .AQ_LOCAL_WDATA ( aq_local_wdata   ),
      .AQ_LOCAL_RDATA ( aq_local_rdata   ),

      .INTERRUPT      ( INTERRUPT        ),

      .MASTER_RST     ( master_rst       ),

      .WR_START       ( wr_start         ),
      .WR_ADRS        ( wr_adrs          ),
      .WR_COUNT       ( wr_len           ),
      .WR_READY       ( wr_ready         ),
      .WR_INT         ( wr_int_r         ),
      .WR_FIFO_EMPTY  ( wr_fifo_empty    ),
      .WR_FIFO_AEMPTY ( wr_fifo_aempty   ),
      .WR_FIFO_FULL   ( FIFO_FULL        ),
      .WR_FIFO_AFULL  ( 1'b0             ),

      .RD_START       ( rd_start         ),
      .RD_ADRS        ( rd_adrs          ),
      .RD_COUNT       ( rd_len           ),
      .RD_READY       ( rd_ready         ),
      .RD_INT         ( rd_int_r         ),
      .RD_FIFO_EMPTY  ( FIFO_EMPTY       ),
      .RD_FIFO_AEMPTY ( 1'b0             ),
      .RD_FIFO_FULL   ( rd_fifo_full     ),
      .RD_FIFO_AFULL  ( rd_fifo_afull    ),

      .DEBUG          ( debug_ctl        )
    );

    assign DEBUG[31:0] = debug_ls;
endmodule
