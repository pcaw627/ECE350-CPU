module rotate_left_by_S_5 (
    input  wire       clk,
    input  wire       clr,
    input  wire [4:0] d,
    input  wire [2:0] s,   // valid values 0 to 4
    output reg  [4:0] q 
);

  // On clock edge or asynchronous clear, update the output.
  always @(posedge clk or posedge clr) begin
    if (clr)
        q <= 5'b0;
    else begin
      case (s)
        3'd0: q  <= d;                                 // No rotation
        3'd1: q <= {d[3:0], d[4]};                  // Rotate left by 1: BCDEA
        3'd2: q <= {d[2:0], d[4:3]};                // Rotate left by 2: CDEAB
        3'd3: q <= {d[1:0], d[4:2]};                // Rotate left by 3: DEABC
        3'd4: q <= {d[0],   d[4:1]};                // Rotate left by 4: EABCD
        default: q <= d; // Default case (if s > 4, though only 0-4 are expected)
      endcase
    end
  end

endmodule
