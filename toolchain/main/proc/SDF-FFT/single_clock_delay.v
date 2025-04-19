module single_clock_delay #(parameter WIDTH=3) (q, d, clr, clk);
    input clr, clk;
    input [WIDTH-1 : 0] d;
    output [WIDTH-1 : 0] q;

    wire [WIDTH-1 : 0] dff1_out_i;

    genvar i;
    generate
        for (i=0; i<WIDTH; i = i+1) begin : dff_loop
            wire dff_out_i;
            dffe_ref dff1(.q(dff_out_i), .d(d[i]), .clr(clr), .clk(clk), .en(1'b1));
            dffe_ref dff2(.q(q[i]), .d(dff_out_i), .clr(clr), .clk(~clk), .en(1'b1));

        end
    endgenerate

endmodule