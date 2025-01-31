module cla_32 (
    input [31:0] A,
    input [31:0] B,
    input Cin,
    output [31:0] Sum,
    output Cout
);
    // block level
    wire [3:0] P, G, C; 
    // Cin, C[0] is C_8, C[1] is C_16, C[2] is C_24, C[3] is C_32 = Cout

    // index level
    wire [31:0] p, g;
    wire [40:0] term;
    
    // Instantiate four 8-bit CLA blocks
    cla_8 CLA0 (
        .A(A[7:0]),
        .B(B[7:0]),
        .Cin(C[0]),
        .Sum(Sum[7:0]),
        .Cout(C[1]),
        .Pout(P[0]),
        .Gout(G[0])
    );

    cla_8 CLA1 (
        .A(A[15:8]),
        .B(B[15:8]),
        .Cin(C[1]),
        .Sum(Sum[15:8]),
        .Cout(C[2]),
        .Pout(P[1]),
        .Gout(G[1])
    );

    cla_8 CLA2 (
        .A(A[23:16]),
        .B(B[23:16]),
        .Cin(C[2]),
        .Sum(Sum[23:16]),
        .Cout(C[3]),
        .Pout(P[2]),
        .Gout(G[2])
    );

    cla_8 CLA3 (
        .A(A[31:24]),
        .B(B[31:24]),
        .Cin(C[3]),
        .Sum(Sum[31:24]),
        .Cout(Cout),
        .Pout(P[3]),
        .Gout(G[3])
    );

    ////////////////////////////////// attach sum
    // assign Sum = {CLA0.Sum, CLA1.Sum, CLA2.Sum, CLA3.Sum};


    ////////////////////////////////// first calculate p and g (index level)
    or (p[0], A[0], B[0]);
    or (p[1], A[1], B[1]);
    or (p[2], A[2], B[2]);  
    or (p[3], A[3], B[3]);
    or (p[4], A[4], B[4]);
    or (p[5], A[5], B[5]);
    or (p[6], A[6], B[6]);
    or (p[7], A[7], B[7]);
    or (p[8], A[8], B[8]);
    or (p[9], A[9], B[9]);
    or (p[10], A[10], B[10]);
    or (p[11], A[11], B[11]);
    or (p[12], A[12], B[12]);
    or (p[13], A[13], B[13]);
    or (p[14], A[14], B[14]);
    or (p[15], A[15], B[15]);
    or (p[16], A[16], B[16]);
    or (p[17], A[17], B[17]);
    or (p[18], A[18], B[18]);
    or (p[19], A[19], B[19]);
    or (p[20], A[20], B[20]);
    or (p[21], A[21], B[21]);
    or (p[22], A[22], B[22]);
    or (p[23], A[23], B[23]);
    or (p[24], A[24], B[24]);
    or (p[25], A[25], B[25]);
    or (p[26], A[26], B[26]);
    or (p[27], A[27], B[27]);
    or (p[28], A[28], B[28]);
    or (p[29], A[29], B[29]);
    or (p[30], A[30], B[30]);
    or (p[31], A[31], B[31]);

    and (g[0], A[0], B[0]);
    and (g[1], A[1], B[1]);
    and (g[2], A[2], B[2]);
    and (g[3], A[3], B[3]);
    and (g[4], A[4], B[4]);
    and (g[5], A[5], B[5]);
    and (g[6], A[6], B[6]);
    and (g[7], A[7], B[7]);
    and (g[8], A[8], B[8]);
    and (g[9], A[9], B[9]);
    and (g[10], A[10], B[10]);
    and (g[11], A[11], B[11]);
    and (g[12], A[12], B[12]);
    and (g[13], A[13], B[13]);
    and (g[14], A[14], B[14]);
    and (g[15], A[15], B[15]);
    and (g[16], A[16], B[16]);
    and (g[17], A[17], B[17]);
    and (g[18], A[18], B[18]);
    and (g[19], A[19], B[19]);
    and (g[20], A[20], B[20]);
    and (g[21], A[21], B[21]);
    and (g[22], A[22], B[22]);
    and (g[23], A[23], B[23]);
    and (g[24], A[24], B[24]);
    and (g[25], A[25], B[25]);
    and (g[26], A[26], B[26]);
    and (g[27], A[27], B[27]);
    and (g[28], A[28], B[28]);
    and (g[29], A[29], B[29]);
    and (g[30], A[30], B[30]);
    and (g[31], A[31], B[31]);

    //////////////////////////////////// now generate P and G (block level)
    and (P[0], p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    and (P[1], p[8], p[9], p[10], p[11], p[12], p[13], p[14], p[15]);
    and (P[2], p[16], p[17], p[18], p[19], p[20], p[21], p[22], p[23]);
    and (P[3], p[24], p[25], p[26], p[27], p[28], p[29], p[30], p[31]);


    // G_0
    and (term[10], p[7], g[6]);
    and (term[11], p[7], p[6], g[5]);
    and (term[12], p[7], p[6], p[5], g[4]);
    and (term[13], p[7], p[6], p[5], p[4], g[3]);
    and (term[14], p[7], p[6], p[5], p[4], p[3], g[2]);
    and (term[15], p[7], p[6], p[5], p[4], p[3], p[2], g[1]);
    and (term[16], p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    or (G[0], g[7], term[10], term[11], term[12], term[13], term[14], term[15], term[16]);

    // G_1
    and (term[18], p[15], g[14]);
    and (term[19], p[15], p[14], g[13]);
    and (term[20], p[15], p[14], p[13], g[12]);
    and (term[21], p[15], p[14], p[13], p[12], g[11]);
    and (term[22], p[15], p[14], p[13], p[12], p[11], g[10]);
    and (term[23], p[15], p[14], p[13], p[12], p[11], p[10], g[9]);
    and (term[24], p[15], p[14], p[13], p[12], p[11], p[10], p[9], g[8]);
    or (G[1], g[15], term[18], term[19], term[20], term[21], term[22], term[23], term[24]);

    // G_2
    and (term[26], p[23], g[22]);
    and (term[27], p[23], p[22], g[21]);
    and (term[28], p[23], p[22], p[21], g[20]);
    and (term[29], p[23], p[22], p[21], p[20], g[19]);
    and (term[30], p[23], p[22], p[21], p[20], p[19], g[18]);
    and (term[31], p[23], p[22], p[21], p[20], p[19], p[18], g[17]);
    and (term[32], p[23], p[22], p[21], p[20], p[19], p[18], p[17], g[16]);
    or (G[2], g[23], term[26], term[27], term[28], term[29], term[30], term[31], term[32]);

    // G_3
    and (term[34], p[31], g[30]);
    and (term[35], p[31], p[30], g[29]);
    and (term[36], p[31], p[30], p[29], g[28]);
    and (term[37], p[31], p[30], p[29], p[28], g[27]);
    and (term[38], p[31], p[30], p[29], p[28], p[27], g[26]);
    and (term[39], p[31], p[30], p[29], p[28], p[27], p[26], g[25]);
    and (term[40], p[31], p[30], p[29], p[28], p[27], p[26], p[25], g[24]);
    or (G[3], g[31], term[34], term[35], term[36], term[37], term[38], term[39], term[40]);




    //////////////////////////////////// and then generate C (block level)
    // Cin, C[0] is C_8, C[1] is C_16, C[2] is C_24, C[3] is C_32 = Cout
    
    and (term[0], P[0], Cin);
    or (C[0], G[0], term[0]); // C_8

    and(term[1], P[1], P[0], C[0]);
    and(term[2], P[1], G[0]);
    or (C[1], G[1], term[1], term[2]);   // C_16

    
    and(term[3], P[2], P[1], P[0], C[1]);
    and(term[4], P[2], P[1], G[0]);
    and(term[5], P[2], G[1]);
    or (C[2], G[2], term[3], term[4], term[5]);   // C_24


    and(term[6], P[3], P[2], P[1], P[0], C[2]);
    and(term[7], P[3], P[2], P[1], G[0]);
    and(term[8], P[3], P[2], G[1]);
    and(term[9], P[3], G[2]);
    or (C[3], G[3], term[6], term[7], term[8], term[9]);   // C_32

endmodule
// iverilog -o cla_32 -s cla_32_tb .\cla_32.v .\cla_32_tb.v
// vvp .\cla_32