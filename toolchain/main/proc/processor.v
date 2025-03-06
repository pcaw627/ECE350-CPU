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

    // ~~~~~~~~~ WIRES ~~~~~~~~~~~~~~~~~~~~
    // fd
    wire [31:0] PC_current, PC_next;
    wire [4:0] fd_opcode, fd_rd, fd_rs, fd_rt, fd_shamt, fd_ALUop;
    wire [31:0] fd_ir, fd_PC, fd_immediate, fd_target;

    //dx
    wire [4:0] dx_opcode, dx_rd, dx_rs, dx_rt, dx_shamt, dx_ALUop;
    wire [31:0] dx_immediate, dx_target;

    // execute ALU
    wire [31:0] main_alu_A, main_alu_B, alu_result;
    wire [4:0] dx_ALUop_final;
    
    //xm
    wire [4:0] xm_opcode, xm_rd, xm_rs, xm_rt;
    
    //mw
    wire [4:0] mw_opcode, mw_rd, mw_rs, mw_rt, mw_shamt, mw_ALUop;
    wire [31:0] mw_immediate, mw_target;

    // Control signals for lw/sw
    wire dx_is_lw, dx_is_sw;
    wire xm_is_lw, xm_is_sw;
    wire mw_is_lw;

    // ~~~~~~~~~ FETCH: program counter ~~~~~~~~~

    // detect direct jump instruction (opcode 00001)
    wire is_jump;
    and(is_jump, ~q_imem[31], ~q_imem[30], ~q_imem[29], ~q_imem[28], q_imem[27]);

    // detect jr instruction (opcode 00100) in decode stage
    wire fd_is_jr;
    and(fd_is_jr, ~fd_opcode[4], ~fd_opcode[3], fd_opcode[2], ~fd_opcode[1], ~fd_opcode[0]);

    // for direct jump instruction, the target address is in the target field
    wire [31:0] jump_target;
    assign jump_target = {5'd0, q_imem[26:0]};

    // for jr instruction, get the jump target from RegA (fd_rd register value)
    wire [31:0] jr_target;
    assign jr_target = data_readRegA;

    // select between pc+1, direct jump target, and jr target
    wire [31:0] next_pc;
    assign next_pc = is_jump ? jump_target : (fd_is_jr ? jr_target : PC_next);

    // alu for pc+1 calculation
    alu PC_increment (.data_operandA(32'd1), .data_operandB(PC_current), .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(5'b00000), .data_result(PC_next), .isNotEqual(), .isLessThan(), .overflow());
    
    // pc register
    register_32 PC (.q(PC_current), .d(next_pc), .clk(clock), .en(1'b1), .clr(reset));
    assign address_imem = PC_current;
    
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

    // ~~~~~~~~~ DECODE: instruction ~~~~~~~~~
    
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

    // detect memory instructions and jr in fetch/decode stage
    wire fd_is_sw, fd_is_lw;
    and(fd_is_sw, ~fd_opcode[4], ~fd_opcode[3], fd_opcode[2], fd_opcode[1], fd_opcode[0]); // sw: 00111
    and(fd_is_lw, ~fd_opcode[4], fd_opcode[3], ~fd_opcode[2], ~fd_opcode[1], ~fd_opcode[0]); // lw: 01000
    
    // for jr $rd, we need to read the value from $rd to use as jump target
    // for all other instructions, we need to read rs
    assign ctrl_readRegA = fd_is_jr ? fd_rd : fd_rs;
    
    // for r-type: read rt
    // for sw: read rd (value to store)
    assign ctrl_readRegB = fd_is_sw ? fd_rd : fd_rt;

    // lw/sw control signals in DX stage
    // lw has opcode 01000
    wire dx_opcode_bit4, dx_opcode_bit3, dx_opcode_bit2, dx_opcode_bit1, dx_opcode_bit0;
    assign dx_opcode_bit4 = dx_opcode[4];
    assign dx_opcode_bit3 = dx_opcode[3];
    assign dx_opcode_bit2 = dx_opcode[2];
    assign dx_opcode_bit1 = dx_opcode[1];
    assign dx_opcode_bit0 = dx_opcode[0];
    
    // lw: 01000
    wire dx_opcode_is_lw_temp;
    and and_lw_op(dx_opcode_is_lw_temp, ~dx_opcode_bit4, dx_opcode_bit3, ~dx_opcode_bit2, ~dx_opcode_bit1, ~dx_opcode_bit0);
    assign dx_is_lw = dx_opcode_is_lw_temp;
    
    // sw: 00111
    wire dx_opcode_is_sw_temp;
    and and_sw_op(dx_opcode_is_sw_temp, ~dx_opcode_bit4, ~dx_opcode_bit3, dx_opcode_bit2, dx_opcode_bit1, dx_opcode_bit0);
    assign dx_is_sw = dx_opcode_is_sw_temp;
    
    // ~~~~~~~~~ DECODE/EXECUTE PIPELINE REGS ~~~~~~~~~
    wire [31:0] dx_ir, dx_PC, dx_A, dx_B;
    
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

    // ~~~~~~~~~ EXECUTE: main ALU + regfile ~~~~~~~~~
    
    // now on output side of regfile, we have alu.
    assign main_alu_A = dx_A;
    
    // for immediate instructions (addi, lw, sw) use immediate as operand B
    wire dx_use_immediate;
    wire dx_ctrl_insn_is_addimmediate;  // addi -> dx_opcode 00101
    
    and(dx_ctrl_insn_is_addimmediate, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], ~dx_opcode[1], dx_opcode[0]); // is dx opcode 00101 (addi)?
    
    // use immediate for addi, lw, sw
    or or_use_imm(dx_use_immediate, dx_ctrl_insn_is_addimmediate, dx_is_lw, dx_is_sw);
    
    assign main_alu_B = dx_use_immediate ? dx_immediate : dx_B;

    // also mux ALUop if its an immediate (addi, lw, sw all use add operation for address calculation)
    assign dx_ALUop_final = dx_use_immediate ? 5'b00000 : dx_ALUop;

    alu main_alu(.data_operandA(main_alu_A), .data_operandB(main_alu_B), .ctrl_ALUopcode(dx_ALUop_final), 
        .ctrl_shiftamt(dx_shamt), .data_result(alu_result), .isNotEqual(), .isLessThan(), .overflow());

    // ~~~~~~~~~ EXECUTION/MEMORY PIPELINE REGS ~~~~~~~~~
    wire [31:0] xm_o;       // ALU output
    wire [31:0] xm_B;       // reg B value (for memory writes)
    wire [31:0] xm_ir;      // instruction
    
    // Extract opcode and registers from xm instruction
    assign xm_opcode = xm_ir[31:27];
    assign xm_rd = xm_ir[26:22];
    assign xm_rs = xm_ir[21:17];
    assign xm_rt = xm_ir[16:12];
    
    // Control signals for lw/sw in XM stage
    wire xm_opcode_bit4, xm_opcode_bit3, xm_opcode_bit2, xm_opcode_bit1, xm_opcode_bit0;
    assign xm_opcode_bit4 = xm_opcode[4];
    assign xm_opcode_bit3 = xm_opcode[3];
    assign xm_opcode_bit2 = xm_opcode[2];
    assign xm_opcode_bit1 = xm_opcode[1];
    assign xm_opcode_bit0 = xm_opcode[0];
    
    // lw: 01000
    wire xm_opcode_is_lw_temp;
    and and_xm_lw_op(xm_opcode_is_lw_temp, ~xm_opcode_bit4, xm_opcode_bit3, ~xm_opcode_bit2, ~xm_opcode_bit1, ~xm_opcode_bit0);
    assign xm_is_lw = xm_opcode_is_lw_temp;
    
    // sw: 00111
    wire xm_opcode_is_sw_temp;
    and and_xm_sw_op(xm_opcode_is_sw_temp, ~xm_opcode_bit4, ~xm_opcode_bit3, xm_opcode_bit2, xm_opcode_bit1, xm_opcode_bit0);
    assign xm_is_sw = xm_opcode_is_sw_temp;

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
        .d(dx_B),     // contains register value to store for sw
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

    // ~~~~~~~~~ MEMORY STAGE ~~~~~~~~~
    
    // for lw/sw, address_dmem needs to be ALU result (rs + immediate)
    assign address_dmem = xm_o;
    
    // data to write to memory (for sw) comes from the B register (which holds rd data for sw)
    assign data = xm_B;
    
    // write enable for memory is high only for sw instruction
    assign wren = xm_is_sw;
    
    // ~~~~~~~~~ MEMORY/WRITEBACK PIPELINE REGS ~~~~~~~~~
    
    wire [31:0] mw_o;       // ALU result (for arithmetic ops)
    wire [31:0] mw_d;       // Data memory value (for lw ops)
    wire [31:0] mw_ir;      // Instruction
    
    // r type
    assign mw_opcode = mw_ir[31:27];
    assign mw_rd = mw_ir[26:22];
    assign mw_rs = mw_ir[21:17];
    assign mw_rt = mw_ir[16:12];
    assign mw_shamt = mw_ir[11:7];
    assign mw_ALUop = mw_ir[6:2];

    // i type: opcode, rd, rs are the same, the rest is immediate
    assign mw_immediate = {{15{mw_ir[16]}}, mw_ir[16:0]};  // we sign extend here

    // j1 type: opcode is the same, the rest is target
    assign mw_target = {5'd0, mw_ir[26:0]};    
    
    // control signals for lw in MW stage
    wire mw_opcode_bit4, mw_opcode_bit3, mw_opcode_bit2, mw_opcode_bit1, mw_opcode_bit0;
    assign mw_opcode_bit4 = mw_opcode[4];
    assign mw_opcode_bit3 = mw_opcode[3];
    assign mw_opcode_bit2 = mw_opcode[2];
    assign mw_opcode_bit1 = mw_opcode[1];
    assign mw_opcode_bit0 = mw_opcode[0];
    
    // lw: 01000
    wire mw_opcode_is_lw_temp;
    and and_mw_lw_op(mw_opcode_is_lw_temp, ~mw_opcode_bit4, mw_opcode_bit3, ~mw_opcode_bit2, ~mw_opcode_bit1, ~mw_opcode_bit0);
    assign mw_is_lw = mw_opcode_is_lw_temp;
    
    // jr: 00100
    wire mw_is_jr;
    and(mw_is_jr, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], ~mw_opcode[1], ~mw_opcode[0]);
    
    // sw: 00111
    wire mw_is_sw;
    and(mw_is_sw, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], mw_opcode[1], mw_opcode[0]); // sw: 00111

    // ALU output reg
    register_32 MW_O (
        .q(mw_o),
        .d(xm_o),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // data reg - holds data from memory for lw
    register_32 MW_D (
        .q(mw_d),
        .d(q_dmem),  // wire memory output to MW_D register
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

    // ~~~~~~~~~ WRITEBACK STAGE ~~~~~~~~~
    
    // for most instructions, regwrite data comes from ALU
    // for lw, it comes from memory data
    wire [31:0] regwrite_data;
    assign regwrite_data = mw_is_lw ? mw_d : mw_o;
    
    // disable register write for sw and jr instructions
    wire reg_write_enable;
    assign reg_write_enable = ~(mw_is_sw || mw_is_jr);
    assign ctrl_writeEnable = reg_write_enable;
    
    // destination register selection
    assign ctrl_writeReg = mw_rd;
    assign data_writeReg = regwrite_data;

endmodule