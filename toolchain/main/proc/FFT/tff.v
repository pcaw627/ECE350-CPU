module tff(q, t, clk, clr);
input t, clk, clr;
output q;
wire d;

assign d = t ^ q;

dffe_ref dff(
    .q(q),
    .d(d),
    .clk(clk),
    .en(1'b1),
    .clr(clr)
);


endmodule