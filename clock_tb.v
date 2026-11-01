`timescale 1ns/1ps

module clock_tb;
reg clk = 0;

always #5 clk = ~clk;

initial begin

$dumpfile("clock.vcd");
$dumpvars(0,clock_tb);

#50
$finish;

end
endmodule;

