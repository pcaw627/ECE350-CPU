module cla_32(sum, overflow, a, b, cin);

    input [31:0] a, b;
    input cin;
    output [31:0] sum;
    output overflow;
    wire c1, c2, c3, c4;
    wire c1_prev, c2_prev, c3_prev, c4_prev;

    cla_8 cla0(sum[7:0], c1, c1_prev, a[7:0], b[7:0], cin);
    cla_8 cla1(sum[15:8], c2, c2_prev, a[15:8], b[15:8], c1);        // use previous cout for the new cin
    cla_8 cla2(sum[23:16], c3, c3_prev, a[23:16], b[23:16], c2);
    cla_8 cla3(sum[31:24], c4, c4_prev, a[31:24], b[31:24], c3);

    xor OVF(overflow, c4, c4_prev);
endmodule
