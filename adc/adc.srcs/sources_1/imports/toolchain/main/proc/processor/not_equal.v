module not_equal(sub_result, isNotEqual);
    input [31:0] sub_result;
    output isNotEqual;

    wire [15:0] or1;
    wire [7:0]  or2;
    wire [3:0]  or3;
    wire [1:0]  or4;


    or or0(or1[0], sub_result[0], sub_result[1]);
    or or1_(or1[1], sub_result[2], sub_result[3]);
    or or2_(or1[2], sub_result[4], sub_result[5]);
    or or3_(or1[3], sub_result[6], sub_result[7]);
    or or4_(or1[4], sub_result[8], sub_result[9]);
    or or5(or1[5], sub_result[10], sub_result[11]);
    or or6(or1[6], sub_result[12], sub_result[13]);
    or or7(or1[7], sub_result[14], sub_result[15]);
    or or8(or1[8], sub_result[16], sub_result[17]);
    or or9(or1[9], sub_result[18], sub_result[19]);
    or or10(or1[10], sub_result[20], sub_result[21]);
    or or11(or1[11], sub_result[22], sub_result[23]);
    or or12(or1[12], sub_result[24], sub_result[25]);
    or or13(or1[13], sub_result[26], sub_result[27]);
    or or14(or1[14], sub_result[28], sub_result[29]);
    or or15(or1[15], sub_result[30], sub_result[31]);

    or or16(or2[0], or1[0], or1[1]);
    or or17(or2[1], or1[2], or1[3]);
    or or18(or2[2], or1[4], or1[5]);
    or or19(or2[3], or1[6], or1[7]);
    or or20(or2[4], or1[8], or1[9]);
    or or21(or2[5], or1[10], or1[11]);
    or or22(or2[6], or1[12], or1[13]);
    or or23(or2[7], or1[14], or1[15]);

    or or24(or3[0], or2[0], or2[1]);
    or or25(or3[1], or2[2], or2[3]);
    or or26(or3[2], or2[4], or2[5]);
    or or27(or3[3], or2[6], or2[7]);

    or or28(or4[0], or3[0], or3[1]);
    or or29(or4[1], or3[2], or3[3]);

    or or30(isNotEqual, or4[0], or4[1]);



endmodule