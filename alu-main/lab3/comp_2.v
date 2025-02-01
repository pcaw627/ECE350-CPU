

module comp_2(EQ1, GT1, A, B, EQ0, GT0);
    input EQ1, GT1;
    input [1:0] A, B;
    output EQ0, GT0;
    wire w1;

    wire [2:0] select;
    wire eqmux_out;

    assign select = {A[1], A[0], B[1]};
    // h(a1 a0 b1 b0) = B0' * f(A1, A0, B1, B0=0) + B0 * f(A1, A0, B1, B0=1)
    wire zero;
    assign zero = 1'b0;
    wire one;
    assign one = !zero;
    
    
    comp_mux_8 eqmux(.select(select), .out(eqmux_out), .in0(!B[0]), .in1(zero), .in2(B[0]), .in3(zero), .in4(zero), .in5(!B[0]), .in6(zero), .in7(B[0]));
    and eq_out(EQ0, EQ1, !GT1, eqmux_out);


    // eq_1 = EQ1 & !GT1 & !A1 & !A0 & !B1 & !B0
    // eq_2 = EQ1 & !GT1 & !A1 & A0 & !B1 & B0
    // eq_3 = EQ1 & !GT1 & A1 & !A0 & B1 & !B0
    // eq_4 = EQ1 & !GT1 & A1 & A0 & B1 & B0

    // EQ0 = eq_1 | eq_2 | eq_3 | eq_4  = (EQ1 & !GT1) & [(!A1 & !A0 & !B1 & !B0) | (!A1 & A0 & !B1 & B0) | (A1 & !A0 & B1 & !B0) | (A1 & A0 & B1 & B0)]
    // EQ0 = (EQ1 & !GT1) & [eqmux_out]

    // A1A0B1 : logic output
    // 000 : !B0
    // 010 : B0
    // 101 : !B0
    // 111 : B0
    // the rest tied to 0.

    // gt_1 = !EQ1 & GT1
    // gt_2 = EQ1 & !GT1 & !A1 & A0 & !B1 & !B0
    // gt_3 = EQ1 & !GT1 & A1 & !B1
    // gt_4 = EQ1 & !GT1 & A1 & A0 & B1 & !B0

    // h(a1 a0 b1 b0) = B0' * f(A1, A0, B1, B0=0) + B0 * f(A1, A0, B1, B0=1)
    // A1A0B1: logic output
    // 010: !B0
    // 111: !B0
    // 1x0: 1
    //default : 0

    // 1 by default: 0 if we have (!G1 & !A1 & B1)

    // 
    wire gt_mux_out;

    comp_mux_8 gt_mux(.select(select), .out(gt_mux_out), .in0(zero), .in1(zero), .in2(!B[0]), .in3(zero), .in4(one), .in5(zero), .in6(one), .in7(!B[0]));

    or mux_out(GT0, gt_mux_out, !EQ1 & GT1);



    // iverilog -o comp_2 -s comp_2_tb .\comp_2.v .\mux_8.v .\mux_2.v .\mux_4.v .\comp_2_tb.v
    // 
endmodule
    