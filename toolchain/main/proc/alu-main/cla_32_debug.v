

module cla_32_debug (
    
    //////// implementation of CLA with cla on the block level, and ripple between blocks  

    input [31:0] A,
    input [31:0] B,
    input Cin,
    output [31:0] Sum,
    output Cout
);
    // internal carries between blocks
    wire c8, c16, c24;
    
    // BLOCK propagate and generate signals (maybe might not need these)
    wire [3:0] P, G;
    
    cla_8 CLA0 (
        .A(A[7:0]),
        .B(B[7:0]),
        .Cin(Cin),
        .Sum(Sum[7:0]),
        .Cout(c8),      // Connect the carry out
        .Pout(P[0]),
        .Gout(G[0])
    );

    cla_8 CLA1 (
        .A(A[15:8]),
        .B(B[15:8]),
        .Cin(c8),       // Use previous carry
        .Sum(Sum[15:8]),
        .Cout(c16),     // Connect the carry out
        .Pout(P[1]),
        .Gout(G[1])
    );

    cla_8 CLA2 (
        .A(A[23:16]),
        .B(B[23:16]),
        .Cin(c16),      // Use previous carry
        .Sum(Sum[23:16]),
        .Cout(c24),     // Connect the carry out
        .Pout(P[2]),
        .Gout(G[2])
    );

    cla_8 CLA3 (
        .A(A[31:24]),
        .B(B[31:24]),
        .Cin(c24),      // Use previous carry
        .Sum(Sum[31:24]),
        .Cout(Cout),    // then carry out on last block is cout for module
        .Pout(P[3]),
        .Gout(G[3])
    );

endmodule