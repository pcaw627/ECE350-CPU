//----------------------------------------------------------------------
//  Butterfly: Add/Sub and Scaling
//----------------------------------------------------------------------
module Butterfly #(
    parameter   WIDTH = 16,
    parameter RH = 0
)(
    input signed  [WIDTH-1:0] x0_real,  //  Input Data #0 (real)
    input signed  [WIDTH-1:0] x0_imag,  //  Input Data #0 (imag)
    input signed  [WIDTH-1:0] x1_real,  //  Input Data #1 (real)
    input signed  [WIDTH-1:0] x1_imag,  //  Input Data #1 (imag)
    output signed  [WIDTH-1:0] y0_real,  //  Output Data #0 (real)
    output signed  [WIDTH-1:0] y0_imag,  //  Output Data #0 (imag)
    output signed  [WIDTH-1:0] y1_real,  //  Output Data #1 (real)
    output signed  [WIDTH-1:0] y1_imag   //  Output Data #1 (imag)
);

wire signed [WIDTH:0] add_real, add_imag, sub_real, sub_imag;

//  Add/Sub
assign  add_real = x0_real + x1_real;
assign  add_imag = x0_imag + x1_imag;
assign  sub_real = x0_real - x1_real;
assign  sub_imag = x0_imag - x1_imag;

//  Scaling
assign  y0_real = (add_real) >>> 1;
assign  y0_imag = (add_imag) >>> 1;
assign  y1_real = (sub_real) >>> 1;
assign  y1_imag = (sub_imag) >>> 1;

endmodule
