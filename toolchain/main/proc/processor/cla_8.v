module cla_8(sum, cout, cout_previous, a, b, cin);

    input cin;
    input [7:0] a, b;
    output cout, cout_previous;
    output [7:0] sum;
    wire [7:0] g, p, c;
    wire [35:0] w;

    // create the g and p values
    gen_prop gp0(g[0],p[0],a[0],b[0]);
    gen_prop gp1(g[1],p[1],a[1],b[1]);
    gen_prop gp2(g[2],p[2],a[2],b[2]);
    gen_prop gp3(g[3],p[3],a[3],b[3]);
    gen_prop gp4(g[4],p[4],a[4],b[4]);
    gen_prop gp5(g[5],p[5],a[5],b[5]);
    gen_prop gp6(g[6],p[6],a[6],b[6]);
    gen_prop gp7(g[7],p[7],a[7],b[7]);

    //c[0]
    and and0(w[0], cin, p[0]);
    or or0(c[0], w[0], g[0]);

    //c[1]
    and and1_0(w[1], cin, p[0], p[1]);
    and and1_1(w[2], g[0], p[1]);
    or or1(c[1], w[1], w[2], g[1]);

    //c[2]
    and and2_0(w[3], cin, p[0], p[1], p[2]);
    and and2_1(w[4], g[0], p[1], p[2]);
    and and2_2(w[5], g[1], p[2]);
    or or2(c[2], w[3], w[4], w[5], g[2]);

    //c[3]
    and and3_0(w[6], cin, p[0], p[1], p[2], p[3]);
    and and3_1(w[7], g[0], p[1], p[2], p[3]);
    and and3_2(w[8], g[1], p[2], p[3]);
    and and3_3(w[9], g[2], p[3]);
    or or3(c[3], w[6], w[7], w[8], w[9], g[3]);

    //c[4]
    and and4_0(w[10], cin, p[0], p[1], p[2], p[3], p[4]);
    and and4_1(w[11], g[0], p[1], p[2], p[3], p[4]);
    and and4_2(w[12], g[1], p[2], p[3], p[4]);
    and and4_3(w[13], g[2], p[3], p[4]);
    and and4_4(w[14], g[3], p[4]);
    or and4(c[4], w[10], w[11], w[12], w[13], w[14], g[4]);

    //c[5]
    and and5_0(w[15], cin, p[0], p[1], p[2], p[3], p[4], p[5]);
    and and5_1(w[16], g[0], p[1], p[2], p[3], p[4], p[5]);
    and and5_2(w[17], g[1], p[2], p[3], p[4], p[5]);
    and and5_3(w[18], g[2], p[3], p[4], p[5]);
    and and5_4(w[19], g[3], p[4], p[5]);
    and and5_5(w[20], g[4], p[5]);
    or or5(c[5], w[15], w[16], w[17], w[18], w[19], w[20], g[5]);

    //c[6]
    and and6_0(w[21], cin, p[0], p[1], p[2], p[3], p[4], p[5], p[6]);
    and and6_1(w[22], g[0], p[1], p[2], p[3], p[4], p[5], p[6]);
    and and6_2(w[23], g[1], p[2], p[3], p[4], p[5], p[6]);
    and and6_3(w[24], g[2], p[3], p[4], p[5], p[6]);
    and and6_4(w[25], g[3], p[4], p[5], p[6]);
    and and6_5(w[26], g[4], p[5], p[6]);
    and and6_6(w[27], g[5], p[6]);
    or or6(c[6], w[21], w[22], w[23], w[24], w[25], w[26], w[27], g[6]);

    //c[7]
    and and7_0(w[28], cin, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    and and7_1(w[29], g[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    and and7_2(w[30], g[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    and and7_3(w[31], g[2], p[3], p[4], p[5], p[6], p[7]);
    and and7_4(w[32], g[3], p[4], p[5], p[6], p[7]);
    and and7_5(w[33], g[4], p[5], p[6], p[7]);
    and and7_6(w[34], g[5], p[6], p[7]);
    and and7_7(w[35], g[6], p[7]);
    or or7(c[7], w[28], w[29], w[30], w[31], w[32], w[33], w[34], w[35], g[7]);


    xor xor0(sum[0],p[0],cin);          // need either a*b or c[x] value to be true can't be both (xor)
    xor xor1(sum[1],p[1],c[0]);
    xor xor2(sum[2],p[2],c[1]);
    xor xor3(sum[3],p[3],c[2]);
    xor xor4(sum[4],p[4],c[3]);
    xor xor5(sum[5],p[5],c[4]);
    xor xor6(sum[6],p[6],c[5]);
    xor xor7(sum[7],p[7],c[6]);

    assign cout_previous = c[6];         //used for overflow calc
    assign cout = c[7];                 // final Cout to be used in other blocks/overflow
endmodule