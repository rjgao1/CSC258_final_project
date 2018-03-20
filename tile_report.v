module tile_report(
  input [5:0] tile_n,
  input [63:0] mineMap,
  input [63:0] flagMap,
  input [63:0] stepMap,

  output reg [2:0] status // status[2] mined, status[1] flagged, status[1] stepped
  );
  integer tile_int;
  always @(*) begin: ini_status
  status = 3'b0; //initialize status to be 000
    case (tile_n)
      000000, 000001, 000010, 000011, 000100, 000101, 000110, 000111, 001000, 001001, 001010, 001011, 001100, 001101, 001110, 001111, 010000, 010001, 010010, 010011, 010100, 010101, 010110, 010111, 011000, 011001, 011010, 011011, 011100, 011101, 011110, 011111, 100000, 100001, 100010, 100011, 100100, 100101, 100110, 100111, 101000, 101001, 101010, 101011, 101100, 101101, 101110, 101111, 110000, 110001, 110010, 110011, 110100, 110101, 110110, 110111, 111000, 111001, 111010, 111011, 111100, 111101, 111110, 111111:
      begin
        tile_int = tile_n;
        status[2] = mineMap[tile_int];
        status[1] = flagMap[tile_int];
        status[0] = stepMap[tile_int];
      end
    endcase
  end
endmodule