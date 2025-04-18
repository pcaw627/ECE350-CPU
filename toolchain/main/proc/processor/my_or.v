module my_or(data_operandA, data_operandB, data_result);
    // Declare variables
    input [31:0] data_operandA, data_operandB;
    output [31:0] data_result;
    wire [31:0] w1;

    // Create 32 or gates for each of the 32 bits and put thw result in w1s
    or or0(w1[0], data_operandA[0], data_operandB[0]);
    or or1(w1[1], data_operandA[1], data_operandB[1]);
    or or2(w1[2], data_operandA[2], data_operandB[2]);
    or or3(w1[3], data_operandA[3], data_operandB[3]);
    or or4(w1[4], data_operandA[4], data_operandB[4]);
    or or5(w1[5], data_operandA[5], data_operandB[5]);
    or or6(w1[6], data_operandA[6], data_operandB[6]);
    or or7(w1[7], data_operandA[7], data_operandB[7]);
    or or8(w1[8], data_operandA[8], data_operandB[8]);
    or or9(w1[9], data_operandA[9], data_operandB[9]);
    or or10(w1[10], data_operandA[10], data_operandB[10]);
    or or11(w1[11], data_operandA[11], data_operandB[11]);
    or or12(w1[12], data_operandA[12], data_operandB[12]);
    or or13(w1[13], data_operandA[13], data_operandB[13]);
    or or14(w1[14], data_operandA[14], data_operandB[14]);
    or or15(w1[15], data_operandA[15], data_operandB[15]);
    or or16(w1[16], data_operandA[16], data_operandB[16]);
    or or17(w1[17], data_operandA[17], data_operandB[17]);
    or or18(w1[18], data_operandA[18], data_operandB[18]);
    or or19(w1[19], data_operandA[19], data_operandB[19]);
    or or20(w1[20], data_operandA[20], data_operandB[20]);
    or or21(w1[21], data_operandA[21], data_operandB[21]);
    or or22(w1[22], data_operandA[22], data_operandB[22]);
    or or23(w1[23], data_operandA[23], data_operandB[23]);
    or or24(w1[24], data_operandA[24], data_operandB[24]);
    or or25(w1[25], data_operandA[25], data_operandB[25]);
    or or26(w1[26], data_operandA[26], data_operandB[26]);
    or or27(w1[27], data_operandA[27], data_operandB[27]);
    or or28(w1[28], data_operandA[28], data_operandB[28]);
    or or29(w1[29], data_operandA[29], data_operandB[29]);
    or or30(w1[30], data_operandA[30], data_operandB[30]);
    or or31(w1[31], data_operandA[31], data_operandB[31]);

    // output
    assign data_result[31:0] = w1[31:0];

endmodule
