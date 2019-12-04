/*
 * AXI4 Lite Slave
 *
 * Copyright (C)2014-2019 AQUAXIS TECHNOLOGY.
 *  Don't remove this header.
 * When you use this source, there is a need to inherit this header.
 *
 * License: MIT License
 *
 * For further information please contact.
 *	URI:    http://www.aquaxis.com/
 *	E-Mail: info(at)aquaxis.com
 */
module aq_axi_sdma64_ctrl
(
  // AXI4 Lite Interface
  input         ARESETN,
  input         ACLK,

  // Write Address Channel
  input [31:0]  S_AXI_AWADDR,
  input [3:0]   S_AXI_AWCACHE,
  input [2:0]   S_AXI_AWPROT,
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
  input [31:0]  S_AXI_ARADDR,
  input [3:0]   S_AXI_ARCACHE,
  input [2:0]   S_AXI_ARPROT,
  input         S_AXI_ARVALID,
  output        S_AXI_ARREADY,

  // Read Data Channel
  output [31:0] S_AXI_RDATA,
  output [1:0]  S_AXI_RRESP,
  output        S_AXI_RVALID,
  input         S_AXI_RREADY,

  // Local Interface
  output        INTERRUPT,

  output        MASTER_RST,

  output        WR_START,
  output [31:0] WR_ADRS,
  output [31:0] WR_COUNT,
  input         WR_READY,
  input         WR_INT,
  input         WR_FIFO_EMPTY,
  input         WR_FIFO_AEMPTY,
  input         WR_FIFO_FULL,
  input         WR_FIFO_AFULL,

  output        RD_START,
  output [31:0] RD_ADRS,
  output [31:0] RD_COUNT,
  input         RD_READY,
  input         RD_INT,
  input         RD_FIFO_EMPTY,
  input         RD_FIFO_AEMPTY,
  input         RD_FIFO_FULL,
  input         RD_FIFO_AFULL,

  output [31:0] DEBUG
);

