module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    // outpurs wires (opcode and mux will select which one to use)
    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] sll_result;
    wire [31:0] sra_result;

    // need to differentiate between add and sub overflows
    wire add_overflow, sub_overflow;


    // two level carry look ahead adder file
    cla_32 my_cla(.sum(add_result), .overflow(add_overflow), .a(data_operandA), .b(data_operandB), .cin(1'b0));

    // sub file (using two level carry look ahead adder and twos complement)
    my_sub sub(.data_result(sub_result), .overflow(sub_overflow), .isNotEqual(isNotEqual), .isLessThan(isLessThan), .data_operandA(data_operandA), .data_operandB(data_operandB));

    // and file
    my_and and_gate(.data_operandA(data_operandA), .data_operandB(data_operandB), .data_result(and_result));

    // or file
    my_or or_gate( .data_operandA(data_operandA), .data_operandB(data_operandB), .data_result(or_result));
 
    // sll file
    my_sll sll_0( .data_operandA(data_operandA), .data_result(sll_result), .ctrl_shiftamt(ctrl_shiftamt));

    // sra file
    my_sra sra_0(.data_operandA(data_operandA), .ctrl_shiftamt(ctrl_shiftamt), .data_result(sra_result));

    // need to assign overflow based on the first bit of opcode (add or sub)
    assign overflow = ctrl_ALUopcode[0] ? sub_overflow : add_overflow;

    // assign data result based off full opcode
    my_mux_8 alu_mux(
        .data_result(data_result),      // alu result
        .select(ctrl_ALUopcode),        // opcode
        .in0(add_result),                    // cla_32.v result
        .in1(sub_result),                    // my_subract.v result
        .in2(and_result),               // my_and.v result
        .in3(or_result),                // my_or.v result
        .in4(sll_result),                    // my_sll.v result
        .in5(sra_result),                    // my_sra.v result
        .in6(32'b0),                    // empty
        .in7(32'b0)                     //empty
    );

endmodule