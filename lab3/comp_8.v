


module comp_8(EQ1, GT1, A, B, EQ0, GT0);
    input EQ1, GT1;
    input [7:0] A, B;
    output EQ0, GT0;

    wire zero;
    assign zero = 1'b0;
    wire one;
    assign one = !zero;

    wire C3_gt0, C2_gt0, C1_gt0, C0_gt0;
    wire C3_eq0, C2_eq0, C1_eq0, C0_eq0;

    // LSB
    comp_2 C0(.EQ1(C1_eq0), .GT1(C1_gt0), .A(A[1:0]), .B(B[1:0]), .EQ0(EQ0),    .GT0(GT0));
    comp_2 C1(.EQ1(C2_eq0), .GT1(C2_gt0), .A(A[3:2]), .B(B[3:2]), .EQ0(C1_eq0), .GT0(C1_gt0));
    comp_2 C2(.EQ1(C3_eq0), .GT1(C3_gt0), .A(A[5:4]), .B(B[5:4]), .EQ0(C2_eq0), .GT0(C2_gt0));
    comp_2 C3(.EQ1(EQ1),    .GT1(GT1),   .A(A[7:6]), .B(B[7:6]), .EQ0(C3_eq0), .GT0(C3_gt0));
    // MSB

    // assign highest MSB EQ1 to 1 ("equal so far, keep searching lower")
    // assign highest MSB GT1 to 0 ("don't know if they're gt yet, keep searching lower")

    // iverilog -o comp_8 -s comp_8_tb .\comp_8.v .\comp_2.v .\mux_8.v .\mux_2.v .\mux_4.v .\comp_8_tb.v

endmodule