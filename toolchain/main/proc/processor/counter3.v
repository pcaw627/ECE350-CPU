module counter3(count, clk, clr, en);
   output [2:0] count;
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
endmodule
