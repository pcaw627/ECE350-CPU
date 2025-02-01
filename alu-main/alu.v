module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    //////// KEEP INTERFACE ABOVE UNCHANGED.


    //////// OPCODE MUX
    wire [31:0] add_result = 32'd0;
    wire [31:0] sub_result = 32'd0;
    wire [31:0] and_result = 32'd0;
    wire [31:0] or_result = 32'd0;
    wire [31:0] sll_result = 32'd0;
    wire [31:0] sra_result = 32'd0;
    mux_32 opmux(.out(data_result), .select(ctrl_ALUopcode), .in0(add_result), .in1(sub_result), .in2(and_result), .in3(or_result), .in4(sll_result), .in5(sra_result), 
    .in6(32'd0), .in7(32'd0), .in8(32'd0), .in9(32'd0), .in10(32'd0), .in11(32'd0), .in12(32'd0), .in13(32'd0), .in14(32'd0), .in15(32'd0), .in16(32'd0), .in17(32'd0),
    .in18(32'd0), .in19(32'd0), .in20(32'd0), .in21(32'd0), .in22(32'd0), .in23(32'd0), .in24(32'd0), .in25(32'd0), .in26(32'd0), .in27(32'd0), .in28(32'd0),
    .in29(32'd0), .in30(32'd0), .in31(32'd0));


    ///////// OPERATIONS

    // ADD
    cla_32 add_op(.A(data_operandA), .B(data_operandB), .Cin(1'b0), .Sum(add_result), .Cout(overflow));
    
    // SUB
    wire [31:0] NOT_operandA;
    not_32 complement(.in(data_operandA), .out(NOT_operandA));
    cla_32 sub_op(.A(NOT_operandA), .B(data_operandB), .Cin(1'b1), .Sum(sub_result), .Cout(overflow));

    // BITWISE AND
    and_32 and_op(.in1(data_operandA), .in2(data_operandB), .out(and_result));

    // BITWISE OR
    or_32 or_op(.in1(data_operandA), .in2(data_operandB), .out(or_result));

    
    ///////// CONTROL SIGNALS OUT
    
    // not equal and c
    wire isGreaterThan;
    not (isLessThan, isGreaterThan);
    wire isEqualTo;
    not (isNotEqual, isEqualTo);
    comp_32 comparator(.EQ1(1'b1), .GT1(1'b0), .A(data_operandA), .B(data_operandB), .EQ0(isEqualTo), .GT0(isGreaterThan));

    // overflow

    


endmodule
    
    
    // iverilog -o ALU -c FileList.txt -s alu_tb -Wimplicit
    // vvp ALU +test=add