module cla_8 (
    input [7:0] A,
    input [7:0] B,
    input Cin,
    output [7:0] Sum,
    output Cout,
    output Pout, // Propagate output for higher-level CLA
    output Gout  // Generate output for higher-level CLA
);
    wire [7:0] P, G;
    wire [7:0] C;
    wire [27:0] term; 

    // need generate fns
    and_1 g0_gate(.out(G[0]), .in1(A[0]), .in2(B[0]));
    and_1 g1_gate(.out(G[1]), .in1(A[1]), .in2(B[1]));
    and_1 g2_gate(.out(G[2]), .in1(A[2]), .in2(B[2]));
    and_1 g3_gate(.out(G[3]), .in1(A[3]), .in2(B[3]));
    and_1 g4_gate(.out(G[4]), .in1(A[4]), .in2(B[4]));
    and_1 g5_gate(.out(G[5]), .in1(A[5]), .in2(B[5]));
    and_1 g6_gate(.out(G[6]), .in1(A[6]), .in2(B[6]));
    and_1 g7_gate(.out(G[7]), .in1(A[7]), .in2(B[7]));

    // need propagation fns
    or_1 p0_gate(.out(P[0]), .in1(A[0]), .in2(B[0]));
    or_1 p1_gate(.out(P[1]), .in1(A[1]), .in2(B[1]));
    or_1 p2_gate(.out(P[2]), .in1(A[2]), .in2(B[2]));
    or_1 p3_gate(.out(P[3]), .in1(A[3]), .in2(B[3]));
    or_1 p4_gate(.out(P[4]), .in1(A[4]), .in2(B[4]));
    or_1 p5_gate(.out(P[5]), .in1(A[5]), .in2(B[5]));
    or_1 p6_gate(.out(P[6]), .in1(A[6]), .in2(B[6]));
    or_1 p7_gate(.out(P[7]), .in1(A[7]), .in2(B[7]));

    //////// Carry terms (prop and gen components)
    // C0 = Cin
    assign C[0] = Cin;
    assign Cout = C[7];

    // generally c_i+1 = g_i + (p_i & c_i)
    // for each c_i below, we will make each OR term its own wire

    //             t_0
    // c_1 = g_0 + p_0 & c_0
    and (term[0], P[0], C[0]);
    or (C[1], G[0], term[0]);

    //                                t_1           t_2 = p_1 & t_0
    // c_2 = g_1 + p_1 & c_1  = g_1 + (p_1 & g_0) + (p_1 & p_0 & c_0)
    and (term[1], P[1], G[0]);
    and (term[2], P[1], P[0], C[0]);
    or (C[2], G[1], term[1], term[2]);

    //                                t_3           t_4 = p_2 & t_1     t_5 = p_2 & t_2
    // c_3 = g_2 + p_2 & c_2  = g_2 + (p_2 & g_1) + (p_2 & p_1 & g_0) + (p_2 & p_1 & p_0 & c_0)
    and (term[3], P[2], G[1]);
    and (term[4], P[2], P[1], G[0]);
    and (term[5], P[2], P[1], P[0], C[0]);
    or (C[3], G[2], term[3], term[4], term[5]);

    //                                t_9           t_10 = p_3 & t_4    t_11 = p_3 & t_5          t_12 = p_3 & t_6
    // c_4 = g_3 + p_3 & c_3  = g_3 + (p_3 & g_2) + (p_3 & p_2 & g_1) + (p_3 & p_2 & p_1 & g_0) + (p_3 & p_2 & p_1 & p_0 & c_0)
    and (term[6], P[3], G[2]);
    and (term[7], P[3], P[2], G[1]);
    and (term[8], P[3], P[2], P[1], G[0]);
    and (term[9], P[3], P[2], P[1], P[0], C[0]);
    or (C[4], G[3], term[6], term[7], term[8], term[9]);

    //                                      t_16          t_17 = p_4 & t_9    t_18 = p_4 & t_10         t_19 = p_4 & t_11               t_20 = p_4 & t_12
    // c_5 = g_4 + p_4 & c_4  = c_5 = g_4 + (p_4 & g_3) + (p_4 & p_3 & g_2) + (p_4 & p_3 & p_2 & g_1) + (p_4 & p_3 & p_2 & p_1 & g_0) + (p_4 & p_3 & p_2 & p_1 & p_0 & c_0)
    and (term[10], P[4], G[3]);
    and (term[11], P[4], P[3], G[2]);
    and (term[12], P[4], P[3], P[2], G[1]);
    and (term[13], P[4], P[3], P[2], P[1], G[0]);
    and (term[14], P[4], P[3], P[2], P[1], P[0], C[0]);
    or (C[5], G[4], term[10], term[11], term[12], term[13], term[14]);
    

    //                                      t_25          t_26 = t_16
    // c_6 = g_5 + p_5 & c_5  = c_6 = g_5 + (p_5 & g_4) + (p_5 & p_4 & g_3) + (p_5 & p_4 & p_3 & g_2) + (p_5 & p_4 & p_3 & p_2 & g_1) + (p_5 & p_4 & p_3 & p_2 & p_1 & g_0) + (p_5 & p_4 & p_3 & p_2 & p_1 & p_0 & c_0)
    and (term[15], P[5], G[4]);
    and (term[16], P[5], P[4], G[3]);
    and (term[17], P[5], P[4], P[3], G[2]);
    and (term[18], P[5], P[4], P[3], P[2], G[1]);
    and (term[19], P[5], P[4], P[3], P[2], P[1], G[0]);
    and (term[20], P[5], P[4], P[3], P[2], P[1], P[0], C[0]);
    or (C[6], G[5], term[15], term[16], term[17], term[18], term[19], term[20]);


    // c_7 = g_6 + p_6 & c_6  = c_7 = g_6 + (p_6 & g_5) + (p_6 & p_5 & g_4) + (p_6 & p_5 & p_4 & g_3) + (p_6 & p_5 & p_4 & p_3 & g_2) + (p_6 & p_5 & p_4 & p_3 & p_2 & g_1) + (p_6 & p_5 & p_4 & p_3 & p_2 & p_1 & g_0) + (p_6 & p_5 & p_4 & p_3 & p_2 & p_1 & p_0 & c_0)
    and (term[21], P[6], G[5]);
    and (term[22], P[6], P[5], G[4]);
    and (term[23], P[6], P[5], P[4], G[3]);
    and (term[24], P[6], P[5], P[4], P[3], G[2]);
    and (term[25], P[6], P[5], P[4], P[3], P[2], G[1]);
    and (term[26], P[6], P[5], P[4], P[3], P[2], P[1], G[0]);
    and (term[27], P[6], P[5], P[4], P[3], P[2], P[1], P[0], C[0]);
    or (C[7], G[6], term[21], term[22], term[23], term[24], term[25], term[26], term[27]);

    wire [7:0] unused_carry;
    //////// Sum (using carry components])
    full_adder S_0(Sum[0], unused_carry[0], A[0], B[0], C[0]);
    full_adder S_1(Sum[1], unused_carry[0], A[1], B[1], C[1]);
    full_adder S_2(Sum[2], unused_carry[2], A[2], B[2], C[2]);
    full_adder S_3(Sum[3], unused_carry[3], A[3], B[3], C[3]);
    full_adder S_4(Sum[4], unused_carry[4], A[4], B[4], C[4]);
    full_adder S_5(Sum[5], unused_carry[5], A[5], B[5], C[5]);
    full_adder S_6(Sum[6], unused_carry[6], A[6], B[6], C[6]);
    full_adder S_7(Sum[7], unused_carry[7], A[7], B[7], C[7]);

    // doesnt work
    // wire [7:0] unused_carry;
    // //////// Sum (using carry components])
    // full_adder S_0(Sum[0], C[0], A[0], B[0], Cin);
    // full_adder S_1(Sum[1], C[0], A[1], B[1], C[0]);
    // full_adder S_2(Sum[2], C[2], A[2], B[2], C[1]);
    // full_adder S_3(Sum[3], C[3], A[3], B[3], C[2]);
    // full_adder S_4(Sum[4], C[4], A[4], B[4], C[3]);
    // full_adder S_5(Sum[5], C[5], A[5], B[5], C[4]);
    // full_adder S_6(Sum[6], C[6], A[6], B[6], C[5]);
    // full_adder S_7(Sum[7], C[7], A[7], B[7], C[6]);

    assign Pout = P[7];
    assign Gout = G[7];

endmodule

// iverilog -o cla_8 -s cla_8_tb .\cla_8.v .\cla_8_tb.v .\logic\or_1.v .\logic\and_1.v .\full_adder.v
// vvp .\cla_8
