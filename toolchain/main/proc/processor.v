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

    
    wire [31:0] fd_insn, fd_PC;
    register_32 FD_PC_reg (.q(fd_PC), .d(PC_current), .clk(~clock), .en(1'b1), .clr(reset));
    register_32 FD_insn_reg (.q(fd_insn), .d(q_imem), .clk(~clock), .en(1'b1), .clr(reset));

    // ~~~~~~~~~ DECODE: Instruction (from external module) ~~~~~~~~~

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
    assign opcode = fd_insn[31:27];
    assign rd = fd_insn[26:22];
    assign rs = fd_insn[21:17];
    assign rt = fd_insn[16:12];
    assign shamt = fd_insn[11:7];
    assign ALUop = fd_insn[6:2];

    // i type: opcode, rd, rs are the same, the rest is immediate
    assign immediate = {{15{fd_insn[16]}}, fd_insn[16:0]};  // we sign extend here

    // j1 type: opcode is the same, the rest is target (unsigned, upper bits guaranteed not used)
    assign target = {5'd0, fd_insn[26:0]};

    // j2 type: opcode and rd are the same, the rest unused

    
    // ~~~~~~~~~ FETCH/DECODE PIPELINE REGS ~~~~~~~~~
    wire [31:0] dx_insn, dx_PC, dx_A, dx_B;
    wire [4:0] dx_ALUop, dx_rd;
    register_32 DX_PC_reg (.q(dx_PC), .d(fd_PC), .clk(~clock), .en(1'b1), .clr(reset));
    register_32 DX_insn_reg (.q(dx_insn), .d(fd_insn), .clk(~clock), .en(1'b1), .clr(reset));
    register_32 DX_A_reg (.q(dx_A), .d(data_readRegA), .clk(~clock), .en(1'b1), .clr(reset));
    register_32 DX_B_reg (.q(dx_B), .d(data_readRegB), .clk(~clock), .en(1'b1), .clr(reset));

    register_5  DX_ctrl_Rdst_reg (.q(dx_rd), .d(rd), .clk(~clock), .en(1'b1), .clr(reset));
    register_5  DX_ctrl_ALUop_reg (.q(dx_ALUop), .d(ALUop), .clk(~clock), .en(1'b1), .clr(reset));
    
    dffe_ref    DX_ctrl_RWE_reg (.q(), .d(), .clk(~clock), .en(1'b1), .clr(reset));
    dffe_ref    DX_ctrl_Rwd_reg (.q(), .d(), .clk(~clock), .en(1'b1), .clr(reset));
    dffe_ref    DX_ctrl_ALUinB_reg (.q(), .d(), .clk(~clock), .en(1'b1), .clr(reset));
    dffe_ref    DX_ctrl_DMwe_reg (.q(), .d(), .clk(~clock), .en(1'b1), .clr(reset));
    dffe_ref    DX_ctrl_JP_reg (.q(), .d(), .clk(~clock), .en(1'b1), .clr(reset));
    dffe_ref    DX_ctrl_BR_reg (.q(), .d(), .clk(~clock), .en(1'b1), .clr(reset));


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

    // ~~~~~~~~~ EXECUTE: main ALU + regfile ~~~~~~~~~
    // also make sure regfile is updated on rising edge (clock high)
    assign ctrl_writeEnable = 1'b1;//clock;

    // on input side of regfile, lets specify s1, s2, d:
    // s1 is always rs
    assign ctrl_readRegA = rs;
    // s2 is always rt
    assign ctrl_readRegB = rt;
    // d is rt for immediate instructions (addi -> opcode 00101), but rd by default
    wire ctrl_insn_is_immediate;
    and(ctrl_insn_is_immediate, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);

    // mux_2 regdestmux (.in0(rd), .in1(rt), .select(ctrl_insn_is_immediate), .out(ctrl_writeReg));
    assign ctrl_writeReg = ctrl_insn_is_immediate ? rt : rd;

    // now on output side of regfile, we have alu. 
    wire [31:0] main_alu_A;
    wire [31:0] main_alu_B;
    wire [31:0] alu_result;

    assign main_alu_A = dx_A;
    mux_2 regB_out_mux (.out(main_alu_B), .select(ctrl_insn_is_immediate), .in0(dx_B), .in1(immediate));

    alu main_alu(.data_operandA(main_alu_A), .data_operandB(main_alu_B), .ctrl_ALUopcode(ALUop), 
        .ctrl_shiftamt(shamt), .data_result(alu_result), .isNotEqual(), .isLessThan(), .overflow());




    
    // ~~~~~~~~~ EXECUTION/MEMORY PIPELINE REGS ~~~~~~~~~
    wire [31:0] xm_o;       // ALU output
    wire [31:0] xm_B;       // reg B value (for memory writes)
    wire [31:0] xm_ir;      // instruction
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
        .d(dx_insn),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // Dest reg
    register_5 XM_RD (
        .q(xm_rd),
        .d(dx_rd),    // could be different based on instruction type, will need hazard muxes here probably
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    
    // ~~~~~~~~~ MEMORY/WRITEBACK PIPELINE REGS ~~~~~~~~~

    wire [31:0] mw_o;       // ALU result (for arithmetic ops)
    wire [31:0] mw_d;       // Data memory value (for lw/sw ops)
    wire [31:0] mw_ir;      // Instruction
    wire [4:0]  mw_rd;      // Destination register

    // ALU output reg
    register_32 MW_O (
        .q(mw_o),
        .d(xm_o),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // data memory value reg
    register_32 MW_D (
        .q(mw_d),
        .d(q_dmem),
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

    // dest reg
    register_5 MW_RD (
        .q(mw_rd),
        .d(xm_rd),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );
 
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // Connect MW stage outputs to register file inputs
    assign ctrl_writeEnable = 1'b1;//mw_regwrite;
    assign ctrl_writeReg = mw_rd;
    assign data_writeReg = mw_o; // or mw_d, later on when we do loadword ops

endmodule

// update file list
// cd "C:\DUKE\ECE350\ECE350-CPU\toolchain\main\proc"; Get-ChildItem -Recurse -Name -Filter *.v | Out-File -FilePath FileList.txt -Encoding Ascii; cd ../..

// python .\autotester.py
// gtkwave .\test_files\output_files\positive_no_bypass.vcd -o .\test_files\output_files\template.gtkw