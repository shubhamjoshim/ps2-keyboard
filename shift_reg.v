module shift_register(
input wire clk,
input wire reset,
input wire enable,
input wire serial_in,
output reg [7:0] data
);

always @(posedge clk) begin
  if(reset)
    data <= 8'b00000000;
  else if (enable)
    data <= {serial_in, data [7:1]};
end
endmodule
