//assign ternary_output = cond ? High : Low;
//      Thw ternary operator is a simple construction that passes on the “High” wire 
//      if the cond wire is asserted and “Low” wire if the cond wire is not asserted

module my_sll(data_operandA, ctrl_shiftamt, data_result);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;
    output [31:0] data_result;

    wire [31:0] w1, w2, w3, w4, w5;

    // Shift by 1 bit if ctrl_shiftamt[0] = 1
    assign w1 = ctrl_shiftamt[0] ? {data_operandA[30:0], 1'b0} : data_operandA;

    // Shift by 2 bits if ctrl_shiftamt[1] = 1
    assign w2 = ctrl_shiftamt[1] ? {w1[29:0], 2'b00} : w1;

    // Shift by 4 bits if ctrl_shiftamt[2] = 1
    assign w3 = ctrl_shiftamt[2] ? {w2[27:0], 4'b0000} : w2;

    // Shift by 8 bits if ctrl_shiftamt[3] = 1
    assign w4 = ctrl_shiftamt[3] ? {w3[23:0], 8'b00000000} : w3;

    // Shift by 16 bits if ctrl_shiftamt[4] = 1
    assign data_result = ctrl_shiftamt[4] ? {w4[15:0], 16'b0000000000000000} : w4;

endmodule