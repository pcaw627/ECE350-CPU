


module comp_32(EQ1, GT1, A, B, EQ0, GT0);
    input EQ1, GT1;
    input [31:0] A, B;
    output EQ0, GT0;

    wire C3_gt0, C2_gt0, C1_gt0, C0_gt0;
    wire C3_eq0, C2_eq0, C1_eq0, C0_eq0;

    // LSB
    comp_8 C0(.EQ1(C1_eq0), .GT1(C1_gt0), .A(A[7:0]),   .B(B[7:0]),   .EQ0(EQ0),    .GT0(GT0));
    comp_8 C1(.EQ1(C2_eq0), .GT1(C2_gt0), .A(A[15:8]),  .B(B[15:8]),  .EQ0(C1_eq0), .GT0(C1_gt0));
    comp_8 C2(.EQ1(C3_eq0), .GT1(C3_gt0), .A(A[23:16]), .B(B[23:16]), .EQ0(C2_eq0), .GT0(C2_gt0));
    comp_8 C3(.EQ1(EQ1),    .GT1(GT1),    .A(A[31:24]), .B(B[31:24]), .EQ0(C3_eq0), .GT0(C3_gt0));
    // MSB

    // assign highest MSB EQ1 to 1 ("equal so far, keep searching lower")
    // assign highest MSB GT1 to 0 ("don't know if they're gt yet, keep searching lower")

    // iverilog -o comp_32 -s comp_32_tb .\comp_32.v .\comp_8.v .\comp_2.v .\mux_8.v .\mux_2.v .\mux_4.v .\comp_32_tb.v
    // iverilog -o comp_32 -s comp_32_tb .\comp_32.v .\comp_8.v .\comp_2.v .\comp_mux_8.v .\comp_mux_2.v .\comp_mux_4.v .\comp_32_tb.v

endmodule