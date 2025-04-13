module cla_16 (
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] Sum,
    output Cout,
    output signed_ovf
);
    // block level vars
    wire [1:0] P, G;
    wire C; 
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
        .Cin(C),
        .Sum(Sum[15:8]),
        .Cout(Cout), // don't ripple
        .Pout(P[1]),
        .Gout(G[1]),
        .signed_ovf(signed_ovf)
    );

    
    // C[0] (carry into second block)
    and (term[0], P[0], Cin);
    or (C, G[0], term[0]);

    // C[1] (carry into third block)
    and (term[1], P[1], G[0]);
    and (term[2], P[1], P[0], Cin);
    or (Cout, G[1], term[1], term[2]);
    

endmodule