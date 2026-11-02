module key_decoder(
  input wire clk,
  input wire reset,
  input wire [7:0] scan_code,
  input wire scan_valid,

  output reg [7:0] key_ascii,
  output reg key_released,
  output reg key_valid
);
  reg release_pending;

function [7:0] decode_ascii;
    input [7:0] code;
    begin
        case (code)
            8'h1C: decode_ascii = "a";
            8'h32: decode_ascii = "b";
            8'h21: decode_ascii = "c";
            8'h23: decode_ascii = "d";
            8'h24: decode_ascii = "e";
            8'h2B: decode_ascii = "f";
            8'h34: decode_ascii = "g";
            8'h33: decode_ascii = "h";
            8'h43: decode_ascii = "i";
            8'h3B: decode_ascii = "j";
            8'h42: decode_ascii = "k";
            8'h4B: decode_ascii = "l";
            8'h3A: decode_ascii = "m";
            8'h31: decode_ascii = "n";
            8'h44: decode_ascii = "o";
            8'h4D: decode_ascii = "p";
            8'h15: decode_ascii = "q";
            8'h2D: decode_ascii = "r";
            8'h1B: decode_ascii = "s";
            8'h2C: decode_ascii = "t";
            8'h3C: decode_ascii = "u";
            8'h2A: decode_ascii = "v";
            8'h1D: decode_ascii = "w";
            8'h22: decode_ascii = "x";
            8'h35: decode_ascii = "y";
            8'h1A: decode_ascii = "z";

            8'h45: decode_ascii = "0";
            8'h16: decode_ascii = "1";
            8'h1E: decode_ascii = "2";
            8'h26: decode_ascii = "3";
            8'h25: decode_ascii = "4";
            8'h2E: decode_ascii = "5";
            8'h36: decode_ascii = "6";
            8'h3D: decode_ascii = "7";
            8'h3E: decode_ascii = "8";
            8'h46: decode_ascii = "9";

            8'h29: decode_ascii = " ";
            8'h5A: decode_ascii = 8'h0D; // Enter: carriage return

            default: decode_ascii = 8'd0;
        endcase
    end
endfunction
  always @(posedge clk) begin
    if(reset ) begin
      release_pending <= 1'b0;
      key_ascii <= 8'd0;
      key_released <= 1'b0;
      key_valid <= 1'b0;
    end
    else begin
      key_valid <= 1'b0;
      if(scan_valid) begin
        if(scan_code == 8'hF0) begin
          release_pending <= 1'b1;
        end else begin
      if (decode_ascii(scan_code) != 8'd0) begin
        key_ascii <= decode_ascii(scan_code);
        key_released <= release_pending;
        key_valid <= 1'b1;
      end

      release_pending <= 1'b0;
    end
  end
  end
  end
endmodule
