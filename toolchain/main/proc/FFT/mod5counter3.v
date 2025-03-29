module mod5counter3 (count, clk, clr, en);

    output [2:0] count;
    input clk, clr, en;

    wire t0_out, t1_out, t2_out;

    tff t0(
        .q(t0_out),
        .t((t2_out && t1_out) || t0_out),
        .clk(clk),
        .clr(clr)
    );

    wire t1;
    assign t1 = en & count[0];
    tff t1(
        .q(t1_out),
        .t(t2_out),
        .clk(clk),
        .clr(clr)
    );

    wire t2;
    assign t2 = en & count[1] & count[0];
    tff t2(
        .q(t2_out),
        .t(~t0_out),
        .clk(clk),
        .clr(clr)
    );
    
endmodule