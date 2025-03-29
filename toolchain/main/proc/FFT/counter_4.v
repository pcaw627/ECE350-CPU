module counter4 (count, clk, clr, en);

    output [3:0] count;
    input clk, clr, en;

    tff t0(
        .q(count[0]),
        .t(en),
        .clk(clk),
        .clr(clr)
    );

    wire t1;
    assign t1 = en & count[0];
    tff t1(
        .q(count[1]),
        .t(t1),
        .clk(clk),
        .clr(clr)
    );

    wire t2;
    assign t2 = en & count[1] & count[0];
    tff t2(
        .q(count[2]),
        .t(t2),
        .clk(clk),
        .clr(clr)
    );

    wire t3;
    assign t3 = en & count[2] & count[1] & count[0];
    tff t3(
        .q(count[3]),
        .t(t3),
        .clk(clk),
        .clr(clr)
    );
    
endmodule