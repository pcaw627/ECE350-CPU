//assign ternary_output = cond ? High : Low;
//      Thw ternary operator is a simple construction that passes on the “High” wire 
//      if the cond wire is asserted and “Low” wire if the cond wire is not asserted

// Need the sign bit to 'multiply' itself over as it shifts (while keeping the MSB as the sign bit)

module my_sra(data_operandA, ctrl_shiftamt, data_result);
    input [31:0] data_operandA;
    input [4:0] ctrl_shiftamt;
    output [31:0] data_result;

    wire [31:0] w1, w2, w3, w4, w5;
    wire sign = data_operandA[31];

    // Shift by 1 bit if ctrl_shiftamt[0] = 1
    assign w1 = ctrl_shiftamt[0] ? {sign, data_operandA[31:1]} : data_operandA;
    
    // Shift by 2 bits if ctrl_shiftamt[1] = 1
    assign w2 = ctrl_shiftamt[1] ? {{sign,sign}, w1[31:2]} : w1;
    
    // Shift by 4 bits if ctrl_shiftamt[2] = 1
    assign w3 = ctrl_shiftamt[2] ? {{sign,sign,sign,sign}, w2[31:4]} : w2;
    
    // Shift by 8 bits if ctrl_shiftamt[3] = 1
    assign w4 = ctrl_shiftamt[3] ? {{sign,sign,sign,sign,sign,sign,sign,sign}, w3[31:8]} : w3;
    
    // Shift by 16 bits if ctrl_shiftamt[4] = 1
    assign data_result = ctrl_shiftamt[4] ? {{sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign,sign}, w4[31:16]} : w4;

endmodule