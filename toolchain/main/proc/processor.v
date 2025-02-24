/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	
    // ~~~~~~~~~ Program Counter ~~~~~~~~~

    // alu(.data_operandA(), .data_operandB(), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(), .isLessThan(), .overflow())
    alu PC_increment (.data_operandA(32'd1), .data_operandB(address_imem), .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(5'b00000), .data_result(PC_next_pointer), .isNotEqual(), .isLessThan(), .overflow());
    wire [31:0] PC_to_imem;
    wire [31:0] PC_next_pointer;
    // register_32 PC (.q(), .d(), .clk(), .en(), .clr());
    register_32 PC (.q(address_imem), .d(PC_next_pointer), .clk(clock), .en(1'b1), .clr(1'b0));

    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ FETCH
    // ~~~~~~~~~ Instruction (from external module) ~~~~~~~~~

    wire [4:0] opcode;
    wire [4:0] rd;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] shamt;
    wire [4:0] ALUop;

    wire [31:0] immediate;
    wire [31:0] target;

    // op is the same bits for all instructions
    
    // r type
    assign opcode = q_imem[31:27];
    assign rd = q_imem[26:22];
    assign rs = q_imem[21:17];
    assign rt = q_imem[16:12];
    assign shamt = q_imem[11:7];
    assign ALUop = q_imem[6:2];

    // i type: opcode, rd, rs are the same, the rest is immediate
    assign immediate = { {15{q_imem[16]}, q_imem[16:0]}};  // we sign extend here

    // j1 type: opcode is the same, the rest is target (unsigned, upper bits guaranteed not used)
    assign target = {5'd0, q_imem[26:0]};

    // j2 type: opcode and rd are the same, the rest unused

    

    // ~~~~~~~~~ main ALU + regfile ~~~~~~~~~
    // also make sure regfile is updated on rising edge (clock high)
    assign ctrl_writeEnable = clock;

    // on input side of regfile, lets specify s1, s2, d:
    // s1 is always rs
    assign ctrl_readRegA = rs;
    // s2 is always rt
    assign ctrl_readRegB = rt;
    // d is rt for immediate instructions (addi -> opcode 00101), but rd by default
    wire ctrl_insn_is_immediate;
    assign ctrl_insn_is_immediate = and(~opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
    mux_2 regdestmux (.in0(rd), .in1(rt), .select(ctrl_insn_is_immediate), .out(ctrl_writeReg));

    // now on output side of regfile, we have alu. 
    wire [31:0] main_alu_A;
    wire [31:0] main_alu_B;

    assign main_alu_A = data_readRegA;
    mux_2 regB_out_mux (.in0(data_readRegB), .in1(immediate), .select(ctrl_insn_is_immediate), .out(main_alu_B));

    alu main_alu(.data_operandA(main_alu_A), .data_operandB(main_alu_B), .ctrl_ALUopcode(ALUop), 
        .ctrl_shiftamt(shamt), .data_result(data_writeReg), .isNotEqual(), .isLessThan(), .overflow());

    
 
    

endmodule
