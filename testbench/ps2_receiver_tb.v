`timescale 1ns/1ps

module ps2_receiver_tb;
  reg clk = 0;
  reg reset = 1;
  reg ps2_clk = 1;
  reg ps2_data = 1;
  reg [7:0] expected_ascii;
  reg expected_release;

  wire ps2_falling;
  wire [7:0] scan_code;
  wire scan_valid;
  wire [7:0] key_ascii;
  wire key_released;
  wire key_valid;
  integer event_count =0;
ps2_receiver dut (
  .clk(clk),
  .reset(reset),
  .ps2_clk(ps2_clk),
  .ps2_falling(ps2_falling),
  .ps2_data(ps2_data),
  .scan_code(scan_code),
  .scan_valid(scan_valid)
);

key_decoder decoder (
  .clk(clk),
  .reset(reset),
  .scan_code(scan_code),
  .scan_valid(scan_valid),
  .key_ascii(key_ascii),
  .key_released(key_released),
  .key_valid(key_valid)
);

always #5 clk = ~clk;

task send_bit;
  input bit_value;
  begin

    ps2_data = bit_value;

    #40;
    ps2_clk = 0;
    #40;
    ps2_clk = 1;
    #40;
  end
endtask

initial begin
  $dumpfile("ps2_receiver.vcd");
  $dumpvars(0,ps2_receiver_tb);

  #12;
  reset = 0;
  test_key(8'h1C, "a");
  test_key(8'h32, "b");
  test_key(8'h1A, "z");
  test_key(8'h16, "1");
  test_key(8'h45, "0");
  test_key(8'h29, " ");
  test_key(8'h5A, 8'h0D);

  #40;
  $display("PASS: all 7 key tests");
  $finish;
end

always @(negedge clk) begin
  if(key_valid) begin
    if(key_ascii !== expected_ascii || key_released !== expected_release)
      $fatal(1,"Incorrect key event");

    event_count = event_count +1;
  end
end

task send_byte;
  input [7:0] value;
  integer i;
  begin
    send_bit(0);

    for(i = 0;i<8; i = i+1)
      send_bit(value[i]);
    send_bit(~(^value));
    send_bit(1);
  end
endtask

task test_key;
  input [7:0] code;
  input [7:0] character;

  integer previous_count;
  begin
    previous_count = event_count;
    expected_ascii = character;

    expected_release = 0;
    send_byte(code);

    if(event_count != previous_count + 1)
      $fatal(1,"Missing or extra press event");

    expected_release = 1;
    send_byte(8'hF0);

    if(event_count != previous_count +1)
      $fatal(1,"F0 incorrectly procuded an event");
    send_byte(code);

    if(event_count != previous_count +2)
      $fatal(1,"Misiing or extra release event");

    $display("PASS: ASCII %h press/release",character);
  end
endtask
endmodule
