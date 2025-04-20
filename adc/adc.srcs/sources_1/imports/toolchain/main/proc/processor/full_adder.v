module full_adder(S, Cout, A, B, Cin);
    wire w1, w2, w3;
    input A, B, Cin;
    output Cout, S;

    and A_and_B(w1, A, B);
    and A_and_C(w2, A, Cin);
    and B_and_C(w3, Cin, B);

    xor Sresult(S, A, B, Cin);
    or Cresult(Cout, w1, w2, w3);

endmodule