module ps2_receiver (
  input wire clk,
  input wire reset,
  input wire ps2_clk,
  input wire ps2_data,
  output wire ps2_falling,
  output reg [7:0] scan_code,
  output reg scan_valid
);

reg ps2_clk_meta; //stabilizing flipflops (meta and sync) which ensure that the flipflop storing the previous clock's state has a stable signal to get input from, hence the order is ps2_clock -> meta -> sync -> prev
reg ps2_clk_sync;
reg ps2_clk_prev;
reg ps2_data_meta;
reg ps2_data_sync;
reg parity_ok;

  localparam IDLE = 2'd0,
             DATA = 2'd1,
             PARITY = 2'd2,
             STOP = 2'd3;
  reg [1:0] state;
  reg [2:0] bit_count;


wire [7:0] received_data;
wire shift_enable;

always @(posedge clk) begin
  if(reset)
    begin

    ps2_clk_meta <= 1'b1;
    ps2_clk_sync <= 1'b1;
    ps2_clk_prev <= 1'b1;
    ps2_data_sync <= 1'b1;
    ps2_data_meta <= 1'b1;

    end
  else
    begin
    ps2_clk_meta <= ps2_clk;
    ps2_clk_sync <= ps2_clk_meta;
    ps2_clk_prev <= ps2_clk_sync;
    ps2_data_meta <= ps2_data;
    ps2_data_sync <= ps2_data_meta;
  end
end

assign ps2_falling = ps2_clk_prev & ~ps2_clk_sync;


always @(posedge clk)
begin
  if(reset) begin
    state <= IDLE;
    parity_ok <= 1'b0;
    bit_count  <= 3'd0;
    scan_code <= 8'b00000000;
    scan_valid <= 1'b0;
  end
  else begin
    scan_valid <= 1'b0;
    if(ps2_falling) begin
    case (state)
      IDLE: begin
        if(ps2_data_sync == 1'b0) begin
          state <= DATA;
          bit_count <= 3'd0;
        end
      end

      DATA: begin
        if(bit_count == 3'd7)
          state <= PARITY;
        else
          bit_count <= bit_count + 3'd1;
      end
      PARITY: begin
        parity_ok <= (^received_data) ^ ps2_data_sync;
        state <= STOP;
      end

      STOP: begin
        if(ps2_data_sync && parity_ok) begin
          scan_code <= received_data;
          scan_valid <= 1'b1;
      end

      state <= IDLE;
    end
    endcase
  end
end
end


assign shift_enable = (state == DATA) & ps2_falling;

shift_register data_register(
  .clk(clk),
  .reset(reset),
  .enable(shift_enable),
  .serial_in(ps2_data_sync),
  .data(received_data)
);
endmodule
