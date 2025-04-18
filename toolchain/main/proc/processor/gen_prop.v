module gen_prop(g, p, a, b);

    input a, b;
    output g, p;

    and and1(g, a, b);  // Creates g term (a*b)
    xor xor1(p, a, b);  // Creates p term xor(a,b)
 
endmodule