/*
  CACHE[3:0]
    WA RA C  B
    0  0  0  0 Noncacheable and nonbufferable
    0  0  0  1 Bufferable only
    0  0  1  0 Cacheable, but do not allocate
   *0  0  1  1 Cacheable and Bufferable, but do not allocate
    0  1  1  0 Cacheable write-through, allocate on reads only
    0  1  1  1 Cacheable write-back, allocate on reads only
    1  0  1  0 Cacheable write-through, allocate on write only
    1  0  1  1 Cacheable write-back, allocate on writes only
    1  1  1  0 Cacheable write-through, allocate on both reads and writes
    1  1  1  1 Cacheable write-back, allocate on both reads and writes

  PROR[2:0]
    [2]:0:Data Access(*)
        1:Instruction Access
    [1]:0:Secure Access(*)
        1:NoSecure Access
    [0]:0:Privileged Access(*)
        1:Normal Access

  RESP[1:0]
    00: OK
    01: EXOK
    10: SLVERR
    11: DECERR
*/

  localparam S_IDLE   = 2'd0;
  localparam S_WRITE  = 2'd1;
  localparam S_WRITE2 = 2'd2;
  localparam S_READ   = 2'd3;

  reg [1:0]     state;
  reg           reg_rnw;
  reg [31:0]    reg_addr, reg_wdata;
  reg [3:0]     reg_be;
  reg           reg_wallready;

  wire          local_cs, local_rnw, local_ack;
  wire [3:0]    local_be;
  wire [31:0]   local_addr, local_wdata, local_rdata;

  always @( posedge ACLK or negedge ARESETN ) begin
    if( !ARESETN ) begin
      state         <= S_IDLE;
      reg_rnw       <= 1'b0;
      reg_addr      <= 32'd0;
      reg_wdata     <= 32'd0;
      reg_be        <= 4'd0;
      reg_wallready <= 1'b0;
    end else begin
      // Receive wdata
      if( S_AXI_WVALID ) begin
        reg_wdata     <= S_AXI_WDATA;
        reg_be        <= S_AXI_WSTRB;
        reg_wallready <= 1'b1;
      end else if( local_ack & S_AXI_BREADY ) begin
        reg_wallready <= 1'b0;
      end

      // Address state
      case( state )
        S_IDLE: begin
          if( S_AXI_AWVALID ) begin
            reg_rnw   <= 1'b0;
            reg_addr  <= S_AXI_AWADDR;
            state     <= S_WRITE;
          end else if( S_AXI_ARVALID ) begin
            reg_rnw   <= 1'b1;
            reg_addr  <= S_AXI_ARADDR;
            state     <= S_READ;
          end
        end
        S_WRITE: begin
          if( reg_wallready ) begin
            state     <= S_WRITE2;
          end
        end
        S_WRITE2: begin
          if( local_ack & S_AXI_BREADY ) begin
            state     <= S_IDLE;
          end
        end
        S_READ: begin
          if( local_ack & S_AXI_RREADY ) begin
            state     <= S_IDLE;
          end
        end
        default: state <= S_IDLE;
      endcase
    end
  end

  // Write Channel
  assign S_AXI_AWREADY  = ( state == S_WRITE || state == S_IDLE )?1'b1:1'b0;
  assign S_AXI_WREADY   = ( state == S_WRITE || state == S_IDLE )?1'b1:1'b0;
  assign S_AXI_BVALID   = ( state == S_WRITE2 )?local_ack:1'b0;
  assign S_AXI_BRESP    = 2'b00;

  // Read Channel
  assign S_AXI_ARREADY  = ( state == S_READ  || state == S_IDLE )?1'b1:1'b0;
  assign S_AXI_RVALID   = ( state == S_READ )?local_ack:1'b0;
  assign S_AXI_RRESP    = 2'b00;
  assign S_AXI_RDATA    = ( state == S_READ )?local_rdata:32'd0;

  // Local Interface
  wire          wr_ena, rd_ena, wr_ack;
  reg           rd_ack;
  reg [31:0]    reg_rdata;

  assign local_cs           = (( state == S_WRITE2 )?1'b1:1'b0) | (( state == S_READ )?1'b1:1'b0) | 1'b0;
  assign local_rnw          = reg_rnw;
  assign local_addr[31:0]   = reg_addr[31:0];
  assign local_be[3:0]      = reg_be[3:0];
  assign local_wdata[31:0]  = reg_wdata[31:0];
  assign local_ack          = wr_ack | rd_ack;
  assign local_rdata[31:0]  = reg_rdata[31:0];

  assign wr_ena = (local_cs & ~local_rnw)?1'b1:1'b0;
  assign rd_ena = (local_cs &  local_rnw)?1'b1:1'b0;
  assign wr_ack = wr_ena;

  // Local Register
  localparam A_STATUS        = 8'h00;
  localparam A_INT_STATUS    = 8'h04;
  localparam A_INT_MASK      = 8'h08;

  localparam A_WR_START      = 8'h10;
  localparam A_WR_ADRS       = 8'h14;
  localparam A_WR_COUNT      = 8'h18;
  localparam A_RD_START      = 8'h20;
  localparam A_RD_ADRS       = 8'h24;
  localparam A_RD_COUNT      = 8'h28;

  localparam A_TESTDATA      = 8'h30;
  localparam A_DEBUG         = 8'h34;

  reg           reg_master_reset;
  reg           reg_wr_start1, reg_rd_start1;
  reg           reg_wr_start2, reg_rd_start2;
  reg [31:0]    reg_wr_adrs, reg_rd_adrs;
  reg [31:0]    reg_wr_count, reg_rd_count;
  reg [31:0]    reg_testdata;
  reg [31:0]    reg_int_mask;
  reg [31:0]    reg_int;

  // Write Register
  always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
      reg_master_reset   <= 1'b0;
      reg_wr_adrs[31:0]  <= 32'd0;
      reg_wr_count[31:0] <= 32'd0;
      reg_rd_adrs[31:0]  <= 32'd0;
      reg_rd_count[31:0] <= 32'd0;
      reg_wr_start1      <= 1'b0;
      reg_wr_start2      <= 1'b0;
      reg_rd_start1      <= 1'b0;
      reg_rd_start2      <= 1'b0;
      reg_int_mask[31:0] <= 32'd0;
      reg_int[31:0]      <= 32'd0;
      reg_testdata[31:0] <= 32'd0;
    end else begin
      if(wr_ena) begin
        case(local_addr[7:0] & 8'hFC)
          A_STATUS: begin
            reg_master_reset <= local_wdata[31];
          end
          A_INT_MASK: begin
            reg_int_mask[31:0] <= local_wdata[31:0];
          end
          A_WR_START: begin
            reg_wr_start2 <= local_wdata[1];
          end
          A_WR_ADRS: begin
            reg_wr_adrs[31:0] <= local_wdata[31:0];
          end
          A_WR_COUNT: begin
            reg_wr_count[31:0] <= local_wdata[31:0];
          end
          A_RD_START: begin
            reg_rd_start2 <= local_wdata[1];
          end
          A_RD_ADRS: begin
            reg_rd_adrs[31:0] <= local_wdata[31:0];
          end
          A_RD_COUNT: begin
            reg_rd_count[31:0] <= local_wdata[31:0];
          end
          A_TESTDATA: begin
            reg_testdata[31:0] <= local_wdata[31:0];
          end
          default: begin
          end
        endcase
      end

      // One shot Write DMA
      if(!WR_READY) begin
        reg_wr_start1 <= 1'b0;
      end else if(wr_ena && ((local_addr[7:0] & 8'hFC) == A_WR_START)) begin
        reg_wr_start1 <= local_wdata[0];
      end
      // One shot Read DMA
      if(!RD_READY) begin
        reg_rd_start1 <= 1'b0;
      end else if(wr_ena && ((local_addr[7:0] & 8'hFC) == A_RD_START)) begin
        reg_rd_start1 <= local_wdata[0];
      end

      // Interrupt for write
      if(WR_INT) begin
        reg_int[0] <= 1'b1;
      end else if(wr_ena && ((local_addr[7:0] & 8'hFC) == A_INT_STATUS)) begin
        if(local_wdata[0]) begin
          reg_int[0] <= 1'b0;
        end
      end
      // Interrupt for read
      if(RD_INT) begin
        reg_int[1] <= 1'b1;
      end else if(wr_ena && ((local_addr[7:0] & 8'hFC) == A_INT_STATUS)) begin
        if(local_wdata[1]) begin
          reg_int[1] <= 1'b0;
        end
      end
    end
  end

  // Read Register
  always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
      reg_rdata[31:0] <= 32'd0;
      rd_ack <= 1'b0;
    end else begin
      rd_ack <= rd_ena;
      if(rd_ena) begin
        case(local_addr[7:0] & 8'hFC)
          A_STATUS:     reg_rdata[31:0] <= {reg_master_reset, 31'd0};
          A_INT_STATUS: reg_rdata[31:0] <= reg_int[31:0];
          A_INT_MASK:   reg_rdata[31:0] <= reg_int_mask[31:0];
          A_WR_START:   reg_rdata[31:0] <= {12'd0, WR_FIFO_AEMPTY, WR_FIFO_EMPTY, WR_FIFO_AFULL, WR_FIFO_FULL, 7'd0, WR_READY, 6'd0, reg_wr_start2, reg_wr_start1};
          A_WR_ADRS:    reg_rdata[31:0] <= reg_wr_adrs[31:0];
          A_WR_COUNT:   reg_rdata[31:0] <= reg_wr_count[31:0];
          A_RD_START:   reg_rdata[31:0] <= {12'd0, RD_FIFO_AEMPTY, RD_FIFO_EMPTY, RD_FIFO_AFULL, RD_FIFO_FULL, 7'd0, RD_READY, 6'd0, reg_rd_start2, reg_rd_start1};
          A_RD_ADRS:    reg_rdata[31:0] <= reg_rd_adrs[31:0];
          A_RD_COUNT:   reg_rdata[31:0] <= reg_rd_count[31:0];
          A_TESTDATA:   reg_rdata[31:0] <= reg_testdata[31:0];
          A_DEBUG:      reg_rdata[31:0] <= {32'd0};
          default:      reg_rdata[31:0] <= 32'd0;
        endcase
      end else begin
        reg_rdata[31:0] <= 32'd0;
      end
    end
  end

  assign WR_START       = reg_wr_start1 | reg_wr_start2;
  assign WR_ADRS[31:0]  = reg_wr_adrs[31:0];
  assign WR_COUNT[31:0] = reg_wr_count[31:0];
  assign RD_START       = reg_rd_start1 | reg_rd_start2;
  assign RD_ADRS[31:0]  = reg_rd_adrs[31:0];
  assign RD_COUNT[31:0] = reg_rd_count[31:0];

  assign MASTER_RST     = reg_master_reset;

  assign INTERRUPT      = ((reg_int & reg_int_mask) != 32'd0)?1'b1:1'b0;

endmodule
