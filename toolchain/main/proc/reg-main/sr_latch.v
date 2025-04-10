module sr_latch (
    input  wire S,      // Set input
    input  wire R,      // Reset input
    input  wire clk,    // Clock (enable for latch transparency)
    output reg  Q      // Q output
);

// Tie asynchronous preset and clear to 0 (inactive)
// (They are not used in this design)
 

initial begin
    Q <= 1'b0;
end

// Level-sensitive latch: when clk is high the latch is transparent.
always @(*) begin
    if (clk) begin
        // Check SR conditions when clock is high
        if (S && !R)
            Q <= 1'b1;      // Set Q if S=1 and R=0
        else if (!S && R)
            Q <= 1'b0;      // Reset Q if S=0 and R=1
        // else if (S && R)
        //     Q <= 1'b0;
        // If S and R are both 0 (or both 1) then Q holds its previous state.
    end
    // When clk is low, the latch holds the previous state.
end

endmodule
