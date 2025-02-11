module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // first let's check for zero inputs and mux for nonzero inputs.

    wire Aisnonzero;
    wire Bisnonzero;
    wire notautozero;
    wire autozero;
    or (Aisnonzero, data_operandA[0], data_operandA[1], data_operandA[2], data_operandA[3], data_operandA[4], data_operandA[5], data_operandA[6], data_operandA[7], data_operandA[8], data_operandA[9], data_operandA[10], data_operandA[11], data_operandA[12], data_operandA[13], data_operandA[14], data_operandA[15], data_operandA[16], data_operandA[17], data_operandA[18], data_operandA[19], data_operandA[20], data_operandA[21], data_operandA[22], data_operandA[23], data_operandA[24], data_operandA[25], data_operandA[26], data_operandA[27], data_operandA[28], data_operandA[29], data_operandA[30], data_operandA[31]);
    or (Bisnonzero, data_operandB[0], data_operandB[1], data_operandB[2], data_operandB[3], data_operandB[4], data_operandB[5], data_operandB[6], data_operandB[7], data_operandB[8], data_operandB[9], data_operandB[10], data_operandB[11], data_operandB[12], data_operandB[13], data_operandB[14], data_operandB[15], data_operandB[16], data_operandB[17], data_operandB[18], data_operandB[19], data_operandB[20], data_operandB[21], data_operandB[22], data_operandB[23], data_operandB[24], data_operandB[25], data_operandB[26], data_operandB[27], data_operandB[28], data_operandB[29], data_operandB[30], data_operandB[31]);
    or (autozero, Aisnonzero, Bisnonzero);
    // not (autozero, notautozero);

    // we will discard the hi part of data_result
    wire [31:0] mult_lo;
    assign mult_lo = 32'b1; // remove this once wallace is more implemented. 
    mux_2 autozero_mux(.select(autozero), .in0(mult_lo), .in1(32'b0), .out(data_result));
    assign data_resultRDY = autozero;
    assign data_exception = 1'b0;

endmodule


// iverilog -o multdiv -c multdiv_FileList.txt -s multdiv_tb -Wimplicit; // vvp multdiv +test=multbasic
// gtkwave multbasic.vcd