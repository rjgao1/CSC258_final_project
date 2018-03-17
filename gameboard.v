module gameboard_top(
    input CLOCK_50,         // On Board 50 MHz
    // Board inputs
    input [9:0] KEY,
    // The ports below are for the VGA output.
    output VGA_CLK,         // VGA Clock
    output VGA_HS,          // VGA H_SYNC
    output VGA_VS,          // VGA V_SYNC
    output VGA_BLANK_N,     // VGA BLANK
    output VGA_SYNC_N,      // VGA SYNC
    output [9:0] VGA_R,     // VGA Red[9:0]
    output [9:0] VGA_G,     // VGA Green[9:0]
    output [9:0] VGA_B     // VGA Blue[9:0]
  );

    wire resetn;
    assign resetn = KEY[0];

    /*
     * Create an instance of a VGA controller
     * Define the number of colors as well as the initial background
     * image file (.MIF) for the controller
     */
    vga_adapter VGA(
      .reset(resetn),
      .clock(CLOCK_50),
      .color(color),
      .x(x),
      .y(y),
      .plot(writeEn),
      // Signals for the DAC to drive the monitor
      .VGA_R(VGA_R),
      .VGA_G(VGA_G),
      .VGA_B(VGA_B),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .VGA_BLANK(VGA_BLANK_N),
      .VGA_SYNC(VGA_SYNC_N),
      .VGA_CLK(VGA_CLK)
    );
    defparam VGA.RESOLUTION = "160X120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "gameboard.mif";






endmodule

module gameboard(
  input clk,
  input [63:0] mineMap,
  input [63:0] flagMap,
  input [63:0] stepMap
  );

endmodule

module gameboard_control(

  );
endmodule

