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

    // https://people.duke.edu/~tkb13/courses/ece250-2022fa/slides/08-datapath-and-control.pdf
    // https://people.duke.edu/~tkb13/courses/ece250-2022fa/slides/12-pipelining.pdf

	
    // ~~~~~~~~~ FETCH: Program Counter ~~~~~~~~~

    // alu(.data_operandA(), .data_operandB(), .ctrl_ALUopcode(), .ctrl_shiftamt(), .data_result(), .isNotEqual(), .isLessThan(), .overflow())
    wire [31:0] PC_current;
    wire [31:0] PC_next;
    alu PC_increment (.data_operandA(32'd1), .data_operandB(PC_current), .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(5'b00000), .data_result(PC_next), .isNotEqual(), .isLessThan(), .overflow());
    // register_32 PC (.q(), .d(), .clk(), .en(), .clr());
    register_32 PC (.q(PC_current), .d(PC_next), .clk(clock), .en(1'b1), .clr(reset));
    assign address_imem = PC_current;
    // assign PC_next = PC_plus_1;

    
    wire [31:0] fd_ir, fd_PC;


    
    wire [4:0] fd_opcode;
    wire [4:0] fd_rd;
    wire [4:0] fd_rs;
    wire [4:0] fd_rt;
    wire [4:0] fd_shamt;
    wire [4:0] fd_ALUop;

    wire [31:0] fd_immediate;
    wire [31:0] fd_target;
    
    // r type
    assign fd_opcode = fd_ir[31:27];
    assign fd_rd = fd_ir[26:22];
    assign fd_rs = fd_ir[21:17];
    assign fd_rt = fd_ir[16:12];
    assign fd_shamt = fd_ir[11:7];
    assign fd_ALUop = fd_ir[6:2];

    // i type: opcode, rd, rs are the same, the rest is immediate
    assign fd_immediate = {{15{fd_ir[16]}}, fd_ir[16:0]};  // we sign extend here

    // j1 type: opcode is the same, the rest is target (unsigned, upper bits guaranteed not used)
    assign fd_target = {5'd0, fd_ir[26:0]};



    register_32 FD_PC_reg (.q(fd_PC), .d(PC_current), .clk(~clock), .en(1'b1), .clr(reset));
    register_32 FD_IR_reg (.q(fd_ir), .d(q_imem), .clk(~clock), .en(1'b1), .clr(reset));

    // ~~~~~~~~~ DECODE: Instruction (from external module) ~~~~~~~~~

    wire [4:0] dx_opcode;
    wire [4:0] dx_rd;
    wire [4:0] dx_rs;
    wire [4:0] dx_rt;
    wire [4:0] dx_shamt;
    wire [4:0] dx_ALUop;

    wire [31:0] dx_immediate;
    wire [31:0] dx_target;
    
    // r type
    assign dx_opcode = dx_ir[31:27];
    assign dx_rd = dx_ir[26:22];
    assign dx_rs = dx_ir[21:17];
    assign dx_rt = dx_ir[16:12];
    assign dx_shamt = dx_ir[11:7];
    assign dx_ALUop = dx_ir[6:2];

    // i type: opcode, rd, rs are the same, the rest is immediate
    assign dx_immediate = {{15{dx_ir[16]}}, dx_ir[16:0]};  // we sign extend here

    // j1 type: opcode is the same, the rest is target (unsigned, upper bits guaranteed not used)
    assign dx_target = {5'd0, dx_ir[26:0]};

    // j2 type: opcode and rd are the same, the rest unused

    
    // ~~~~~~~~~ DECODE/EXECUTE PIPELINE REGS ~~~~~~~~~
    wire [31:0] dx_ir, dx_PC, dx_A, dx_B;
    // wire [4:0] dx_ALUop, dx_rd;
    
    // PC reg
    register_32 DX_PC (
        .q(dx_PC),
        .d(fd_PC),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );
    // Instruction reg
    register_32 DX_IR (
        .q(dx_ir),
        .d(fd_ir),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );
    // A reg
    register_32 DX_A_reg (
        .q(dx_A),
        .d(data_readRegA),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );
    // B reg
    register_32 DX_B_reg (
        .q(dx_B),
        .d(data_readRegB),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

    // ~~~~~~~~~ EXECUTE: main ALU + regfile ~~~~~~~~~
    // also make sure regfile is updated on rising edge (clock high)
    assign ctrl_writeEnable = 1'b1;//clock;

    // on input side of regfile, lets specify s1, s2, d:
    // s1 is always rs
    assign ctrl_readRegA = fd_rs;
    // s2 is always rt
    assign ctrl_readRegB = fd_rt;

    // now on output side of regfile, we have alu. 
    wire [31:0] main_alu_A;
    wire [31:0] main_alu_B;
    wire [31:0] alu_result;
    wire [4:0] dx_ALUop_final;

    assign main_alu_A = dx_A;
    wire dx_ctrl_insn_is_addimmediate;  // if immediate, take main_alu_B to be imm, otherwise default back to rt

    // d is rt for immediate instructions (addi -> dx_opcode 00101), but rd by default
    and(dx_ctrl_insn_is_addimmediate, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], ~dx_opcode[1], dx_opcode[0]); // is dx opcode 00101 (addi)?
    
    mux_2 regB_out_mux (.out(main_alu_B), .select(dx_ctrl_insn_is_addimmediate), .in0(dx_B), .in1(dx_immediate));
    // main_alu_B = dx_ctrl_insn_is_addimmediate ? dx_immediate : dx_B;

    // also mux ALUop if its an immediate (addi has no aluOP as its lower bits are all immediate.)
    // mux_2 addi_aluop_mux (.out(dx_ALUop_final), .select(dx_ctrl_insn_is_addimmediate), .in0(dx_ALUop), .in1(5'b00000));
    assign dx_ALUop_final = dx_ctrl_insn_is_addimmediate ? 5'b00000 : dx_ALUop;

    // mux_2 regdestmux (.in0(rd), .in1(rt), .select(ctrl_insn_is_immediate), .out(ctrl_writeReg));
    // assign ctrl_writeReg = dx_ctrl_insn_is_addimmediate ? dx_rt : dx_rd;


    alu main_alu(.data_operandA(main_alu_A), .data_operandB(main_alu_B), .ctrl_ALUopcode(dx_ALUop_final), 
        .ctrl_shiftamt(dx_shamt), .data_result(alu_result), .isNotEqual(), .isLessThan(), .overflow());




    
    // ~~~~~~~~~ EXECUTION/MEMORY PIPELINE REGS ~~~~~~~~~
    wire [31:0] xm_o;       // ALU output
    wire [31:0] xm_B;       // reg B value (for memory writes)
    wire [31:0] xm_ir;      // instruction
    wire [31:0] xm_d;       // mem data
    wire [4:0]  xm_rd;      // dest reg

    // ALU output register
    register_32 XM_O (
        .q(xm_o),
        .d(alu_result),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // reg B value (for memory store operations)
    register_32 XM_B (
        .q(xm_B),
        .d(dx_B),     // could be hazardous maybe
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // Instruction reg
    register_32 XM_IR (
        .q(xm_ir),
        .d(dx_ir),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    
    // ~~~~~~~~~ MEMORY/WRITEBACK PIPELINE REGS ~~~~~~~~~
    
    wire [31:0] mw_o;       // ALU result (for arithmetic ops)
    wire [31:0] mw_d;       // Data memory value (for lw/sw ops)
    wire [31:0] mw_ir;      // Instruction



    wire [4:0] mw_opcode;
    wire [4:0] mw_rd;
    wire [4:0] mw_rs;
    wire [4:0] mw_rt;
    wire [4:0] mw_shamt;
    wire [4:0] mw_ALUop;

    wire [31:0] mw_immediate;
    wire [31:0] mw_target;


    
    // r type
    assign mw_opcode = mw_ir[31:27];
    assign mw_rd = mw_ir[26:22];
    assign mw_rs = mw_ir[21:17];
    assign mw_rt = mw_ir[16:12];
    assign mw_shamt = mw_ir[11:7];
    assign mw_ALUop = mw_ir[6:2];

    // i type: opcode, rd, rs are the same, the rest is immediate
    assign mw_immediate = {{15{mw_ir[16]}}, mw_ir[16:0]};  // we sign extend here

    // j1 type: opcode is the same, the rest is target (unsigned, upper bits guaranteed not used)
    assign mw_target = {5'd0, mw_ir[26:0]};


    

    // ALU output reg
    register_32 MW_O (
        .q(mw_o),
        .d(xm_o),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // data reg
    register_32 MW_D (
        .q(mw_d),
        .d(xm_d),  // wire xm_d to data memory out
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // insn reg
    register_32 MW_IR (
        .q(mw_ir),
        .d(xm_ir),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

 
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // d is rt for immediate instructions (addi -> mw_opcode 00101), but rd by default
    wire mw_ctrl_insn_is_immediate;
    and(mw_ctrl_insn_is_immediate, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], ~mw_opcode[1], mw_opcode[0]);

    // mux_2 regdestmux (.in0(rd), .in1(rt), .select(ctrl_insn_is_immediate), .out(ctrl_writeReg));
    // assign ctrl_writeReg = mw_ctrl_insn_is_immediate ? mw_rs : mw_rd;


    // Connect MW stage outputs to register file inputs
    assign ctrl_writeEnable = 1'b1;//mw_regwrite;
    assign ctrl_writeReg = mw_rd;
    assign data_writeReg = mw_o; // or mw_d, later on when we do loadword ops

endmodule

// update file list
// cd "C:\DUKE\ECE350\ECE350-CPU\toolchain\main\proc"; Get-ChildItem -Recurse -Name -Filter *.v | Out-File -FilePath FileList.txt -Encoding Ascii; cd ../..

// python .\autotester.py
// gtkwave .\test_files\output_files\positive_no_bypass.vcd -o .\test_files\output_files\template.gtkw