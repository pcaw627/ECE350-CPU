module multi_clock_delay #(parameter WIDTH=3, parameter CYCLES=1) (q, d, clr, clk);
    input clr, clk;
    input [WIDTH-1 : 0] d;
    output [WIDTH-1 : 0] q;

    // reg [WIDTH-1:0] scd_d [0:CYCLES-1];
    wire [WIDTH-1:0] scd_q [0:CYCLES-1];

    single_clock_delay #(.WIDTH(WIDTH)) scd_first(
        .q(scd_q[0]),
        .d(d),
        .clr(clr),
        .clk(clk)
    );
    
    genvar i;
    generate
        for (i=1; i<CYCLES; i = i+1) begin : delay_loop 
            single_clock_delay #(.WIDTH(WIDTH)) scd(
                .q(scd_q[i]),
                .d(scd_q[i-1]),
                .clr(clr),
                .clk(clk)
            );
        end
    endgenerate

    assign q = scd_q[CYCLES-1];    

endmodule