module counter4 (count, clk, clr, en, cout);

    output [3:0] count;
    output cout;
    input clk, clr, en;

    tff t0_tff(
        .q(count[0]),
        .t(en),
        .clk(clk),
        .clr(clr)
    );

    wire t1;
    assign t1 = en & count[0];
    tff t1_tff(
        .q(count[1]),
        .t(t1),
        .clk(clk),
        .clr(clr)
    );

    wire t2;
    assign t2 = en & count[1] & count[0];
    tff t2_tff(
        .q(count[2]),
        .t(t2),
        .clk(clk),
        .clr(clr)
    );

    wire t3;
    assign t3 = en & count[2] & count[1] & count[0];
    tff t3_tff(
        .q(count[3]),
        .t(t3),
        .clk(clk),
        .clr(clr)
    );

    assign cout = (count == 4'b0000) && (~clk);
    
endmodule