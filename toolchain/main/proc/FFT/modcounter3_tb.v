module modcounter3_tb;
  parameter N = 5;
  parameter WIDTH = 3;

  reg clk;
  reg clr;
  wire [WIDTH-1:0] out;
  wire cout;

  mod5counter3 u0  ( 	.clk(clk),
                	.clr(clr),
                	.out(out),
                  .cout(cout));

  always #10 clk = ~clk;

  initial begin
    {clk, clr} <= 0;

    $monitor ("T=%0t clr=%0b out=0x%0h cout=%0b", $time, clr, out, cout);
    repeat(2) @ (posedge clk);
    clr <= 1;

    repeat(20) @ (posedge clk);
    $finish;
  end
endmodule