module gameboard_datapath(
  input clk,
  input load_x, load_y, reset, load_c, en_c,
  input [7:0] x_in,
  input [6:0] y_in,
  input [2:0] color_in,
  output [7:0] x_out,
  output [6:0] y_out,
  output reg [2:0] color_out
  );

  wire en_y;
  wire reset_count;
  wire [4:0] x_count_out;
  wire [3:0] y_count_out;
  assign en_y = ~x_count_out[0] & // should increment y when x = 18
                 x_count_out[1] &
                ~x_count_out[2] &
                ~x_count_out[3] &
                 x_count_out[4];
  assign reset_count =  y_count_out[0] & // should reset itself when y = 13
                       ~y_count_out[1] &
                        y_count_out[2] &
                        y_count_out[3];

  assign x_out = x_in + {3'b00, x_count_out};
  assign y_out = y_in + {3'b00, y_count_out};
// x and y counters  19 x 14
  x_counter xc(
    .clk(clk),
    .load_x(load_x),
    .reset(reset & ~ en_y),
    .en(en_c),
    .x_in(5'b00000),
    .x_out(x_count_out)
    );

  y_counter yc(
    .clk(clk),
    .load_y(load_y),
    .reset(reset & ~ reset_count),
    .en(en_y),
    .y_in(4'b000),
    .y_out(y_count_out)
    );

    // load color if not in reset mode
      always @(posedge clk) begin
        if (!reset)
          color_out <= 3'b0;
        else if (load_c == 1)
          color_out <= color_in;
        else
          color_out <= color_out;
      end


endmodule

module x_counter(
	input clk,
	input load_x, reset, en,
	input [4:0] x_in,
	output reg [4:0] x_out
	);
	always @(posedge clk) begin
		if (!reset) begin
			x_out <= 5'b0;
      end
		else if (load_x) begin
			x_out <= x_in;
      end
		else if (en) begin
				x_out <= x_out + 1;
		end
	end
endmodule

module y_counter(
	input clk,
	input load_y, reset, en,
	input [3:0] y_in,
	output reg [3:0] y_out
	);
	always @(posedge clk) begin
		if (!reset) begin
			y_out <= 4'b0;
      end
		else if (load_y) begin
			y_out <= 0;
      end
		else if (en) begin
				y_out <= y_out + 1;
		end
	end
endmodule

module tile_control(
  input clk,
  input resetn,
  input go,

  output reg ld_x, ld_y, ld_color,
  output reg en_xc,
  output reg writeEn);

  reg [4:0] current_state, next_state;

  localparam  S_LOAD      = 5'd0,
              S_LOAD_WAIT = 5'd1,
              S_CYCLE_0   = 5'd2,
              S_CYCLE_1   = 5'd3,
              S_CYCLE_2   = 5'd4,
              S_CYCLE_3   = 5'd5,
              S_CYCLE_4   = 5'd6,
              S_CYCLE_5   = 5'd7,
              S_CYCLE_6   = 5'd8,
              S_CYCLE_7   = 5'd9,
              S_CYCLE_8   = 5'd10,
              S_CYCLE_9   = 5'd11,
              S_CYCLE_10  = 5'd12,
              S_CYCLE_11  = 5'd13,
              S_CYCLE_12  = 5'd14,
              S_CYCLE_13  = 5'd15,
              S_CYCLE_14  = 5'd16,
              S_CYCLE_15  = 5'd17;

  // Next state logic aka our state table
  always@(*)
  begin: state_table
    case (current_state)
      S_LOAD: next_state = go ? S_LOAD_WAIT : S_LOAD; // Loop in current state until value is input
      S_LOAD_WAIT: next_state = go ? S_LOAD_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
      S_CYCLE_0: next_state = S_CYCLE_1;
      S_CYCLE_1: next_state = S_CYCLE_2;
      S_CYCLE_2: next_state = S_CYCLE_3;
      S_CYCLE_3: next_state = S_CYCLE_4;
      S_CYCLE_4: next_state = S_CYCLE_5;
      S_CYCLE_5: next_state = S_CYCLE_6;
      S_CYCLE_6: next_state = S_CYCLE_7;
      S_CYCLE_7: next_state = S_CYCLE_8;
      S_CYCLE_8: next_state = S_CYCLE_9;
      S_CYCLE_9: next_state = S_CYCLE_10;
      S_CYCLE_10:next_state = S_CYCLE_11;
      S_CYCLE_11:next_state = S_CYCLE_12;
      S_CYCLE_12:next_state = S_CYCLE_13;
      S_CYCLE_13:next_state = S_CYCLE_14;
      S_CYCLE_14:next_state = S_CYCLE_15;
      S_CYCLE_15:next_state = S_LOAD;
      default: next_state = S_LOAD;
    endcase
  end

  // Output logic aka all of our datapath control signals
  always @(*)
  begin: enable_signals
    // By default make all our signals 0
    ld_x = 1'b0;
    ld_y = 1'b0;
		en_xc = 1'b0;
		// en_yc = 1'b0;
    ld_color = 1'b0;
    writeEn = 1'b0;

    case (current_state)
      S_LOAD: begin
        ld_x = 1'b1;
        ld_y = 1'b1;
        ld_color = 1'b1;
        end
      S_CYCLE_0,  // row 1
      S_CYCLE_1,  // row 1
      S_CYCLE_2,   // row 1
      S_CYCLE_4,  // row 2
      S_CYCLE_5,  // row 2
      S_CYCLE_6,  // row 2
      S_CYCLE_8,  // row 3
      S_CYCLE_9,  // row 3
      S_CYCLE_10, // row 3
      S_CYCLE_12, // row 4
      S_CYCLE_13, // row 4
      S_CYCLE_14: // row 4
      begin // start shift across the x axis
				en_xc = 1'b1;
        writeEn = 1'b1;
        end
      S_CYCLE_3, // row 1
      S_CYCLE_7, // row 2
      S_CYCLE_11,// row 3
      S_CYCLE_15:// row 4
      begin //  start shift down the y axis
        ld_x = 1'b1;
        writeEn = 1'b1;
        end
    endcase
  end

  always@(posedge clk)
  begin: state_FFs
    if(!resetn)
      current_state <= S_LOAD;
    else
      current_state <= next_state;
  end
  endmodule
