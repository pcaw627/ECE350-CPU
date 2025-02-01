module cla_32 (
    input [31:0] A,
    input [31:0] B,
    input Cin,
    output [31:0] Sum,
    output Cout
);
    // block level vars
    wire [3:0] P, G;
    wire [2:0] C; 
    wire [9:0] term;
    
    
    cla_8 CLA0 (
        .A(A[7:0]),
        .B(B[7:0]),
        .Cin(Cin),
        .Sum(Sum[7:0]),
        .Cout(), // don't ripple
        .Pout(P[0]),
        .Gout(G[0])
    );

    cla_8 CLA1 (
        .A(A[15:8]),
        .B(B[15:8]),
        .Cin(C[0]),
        .Sum(Sum[15:8]),
        .Cout(), // don't ripple
        .Pout(P[1]),
        .Gout(G[1])
    );

    cla_8 CLA2 (
        .A(A[23:16]),
        .B(B[23:16]),
        .Cin(C[1]),
        .Sum(Sum[23:16]),
        .Cout(), // don't ripple
        .Pout(P[2]),
        .Gout(G[2])
    );

    cla_8 CLA3 (
        .A(A[31:24]),
        .B(B[31:24]),
        .Cin(C[2]),
        .Sum(Sum[31:24]),
        .Cout(), // don't ripple
        .Pout(P[3]),
        .Gout(G[3])
    );

    
    // C[0] (carry into second block)
    and (term[0], P[0], Cin);
    or (C[0], G[0], term[0]);

    // C[1] (carry into third block)
    and (term[1], P[1], G[0]);
    and (term[2], P[1], P[0], Cin);
    or (C[1], G[1], term[1], term[2]);

    // C[2] (carry into fourth block)
    and (term[3], P[2], G[1]);
    and (term[4], P[2], P[1], G[0]);
    and (term[5], P[2], P[1], P[0], Cin);
    or (C[2], G[2], term[3], term[4], term[5]);

    // Cout
    and (term[6], P[3], G[2]);
    and (term[7], P[3], P[2], G[1]);
    and (term[8], P[3], P[2], P[1], G[0]);
    and (term[9], P[3], P[2], P[1], P[0], Cin);
    or (Cout, G[3], term[6], term[7], term[8], term[9]);

endmodule