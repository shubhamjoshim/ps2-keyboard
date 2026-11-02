`timescale 1ns/1ps

module shift_reg_tb;
  reg clk = 0;
  reg reset =1;
  reg serial_in = 0;
  reg enable = 1;

  wire [7:0] data;

  shift_register dut(.clk(clk), .reset(reset),.enable(enable),.serial_in(serial_in),.data(data));

  always #5 clk = ~clk;

  initial begin
  $dumpfile("shift_reg.vcd");
  $dumpvars(0,shift_reg_tb);

  #12
  reset = 0;
  serial_in = 1;

  #10
  serial_in = 0;
  enable = 0;
  #80
  $finish;
end

endmodule
