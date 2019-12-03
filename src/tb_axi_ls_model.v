/*
 * Copyright (C)2014-2017 AQUAXIS
 */
module tb_axi_ls_master_model
  (
   // Reset, Clock
   input             ARESETN,
   input             ACLK,

   // Write Address Channel
   output reg [31:0] S_AXI_AWADDR,
   output reg [3:0]  S_AXI_AWCACHE,
   output reg [2:0]  S_AXI_AWPROT,
   output reg        S_AXI_AWVALID,
   input             S_AXI_AWREADY,

   // Write Data Channel
   output reg [31:0] S_AXI_WDATA,
   output reg [3:0]  S_AXI_WSTRB,
   output reg        S_AXI_WVALID,
   input             S_AXI_WREADY,

   // Write Response Channel
   input             S_AXI_BVALID,
   output reg        S_AXI_BREADY,
   input [1:0]       S_AXI_BRESP,

   // Read Address Channe
   output reg [31:0] S_AXI_ARADDR,
   output reg [3:0]  S_AXI_ARCACHE,
   output reg [2:0]  S_AXI_ARPROT,
   output reg        S_AXI_ARVALID,
   input             S_AXI_ARREADY,

   // Read Data Channel
   input [31:0]      S_AXI_RDATA,
   input [1:0]       S_AXI_RRESP,
   input             S_AXI_RVALID,
   output reg        S_AXI_RREADY
);

   initial begin
      S_AXI_AWADDR   = 32'h0000_0000;
      S_AXI_AWCACHE  = 3'd0;
      S_AXI_AWPROT   = 2'd0;
      S_AXI_AWVALID  = 1'b0;
      S_AXI_WDATA    = 32'h0000_0000;
      S_AXI_WSTRB    = 4'H0;
      S_AXI_WVALID   = 1'b0;
      S_AXI_BREADY   = 1'b0;
      S_AXI_ARADDR   = 32'h0000_0000;
      S_AXI_ARCACHE  = 3'd0;
      S_AXI_ARPROT   = 2'd0;
      S_AXI_ARVALID  = 1'b0;
      S_AXI_RREADY   = 1'b0;
   end

   // Write Data
   task wrdata;
      input [31:0] adrs;
      input [31:0] data;
      begin
         @(negedge ACLK);

         S_AXI_AWADDR <= adrs;
         S_AXI_AWVALID  <= 1'b1;

         @(negedge ACLK);

         wait(S_AXI_AWREADY);
         S_AXI_AWVALID  <= 1'b0;

         @(negedge ACLK);

         S_AXI_WDATA  <= data;
         S_AXI_WSTRB  <= 4'HF;
         S_AXI_WVALID <= 1'b1;

         wait(S_AXI_WREADY);

         @(negedge ACLK);

         S_AXI_WVALID <= 1'b0;

         @(negedge ACLK);

         wait(S_AXI_BVALID);

         @(negedge ACLK);

         S_AXI_BREADY <= 1'b1;

         @(negedge ACLK);

         wait(!S_AXI_BVALID);
         S_AXI_BREADY <= 1'b0;

         @(negedge ACLK);
      end
   endtask

   // Read Data
   task rddata;
      input [31:0] adrs;
      output [31:0] data;
      begin
         @(negedge ACLK);

         S_AXI_ARADDR <= adrs;
         S_AXI_ARVALID  <= 1'b1;

         @(negedge ACLK);

         wait(S_AXI_ARREADY);

         S_AXI_ARVALID  <= 1'b0;

         @(negedge ACLK);

         S_AXI_RREADY <= 1'b1;
         wait(S_AXI_RVALID);
         data = S_AXI_RDATA;
         $display("AXI Lite Master Read[%08X]: %08X", adrs, S_AXI_RDATA);

         @(negedge ACLK);

         S_AXI_RREADY <= 1'b0;
         wait(!S_AXI_RVALID);

         @(negedge ACLK);

      end
   endtask
endmodule

