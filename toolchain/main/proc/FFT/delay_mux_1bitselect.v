module #(parameter WIDTH=1) delay_mux_1bitselect(
    input clock,
    input select,
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    output [WIDTH-1:0] out);

    wire [WIDTH-1:0] out_predelay;
    assign out_predelay = select ? in1 : in0;

    single_clock_delay #(WIDTH=WIDTH) scd (
        .q(out),
        .d(out_predelay),
        .clr(1'b0),
        .clk(clk)
    );

endmodule