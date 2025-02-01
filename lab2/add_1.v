
module add_1(S, Cout, A, B, Cin);
    input A, B, Cin;
    output S, Cout;
    wire w1, w2, w3, w4, w5, w6, w7, w8, w9;

    nand A_nand_B(w1, A, B);
    nand w1_nand_A(w2, w1, A);
    nand w1_nand_B(w3, w1, B);
    nand A_xor_B(w4, w2, w3);

    nand AxorB_nand_Cin(w5, w4, Cin);
    nand w5_nand_AxorB(w6, w5, w4);
    nand w5_nand_Cin(w7, w5, Cin);
    nand AxorB_xor_Cin(S, w6, w7);
    nand w_Cout(Cout, w1, w5);

endmodule


// iverilog -o add_1 -s add_1_tb .\add_1.v .\add_1_tb.v
// vvp .\add_1