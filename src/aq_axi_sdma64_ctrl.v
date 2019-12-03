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
module aq_axi_dma64_ctrl
  (
   input         RST_N,

   input         AQ_LOCAL_CLK,
   input         AQ_LOCAL_CS,
   input         AQ_LOCAL_RNW,
   output        AQ_LOCAL_ACK,
   input [31:0]  AQ_LOCAL_ADDR,
   input [3:0]   AQ_LOCAL_BE,
   input [31:0]  AQ_LOCAL_WDATA,
   output [31:0] AQ_LOCAL_RDATA,

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

   localparam A_STATUS        = 8'h00;
   localparam A_INT_STATUS    = 8'h04;
   localparam A_INT_MASK      = 8'h08;

   localparam A_WR_START      = 8'h0C;
   localparam A_WR_ADRS       = 8'h10;
   localparam A_WR_COUNT      = 8'h14;
   localparam A_RD_START      = 8'h18;
   localparam A_RD_ADRS       = 8'h1C;
   localparam A_RD_COUNT      = 8'h20;

   localparam A_TESTDATA      = 8'h24;
   localparam A_DEBUG         = 8'h28;

   wire          wr_ena, rd_ena, wr_ack;
   reg           rd_ack;

   reg           reg_master_reset;
   reg           reg_wr_start1, reg_rd_start1;
   reg           reg_wr_start2, reg_rd_start2;
   reg [31:0]    reg_wr_adrs, reg_rd_adrs;
   reg [31:0]    reg_wr_count, reg_rd_count;
   reg [31:0]    reg_testdata;
   reg [31:0]    reg_int_mask;
   reg [31:0]    reg_int;

   reg [31:0]    reg_rdata;

   assign wr_ena = (AQ_LOCAL_CS & ~AQ_LOCAL_RNW)?1'b1:1'b0;
   assign rd_ena = (AQ_LOCAL_CS &  AQ_LOCAL_RNW)?1'b1:1'b0;
   assign wr_ack = wr_ena;

   // Write Register
   always @(posedge AQ_LOCAL_CLK or negedge RST_N) begin
      if(!RST_N) begin
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
      end else begin
         if(wr_ena) begin
            case(AQ_LOCAL_ADDR[7:0] & 8'hFC)
              A_STATUS: begin
                 reg_master_reset <= AQ_LOCAL_WDATA[31];
              end
              A_INT_MASK: begin
                 reg_int_mask[31:0] <= AQ_LOCAL_WDATA[31:0];
              end
              A_WR_START: begin
                 reg_wr_start2 <= AQ_LOCAL_WDATA[1];
              end
              A_WR_ADRS: begin
                 reg_wr_adrs[31:0] <= AQ_LOCAL_WDATA[31:0];
              end
              A_WR_COUNT: begin
                 reg_wr_count[31:0] <= AQ_LOCAL_WDATA[31:0];
              end
              A_RD_START: begin
                 reg_rd_start2 <= AQ_LOCAL_WDATA[1];
              end
              A_RD_ADRS: begin
                 reg_rd_adrs[31:0] <= AQ_LOCAL_WDATA[31:0];
              end
              A_RD_COUNT: begin
                 reg_rd_count[31:0] <= AQ_LOCAL_WDATA[31:0];
              end
              A_TESTDATA: begin
                 reg_testdata[31:0] <= AQ_LOCAL_WDATA[31:0];
              end
              default: begin
              end
            endcase
         end

         // One shot Write DMA
         if(!WR_READY) begin
            reg_wr_start1 <= 1'b0;
         end else if(wr_ena && ((AQ_LOCAL_ADDR[7:0] & 8'hFC) == A_WR_START)) begin
            reg_wr_start1 <= AQ_LOCAL_WDATA[0];
         end
         // One shot Read DMA
         if(!RD_READY) begin
            reg_rd_start1 <= 1'b0;
         end else if(wr_ena && ((AQ_LOCAL_ADDR[7:0] & 8'hFC) == A_RD_START)) begin
               reg_rd_start1 <= AQ_LOCAL_WDATA[0];
         end

         // Interrupt for write
         if(WR_INT) begin
            reg_int[0] <= 1'b1;
         end else if(wr_ena && ((AQ_LOCAL_ADDR[7:0] & 8'hFC) == A_INT_STATUS)) begin
            if(AQ_LOCAL_WDATA[0]) begin
               reg_int[0] <= 1'b0;
            end
         end
         // Interrupt for read
         if(RD_INT) begin
            reg_int[1] <= 1'b1;
         end else if(wr_ena && ((AQ_LOCAL_ADDR[7:0] & 8'hFC) == A_INT_STATUS)) begin
            if(AQ_LOCAL_WDATA[1]) begin
               reg_int[1] <= 1'b0;
            end
         end
      end
   end

   // Read Register
   always @(posedge AQ_LOCAL_CLK or negedge RST_N) begin
      if(!RST_N) begin
         reg_rdata[31:0] <= 32'd0;
         rd_ack <= 1'b0;
      end else begin
         rd_ack <= rd_ena;
         if(rd_ena) begin
            case(AQ_LOCAL_ADDR[7:0] & 8'hFC)
              A_STATUS: begin
                 reg_rdata[31:0] <= {reg_master_reset, 31'd0};
              end
              A_INT_STATUS: begin
                 reg_rdata[31:0] <= reg_int[31:0];
              end
              A_INT_MASK: begin
                 reg_rdata[31:0] <= reg_int_mask[31:0];
              end
              A_WR_START: begin
                 reg_rdata[31:0] <= {12'd0, WR_FIFO_AEMPTY, WR_FIFO_EMPTY, WR_FIFO_AFULL, WR_FIFO_FULL, 7'd0, WR_READY, 6'd0, reg_wr_start2, reg_wr_start1};
              end
              A_WR_ADRS: begin
                 reg_rdata[31:0] <= reg_wr_adrs[31:0];
              end
              A_WR_COUNT: begin
                 reg_rdata[31:0] <= reg_wr_count[31:0];
              end
              A_RD_START: begin
                 reg_rdata[31:0] <= {12'd0, RD_FIFO_AEMPTY, RD_FIFO_EMPTY, RD_FIFO_AFULL, RD_FIFO_FULL, 7'd0, RD_READY, 6'd0, reg_rd_start2, reg_rd_start1};
              end
              A_RD_ADRS: begin
                 reg_rdata[31:0] <= reg_rd_adrs[31:0];
              end
              A_RD_COUNT: begin
                 reg_rdata[31:0] <= reg_rd_count[31:0];
              end
              A_TESTDATA: begin
                 reg_rdata[31:0] <= reg_testdata[31:0];
              end
              A_DEBUG: begin
                 reg_rdata[31:0] <= {32'd0};
              end
              default: begin
                 reg_rdata[31:0] <= 32'd0;
              end
            endcase
         end else begin
            reg_rdata[31:0] <= 32'd0;
         end
      end
   end

   assign AQ_LOCAL_ACK         = (wr_ack | rd_ack);
   assign AQ_LOCAL_RDATA[31:0] = reg_rdata[31:0];

   assign WR_START       = reg_wr_start1 | reg_wr_start2;
   assign WR_ADRS[31:0]  = reg_wr_adrs[31:0];
   assign WR_COUNT[31:0] = reg_wr_count[31:0];
   assign RD_START       = reg_rd_start1 | reg_rd_start2;
   assign RD_ADRS[31:0]  = reg_rd_adrs[31:0];
   assign RD_COUNT[31:0] = reg_rd_count[31:0];

   assign MASTER_RST     = reg_master_reset;

   assign INTERRUPT = ((reg_int & reg_int_mask) != 32'd0)?1'b1:1'b0;

endmodule
