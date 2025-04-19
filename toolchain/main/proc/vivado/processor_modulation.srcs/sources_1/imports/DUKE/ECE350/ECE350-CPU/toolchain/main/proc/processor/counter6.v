module counter6(count, clk, clr, en);
    output [5:0] count;
    input clk, clr, en;

    // Bit 0 toggles on every enabled clock pulse.
    tff t0(
        .q(count[0]),
        .t(en),
        .clk(clk),
        .clr(clr)
    );

    // Bit 1 toggles when en is high and count[0] is 1.
    wire t1;
    assign t1 = en & count[0];
    tff t1ff(
        .q(count[1]),
        .t(t1),
        .clk(clk),
        .clr(clr)
    );

    // Bit 2 toggles when en is high and count[0]&count[1] are 1.
    wire t2;
    assign t2 = en & count[0] & count[1];
    tff t2ff(
        .q(count[2]),
        .t(t2),
        .clk(clk),
        .clr(clr)
    );

    // Bit 3 toggles when en is high and count[0]&count[1]&count[2] are 1.
    wire t3;
    assign t3 = en & count[0] & count[1] & count[2];
    tff t3ff(
        .q(count[3]),
        .t(t3),
        .clk(clk),
        .clr(clr)
    );

    // Bit 4 toggles when en is high and count[0]&count[1]&count[2]&count[3] are 1.
    wire t4;
    assign t4 = en & count[0] & count[1] & count[2] & count[3];
    tff t4ff(
        .q(count[4]),
        .t(t4),
        .clk(clk),
        .clr(clr)
    );

    // Bit 5 toggles when en is high and count[0]&count[1]&count[2]&count[3]&count[4] are 1.
    wire t5;
    assign t5 = en & count[0] & count[1] & count[2] & count[3] & count[4];
    tff t5ff(
        .q(count[5]),
        .t(t5),
        .clk(clk),
        .clr(clr)
    );
endmodule