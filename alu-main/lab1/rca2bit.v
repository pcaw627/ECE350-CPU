module rca2bit(S, Cout, A, B, Cin);
    input [1:0] A, B;
    input Cin;
    output [1:0] S;
    output Cout;
    wire C0, w2, w3;

    // syntax: gate instance_name(output, input_1, input_2...)
    full_adder S0result(.in1(A[0]), .in2(B[0]), .in3(Cin), .out1(S[0]), .out2(C0));
    full_adder S1result(.in1(A[1]), .in2(B[1]), .in3(C0), .out1(S[1]), .out2(Cout));


endmodule

// iverilog -o rca2bit -s rca2bit_tb .\rca2bit.v .\full_adder.v .\rca2bit_tb.v
// 
// vvp .\rca2bit