

module comp_2(EQ1, GT1, A, B, EQ0, GT0);
    input EQ1, GT1;
    input [1:0] A, B;
    output EQ0, GT0;
    wire w1;

    wire [2:0] select;
    wire eqmux_out;

    assign select = {A[1], A[0], B[1]};
    // h(a1 a0 b1 b0) = B0' * f(A1, A0, B1, B0=0) + B0 * f(A1, A0, B1, B0=1)
    wire notB;
    not (notB, B[0]);

    wire notEQ1;
    not (notEQ1, EQ1);

    wire notGT1;
    not (notGT1, GT1);
    
    
    comp_mux_8 eqmux(.select(select), .out(eqmux_out), .in0(notB), .in1(1'b0), .in2(B[0]), .in3(1'b0), .in4(1'b0), .in5(notB), .in6(1'b0), .in7(B[0]));
    and eq_out(EQ0, EQ1, notGT1, eqmux_out);
    // eqmux is 1 when current block inputs are equal (regardless of passed in values)
    // 1 by default: 0 if we have (!G1 & !A1 & B1)

    // 
    wire gt_mux_out;

    comp_mux_8 gt_mux(.select(select), .out(gt_mux_out), .in0(1'b0), .in1(1'b0), .in2(notB), .in3(1'b0), .in4(1'b1), .in5(1'b0), .in6(1'b1), .in7(notB));
    // wire gtmuxout;
    // and(gtmuxout, notEQ1, GT1);


    wire temp3;
    and (temp3, gt_mux_out, EQ1, notGT1);

    wire temp4;
    and (temp4, notEQ1, GT1);

    or (GT0, temp4, temp3);



    // gtmuxout is 1 when A for current block is greater than B for current block (regardless of passed in values).



    // iverilog -o comp_2 -s comp_2_tb .\comp_2.v .\mux_8.v .\mux_2.v .\mux_4.v .\comp_2_tb.v
    // 
endmodule
    