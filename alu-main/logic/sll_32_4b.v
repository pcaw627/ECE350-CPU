module sll_32_4b (
    input [31:0] in,
    output [31:0] out
);

    assign out[3:0] = 4'b0000;
    assign out[31:4] = in[27:0];
endmodule
