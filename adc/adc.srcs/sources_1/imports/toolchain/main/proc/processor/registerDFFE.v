module registerDFFE #(parameter WIDTH = 32) (
    input                 clock,   // We will feed ~clock for falling-edge
    input                 reset,   // Asynchronous clear
    input                 we,      // Write enable
    input      [WIDTH-1:0] d,      // Data in
    output     [WIDTH-1:0] q       // Data out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : dffe_gen
            dffe_ref dff(
                .q   (q[i]),
                .d   (d[i]),
                .clk (clock),
                .en  (we),
                .clr (reset)
            );
        end
    endgenerate
endmodule
