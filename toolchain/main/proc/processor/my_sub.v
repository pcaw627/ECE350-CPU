module my_sub(data_result, overflow, isNotEqual, isLessThan, data_operandA, data_operandB);
    input [31:0] data_operandA, data_operandB;
    output [31:0] data_result;
    output overflow, isNotEqual, isLessThan;
    
    wire [31:0] twos_complement_B;
    wire A_sign, B_sign, sub_sign, not_A_sign, not_B_sign, not_sub_sign;
    wire w1, w2, w3, w4;
    
    // use not gates to get opposite of B
    not B0(twos_complement_B[0], data_operandB[0]);
    not B1(twos_complement_B[1], data_operandB[1]);
    not B2(twos_complement_B[2], data_operandB[2]);
    not B3(twos_complement_B[3], data_operandB[3]);
    not B4(twos_complement_B[4], data_operandB[4]);
    not B5(twos_complement_B[5], data_operandB[5]);
    not B6(twos_complement_B[6], data_operandB[6]);
    not B7(twos_complement_B[7], data_operandB[7]);
    not B8(twos_complement_B[8], data_operandB[8]);
    not B9(twos_complement_B[9], data_operandB[9]);
    not B10(twos_complement_B[10], data_operandB[10]);
    not B11(twos_complement_B[11], data_operandB[11]);
    not B12(twos_complement_B[12], data_operandB[12]);
    not B13(twos_complement_B[13], data_operandB[13]);
    not B14(twos_complement_B[14], data_operandB[14]);
    not B15(twos_complement_B[15], data_operandB[15]);
    not B16(twos_complement_B[16], data_operandB[16]);
    not B17(twos_complement_B[17], data_operandB[17]);
    not B18(twos_complement_B[18], data_operandB[18]);
    not B19(twos_complement_B[19], data_operandB[19]);
    not B20(twos_complement_B[20], data_operandB[20]);
    not B21(twos_complement_B[21], data_operandB[21]);
    not B22(twos_complement_B[22], data_operandB[22]);
    not B23(twos_complement_B[23], data_operandB[23]);
    not B24(twos_complement_B[24], data_operandB[24]);
    not B25(twos_complement_B[25], data_operandB[25]);
    not B26(twos_complement_B[26], data_operandB[26]);
    not B27(twos_complement_B[27], data_operandB[27]);
    not B28(twos_complement_B[28], data_operandB[28]);
    not B29(twos_complement_B[29], data_operandB[29]);
    not B30(twos_complement_B[30], data_operandB[30]);
    not B31(twos_complement_B[31], data_operandB[31]);

    // use cin = 1 to add the extra 1 needed for twos complement of B while also adding A and B together so its basically (A + (-B + 1))
    cla_32 adder(.sum(data_result), .overflow(overflow), .a(data_operandA), .b(twos_complement_B), .cin(1'b1));

    // use not_equal.v to find equality based off the sub answer
    not_equal ne(data_result, isNotEqual);

    // determine less than based off of sign bit
    assign A_sign = data_operandA[31];    // determine sign of A
    assign B_sign = data_operandB[31];    // determine sign of B
    assign sub_sign = data_result[31];    // determine sub_result sign

    not not_A_sign_gate(not_A_sign, A_sign);
    not not_B_sign_gate(not_B_sign, B_sign);
    not not_sub_sign_gate(not_sub_sign, sub_sign);

    and and_lt_gate1(w1, A_sign, not_B_sign);  // A is negative,  B is positive
    and and_lt_gate2(w2, sub_sign, A_sign, B_sign);  // A and sub result is negative
    and and_lt_gate3(w3, not_A_sign, not_B_sign, sub_sign); // A, B, and sub result are negative 

    // Declare OR gate for the final result
    or or_lt_gate1(isLessThan, w1, w2, w3);  // Combine the conditions

endmodule
