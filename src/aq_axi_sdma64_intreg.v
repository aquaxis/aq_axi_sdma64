/*
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
module aq_axi_sdma64_intreg
(
  input  RST_N,

  input  CLKA,
  input  DIN,

  input  CLKB,
  output DOUT
 );

  reg    data_in;
  reg [2:0] data_in_rst;
  reg [2:0] data_out;

  always @(posedge CLKA or negedge RST_N) begin
    if(!RST_N) begin
      data_in <= 1'b0;
      data_in_rst[2:0] <= 3'd0;
    end else begin
      if(data_in_rst[2]) begin
        data_in <= 1'b0;
      end else if(DIN) begin
        data_in <= 1'b1;
      end
      data_in_rst[2:0] <= {data_in_rst[1:0], data_out[2]};
    end
  end

  always @(posedge CLKB or negedge RST_N) begin
    if(!RST_N) begin
      data_out[2:0] <= 3'd0;
    end else begin
      data_out[2:0] <= {data_out[1:0], data_in};
    end
  end

  assign DOUT = (data_out[2:1] == 2'b01)?1'b1:1'b0;

endmodule
