module delay_mux_2bitselect #(parameter WIDTH=1) (
    input clock,
    input [1:0] select,
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input [WIDTH-1:0] in3,
    output [WIDTH-1:0] out);

    wire [WIDTH-1:0] out_predelay;
    assign out_predelay = select[1] ? 
    ( // MSB 1
        select[0] ? in3 : in2
    ) : 
    ( // MSB 0
        select[0] ? in1 : in0
    );

    single_clock_delay #(.WIDTH(WIDTH)) scd (
        .q(out),
        .d(out_predelay),
        .clr(1'b0),
        .clk(clock)
    );

endmodule