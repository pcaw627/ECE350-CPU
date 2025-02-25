module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    //////// KEEP INTERFACE ABOVE UNCHANGED.


    //////// OPCODE MUX
    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] sll_result;
    wire [31:0] sra_result;
    // disconnect when op is mult or div
    mux_32 opmux(.out(data_result), .select(ctrl_ALUopcode), .in0(add_result), .in1(sub_result), .in2(and_result), .in3(or_result), .in4(sll_result), .in5(sra_result), 
    .in6(32'dz), .in7(32'dz), .in8(32'd0), .in9(32'd0), .in10(32'd0), .in11(32'd0), .in12(32'd0), .in13(32'd0), .in14(32'd0), .in15(32'd0), .in16(32'd0), .in17(32'd0),
    .in18(32'd0), .in19(32'd0), .in20(32'd0), .in21(32'd0), .in22(32'd0), .in23(32'd0), .in24(32'd0), .in25(32'd0), .in26(32'd0), .in27(32'd0), .in28(32'd0),
    .in29(32'd0), .in30(32'd0), .in31(32'd0));


    ///////// OPERATIONS
    wire add_ovf;
    wire sub_ovf;
    wire [31:0] inv_B;
    wire [31:0] cla_B_in;

    not_32 subinv(.out(inv_B), .in(data_operandB));
    mux_2 submux(.select(ctrl_ALUopcode[0]), .in0(data_operandB), .in1(inv_B), .out(cla_B_in));
    // mux_2 (.)
    assign sub_result = add_result;


    // ADD
    cla_32 addsub(.A(data_operandA), .B(cla_B_in), .Cin(ctrl_ALUopcode[0]), .Sum(add_result), .Cout(), .signed_ovf(overflow)); 
    // cla_32 add_op(.A(data_operandA), .B(data_operandB), .Cin(1'b0), .Sum(add_result), .Cout(add_ovf));  
    // you may need two overflows if you have separate cla for add and sub
    // x is double driven or propogated z
    
    // SUB
    wire [31:0] NOT_operandA;
    not_32 complement(.in(data_operandA), .out(NOT_operandA));
    // cla_32 sub_op(.A(NOT_operandA), .B(data_operandB), .Cin(1'b1), .Sum(sub_result), .Cout(sub_ovf));

    // BITWISE AND
    and_32 and_op(.in1(data_operandA), .in2(data_operandB), .out(and_result));

    // BITWISE OR
    or_32 or_op(.in1(data_operandA), .in2(data_operandB), .out(or_result));

    // LOGICAL SHIFT LEFT
    sll_32 sll_op(.in(data_operandA), .shamt(ctrl_shiftamt), .out(sll_result));

    // ARITHMETIC SHIFT RIGHT
    sra_32 sra_op(.in(data_operandA), .shamt(ctrl_shiftamt), .out(sra_result));
    
    ///////// CONTROL SIGNALS OUT
    
    // isequal and greaterthan
    wire isGreaterThan;
    wire geq;
    wire lt_for_same_sign;
    wire isEqualTo;

    or (geq, isGreaterThan, isEqualTo);
    not (lt_for_same_sign, geq);

    wire same_sign;
    xnor (same_sign, data_operandA[31], data_operandB[31]);
    

    comp_mux_2 ltmux(.select(same_sign), .in0(data_operandA[31]), .in1(lt_for_same_sign), .out(isLessThan));


    not (isNotEqual, isEqualTo);
    comp_32 comparator(.EQ1(1'b1), .GT1(1'b0), .A(data_operandA), .B(data_operandB), .EQ0(isEqualTo), .GT0(isGreaterThan));

endmodule
    
    
    // iverilog -o ALU -c FileList.txt -s alu_tb -Wimplicit
    // vvp ALU +test=add