// AXI Slave Model
module tb_axi_slave_model
  (
   // Reset, Clock
   input            ARESETN,
   input            ACLK,

   // Master Write Address
   input [0:0]      M_AXI_AWID,
   input [31:0]     M_AXI_AWADDR,
   input [7:0]      M_AXI_AWLEN, // Burst Length: 0-255
   input [2:0]      M_AXI_AWSIZE, // Burst Size: Fixed 2'b011
   input [1:0]      M_AXI_AWBURST, // Burst Type: Fixed 2'b01(Incremental Burst)
   input            M_AXI_AWLOCK, // Lock: Fixed 2'b00
   input [3:0]      M_AXI_AWCACHE, // Cache: Fiex 2'b0011
   input [2:0]      M_AXI_AWPROT, // Protect: Fixed 2'b000
   input [3:0]      M_AXI_AWQOS, // QoS: Fixed 2'b0000
   input [0:0]      M_AXI_AWUSER, // User: Fixed 32'd0
   input            M_AXI_AWVALID,
   output reg       M_AXI_AWREADY,

   // Master Write Data
   input [31:0]     M_AXI_WDATA,
   input [3:0]      M_AXI_WSTRB,
   input            M_AXI_WLAST,
   input [0:0]      M_AXI_WUSER,
   input            M_AXI_WVALID,
   output reg       M_AXI_WREADY,

   // Master Write Response
   output reg [0:0] M_AXI_BID,
   output reg [1:0] M_AXI_BRESP,
   output reg [0:0] M_AXI_BUSER,
   output           M_AXI_BVALID,
   input            M_AXI_BREADY,

   // Master Read Address
   input [0:0]      M_AXI_ARID,
   input [31:0]     M_AXI_ARADDR,
   input [7:0]      M_AXI_ARLEN,
   input [2:0]      M_AXI_ARSIZE,
   input [1:0]      M_AXI_ARBURST,
   //  input [1:0]  M_AXI_ARLOCK,
   input [0:0]      M_AXI_ARLOCK,
   input [3:0]      M_AXI_ARCACHE,
   input [2:0]      M_AXI_ARPROT,
   input [3:0]      M_AXI_ARQOS,
   input [0:0]      M_AXI_ARUSER,
   input            M_AXI_ARVALID,
   output reg       M_AXI_ARREADY,

   // Master Read Data
   output reg [0:0] M_AXI_RID,
   output [63:0]    M_AXI_RDATA,
   output reg [1:0] M_AXI_RRESP,
   output           M_AXI_RLAST,
   output reg [0:0] M_AXI_RUSER,
   output           M_AXI_RVALID,
   input            M_AXI_RREADY
   );

   initial begin
      M_AXI_AWREADY  = 1;
      M_AXI_WREADY   = 1;
      M_AXI_BID      = 0;
      M_AXI_BRESP    = 0;
      M_AXI_BUSER    = 0;
      //M_AXI_BVALID = 0;
      M_AXI_ARREADY  = 1;
      M_AXI_RID      = 0;
      //M_AXI_RDATA  = 0;
      M_AXI_RRESP    = 0;
      //M_AXI_RLAST  = 0;
      M_AXI_RUSER    = 0;
      //M_AXI_RVALID = 0;
   end

   // AXI Read
   reg axi_rena;
   reg [31:0] count,rcount;
   reg [7:0]  axi_length;
   always @(posedge ACLK or negedge ARESETN) begin
      if(!ARESETN) begin
         count <= 32'd0;
         rcount <= 32'd0;
         axi_rena <= 0;
         axi_length <= 0;
         //        M_AXI_RVALID<=1'b0;
      end else begin
         if(M_AXI_RLAST) begin
            axi_rena <= 0;
         end else if(M_AXI_ARVALID) begin
            axi_rena <= 1;
            axi_length <= M_AXI_ARLEN;
         end

         if(axi_rena) begin
            count <= count + 32'd1;
         end else begin
            count <= 0;
         end

         if(M_AXI_RVALID & M_AXI_RREADY) begin
            rcount <= rcount + 32'd1;
         end
      end
   end
   assign M_AXI_RDATA  = {rcount,rcount};
   assign M_AXI_RLAST  = (axi_rena & (axi_length == count))?1:0;
   assign M_AXI_RVALID = axi_rena;

   // AXI BResponse
   reg axi_wvalid;
   always @(posedge ACLK or negedge ARESETN)begin
      if(!ARESETN) begin
         axi_wvalid <= 0;
      end else begin
         if(M_AXI_BREADY) begin
            axi_wvalid <= 0;
         end else if (M_AXI_WVALID & M_AXI_WLAST) begin
            axi_wvalid <= 1;
         end
      end
   end

   assign M_AXI_BVALID  = axi_wvalid;

endmodule

module axis_master_model
  (
   input             W_AXIS_TCLK,
   output reg [63:0] W_AXIS_TDATA,
   output reg        W_AXIS_TVALID,
   input             W_AXIS_TREADY,
   output reg [7:0]  W_AXIS_TSTRB,
   output reg        W_AXIS_TKEEP,
   output reg        W_AXIS_TLAST
   );

   initial begin
      W_AXIS_TDATA  = 64'd0;
      W_AXIS_TVALID = 1'b0;
      W_AXIS_TSTRB  = 8'd0;
      W_AXIS_TKEEP  = 1'b0;
      W_AXIS_TLAST  = 1'b0;
   end

   task wrdata;
      input [63:0] wdata;
      input        last;
      begin
         @(posedge W_AXIS_TCLK);

         wait (W_AXIS_TREADY);

         W_AXIS_TVALID <= 1'b1;
         W_AXIS_TDATA  <= wdata;
         W_AXIS_TLAST  <= last;
         @(posedge W_AXIS_TCLK);
         W_AXIS_TVALID <= 1'b0;
         W_AXIS_TDATA  <= 64'd0;
         W_AXIS_TLAST  <= 1'b0;
         @(posedge W_AXIS_TCLK);
      end
   endtask

endmodule

module axis_slave_model
  (
   input        R_AXIS_TCLK,
   input [63:0] R_AXIS_TDATA,
   input        R_AXIS_TVALID,
   output reg   R_AXIS_TREADY,
   input [7:0]  R_AXIS_TSTRB,
   input        R_AXIS_TKEEP,
   input        R_AXIS_TLAST
   );

   initial begin
      R_AXIS_TREADY = 1'b0;
   end

   task rdenable;
      begin
         @(posedge R_AXIS_TCLK);
         R_AXIS_TREADY <= 1'b1;
         @(posedge R_AXIS_TCLK);
      end
   endtask

   task rddisable;
      begin
         @(posedge R_AXIS_TCLK);
         R_AXIS_TREADY <= 1'b1;
         @(posedge R_AXIS_TCLK);
      end
   endtask

endmodule
