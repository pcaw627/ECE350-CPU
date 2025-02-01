module sll_32 (
    input [31:0] in,
    input [4:0] shamt,
    output [31:0] out
);

    // shifted values
    wire [31:0] s_16_out;
    wire [31:0] s_8_out;
    wire [31:0] s_4_out;
    wire [31:0] s_2_out;
    wire [31:0] s_1_out;

    // mux output values (dependent on shamt bit for that mux)
    wire [31:0] s_16_muxout;
    wire [31:0] s_8_muxout;
    wire [31:0] s_4_muxout;
    wire [31:0] s_2_muxout;
    wire [31:0] s_1_muxout; // is the module output

    // shifters
    sll_32_16b s16(.in(in),        .out(s_16_out));
    sll_32_8b s8(.in(s_16_muxout), .out(s_8_out));
    sll_32_4b s4(.in(s_8_muxout),  .out(s_4_out));
    sll_32_2b s2(.in(s_4_muxout),  .out(s_2_out));
    sll_32_1b s1(.in(s_2_muxout),  .out(s_1_out));
    
    // muxes
    mux_2 s_16_mux (.out(s_16_muxout), .select(shamt[4]), .in0(in),          .in1(s_16_out));
    mux_2 s_8_mux (.out(s_8_muxout),   .select(shamt[3]), .in0(s_16_muxout), .in1(s_8_out));
    mux_2 s_4_mux (.out(s_4_muxout),   .select(shamt[2]), .in0(s_8_muxout),  .in1(s_4_out));
    mux_2 s_2_mux (.out(s_2_muxout),   .select(shamt[1]), .in0(s_4_muxout),  .in1(s_2_out));
    mux_2 s_1_mux (.out(out),          .select(shamt[0]), .in0(s_2_muxout),  .in1(s_1_out));

endmodule

// iverilog -o sll_32 -s sll_32_tb -c .\sll_reqs.txt