module processor(
    // control signals
    clock,                          // i: the master clock
    reset,                          // i: a reset signal

    // imem
    address_imem,                   // o: the address of the data to get from imem
    q_imem,                         // i: the data from imem

    // dmem
    address_dmem,                   // o: the address of the data to get or put from/to dmem
    data,                           // o: the data to write to dmem
    wren,                           // o: write enable for dmem
    q_dmem,                         // i: the data from dmem

    // regfile
    ctrl_writeEnable,               // o: write enable for regfile
    ctrl_writeReg,                  // o: register to write to in regfile
    ctrl_readRegA,                  // o: register to read from port a of regfile
    ctrl_readRegB,                  // o: register to read from port b of regfile
    data_writeReg,                  // o: data to write to for regfile
    data_readRegA,                  // i: data from port a of regfile
    data_readRegB                   // i: data from port b of regfile
	 
	);

	// control signals
	input clock, reset;
	
	// imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    // ~~~~~~~~~ wires ~~~~~~~~~~~~~~~~~~~~
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

    // control signals for lw/sw
    wire dx_is_lw, dx_is_sw;
    wire xm_is_lw, xm_is_sw;
    wire mw_is_lw;

    // ~~~~~~~~~ fetch: program counter ~~~~~~~~~

    // detect different jump/branch instructions
    wire is_jump;
    and(is_jump, ~q_imem[31], ~q_imem[30], ~q_imem[29], ~q_imem[28], q_imem[27]);

    wire is_jal;
    and(is_jal, ~q_imem[31], ~q_imem[30], ~q_imem[29], q_imem[28], q_imem[27]);

    wire is_bne;
    and(is_bne, ~q_imem[31], ~q_imem[30], ~q_imem[29], q_imem[28], ~q_imem[27]);

    // detect jr instruction at fd stage
    wire fd_is_jr;
    and(fd_is_jr, ~fd_opcode[4], ~fd_opcode[3], fd_opcode[2], ~fd_opcode[1], ~fd_opcode[0]);

    // for direct jump instructions, target is in the instruction
    wire [31:0] jump_target;
    assign jump_target = {5'd0, q_imem[26:0]};

    // for jr instruction, target is in register
    wire [31:0] jr_target;
    assign jr_target = data_readRegA;

    // for branch instructions, need to check condition in execute stage
    wire [31:0] dx_branch_target;
    
    // branch comparison results
    wire alu_isNotEqual, alu_isLessThan, alu_overflow;
    
    // branch condition signals
    wire dx_is_bne, dx_is_blt;
    wire dx_take_branch;
    
    // PC control logic
    wire [31:0] next_pc;
    assign next_pc = is_jump || is_jal ? jump_target : 
                     fd_is_jr ? jr_target : 
                     dx_take_branch ? dx_branch_target : 
                     PC_next;

    // PC+1 value for normal execution
    wire [31:0] PC_plus_1;
    alu PC_increment (.data_operandA(32'd1), .data_operandB(PC_current), .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(5'b00000), .data_result(PC_plus_1), .isNotEqual(), .isLessThan(), .overflow());
    assign PC_next = PC_plus_1;
    
    // PC register
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

    // create pipeline registers for fetch/decode stage
    register_32 FD_PC_reg (.q(fd_PC), .d(PC_current), .clk(~clock), .en(1'b1), .clr(reset));
    register_32 FD_IR_reg (.q(fd_ir), .d(q_imem), .clk(~clock), .en(1'b1), .clr(reset));

    // ~~~~~~~~~ decode: instruction ~~~~~~~~~
    
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

    // detect memory instructions and branch/jump instructions in fetch/decode stage
    wire fd_is_sw, fd_is_lw, fd_is_bne, fd_is_blt;
    and(fd_is_sw, ~fd_opcode[4], ~fd_opcode[3], fd_opcode[2], fd_opcode[1], fd_opcode[0]); // sw: 00111
    and(fd_is_lw, ~fd_opcode[4], fd_opcode[3], ~fd_opcode[2], ~fd_opcode[1], ~fd_opcode[0]); // lw: 01000
    and(fd_is_bne, ~fd_opcode[4], ~fd_opcode[3], ~fd_opcode[2], fd_opcode[1], ~fd_opcode[0]); // bne: 00010
    and(fd_is_blt, ~fd_opcode[4], ~fd_opcode[3], fd_opcode[2], fd_opcode[1], ~fd_opcode[0]); // blt: 00110
    
    // combined branch signal
    wire fd_is_branch;
    or(fd_is_branch, fd_is_bne, fd_is_blt);
    
    // register reads based on instruction type
    // branches: $rs in A, $rd in B
    // jr: $rd in A (target)
    // sw: $rd in B (data to store), $rs in A (address base)
    // other instructions: $rs in A, $rt in B
    assign ctrl_readRegA = fd_is_jr ? fd_rd : fd_rs;
    assign ctrl_readRegB = fd_is_sw ? fd_rd : (fd_is_branch ? fd_rd : fd_rt);

    // ~~~~~~~~~ decode/execute pipeline regs ~~~~~~~~~
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
    
    // A reg ($rs value or $rd for jr)
    register_32 DX_A_reg (
        .q(dx_A),
        .d(data_readRegA),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );
    
    // B reg ($rt or $rd value depending on instruction)
    register_32 DX_B_reg (
        .q(dx_B),
        .d(data_readRegB),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // ~~~~~~~~~ execute: main ALU + regfile ~~~~~~~~~
    
    // Detect branch instructions in execute stage
    and(dx_is_bne, ~dx_opcode[4], ~dx_opcode[3], ~dx_opcode[2], dx_opcode[1], ~dx_opcode[0]); // bne: 00010
    and(dx_is_blt, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], dx_opcode[1], ~dx_opcode[0]); // blt: 00110
    
    // detect other instruction types in execute stage
    and(dx_is_lw, ~dx_opcode[4], dx_opcode[3], ~dx_opcode[2], ~dx_opcode[1], ~dx_opcode[0]); // lw: 01000
    and(dx_is_sw, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], dx_opcode[1], dx_opcode[0]); // sw: 00111
    
    wire dx_is_jr;
    and(dx_is_jr, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], ~dx_opcode[1], ~dx_opcode[0]); // jr: 00100
    
    // branch comparison logic
    // bne: branch if $rd != $rs (B != A)
    // blt: branch if $rd < $rs (B < A)
    wire bne_result, blt_result;
    
    // for comparison, we need an ALU or comparator 
    // if B - A == 0, then B == A
    // if B - A < 0, then B < A
    wire [31:0] branch_comp_result;
    wire branch_comp_isNotEqual, branch_comp_isLessThan, branch_comp_overflow;
    
    // branch comparison ALU
    alu branch_comp_alu(
        .data_operandA(dx_B),  // $rd
        .data_operandB(dx_A),  // $rs
        .ctrl_ALUopcode(5'b00001), // subtract B - A
        .ctrl_shiftamt(5'b00000),
        .data_result(branch_comp_result),
        .isNotEqual(branch_comp_isNotEqual),    // $rd != $rs
        .isLessThan(branch_comp_isLessThan),    // $rd < $rs
        .overflow(branch_comp_overflow)
    );
    
    // branch conditions
    assign bne_result = branch_comp_isNotEqual;
    assign blt_result = branch_comp_isLessThan;
    
    // Determine if branch should be taken
    wire bne_take, blt_take;
    and(bne_take, dx_is_bne, bne_result);
    and(blt_take, dx_is_blt, blt_result);
    or(dx_take_branch, bne_take, blt_take);
    
    // Calculate branch target: PC+1+immediate
    // PC+1 is already in dx_PC by pipeline timing
    alu branch_target_alu(
        .data_operandA(dx_PC),
        .data_operandB(dx_immediate),
        .ctrl_ALUopcode(5'b00000), // add
        .ctrl_shiftamt(5'b00000),
        .data_result(dx_branch_target),
        .isNotEqual(),
        .isLessThan(),
        .overflow()
    );
    
    // For arithmetic/memory operations
    wire dx_ctrl_insn_is_addimmediate;  // addi -> dx_opcode 00101
    and(dx_ctrl_insn_is_addimmediate, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], ~dx_opcode[1], dx_opcode[0]);
    
    // Use immediate for addi, lw, sw
    wire dx_use_immediate;
    or(dx_use_immediate, dx_ctrl_insn_is_addimmediate, dx_is_lw, dx_is_sw);
    
    // Select ALU inputs
    assign main_alu_A = dx_A;  // $rs
    assign main_alu_B = dx_use_immediate ? dx_immediate : dx_B;
    
    // Select ALUop
    assign dx_ALUop_final = dx_use_immediate ? 5'b00000 : dx_ALUop;
    
    // Main ALU for arithmetic and memory address calculation
    alu main_alu(
        .data_operandA(main_alu_A),
        .data_operandB(main_alu_B),
        .ctrl_ALUopcode(dx_ALUop_final),
        .ctrl_shiftamt(dx_shamt),
        .data_result(alu_result),
        .isNotEqual(alu_isNotEqual),
        .isLessThan(alu_isLessThan),
        .overflow(alu_overflow)
    );

    // ~~~~~~~~~ execution/memory pipeline regs ~~~~~~~~~
    wire [31:0] xm_o;       // ALU output
    wire [31:0] xm_B;       // reg B value (for memory writes)
    wire [31:0] xm_ir;      // instruction
    wire [31:0] xm_PC;      // PC value for jal
    
    // Extract opcode and registers from xm instruction
    assign xm_opcode = xm_ir[31:27];
    assign xm_rd = xm_ir[26:22];
    assign xm_rs = xm_ir[21:17];
    assign xm_rt = xm_ir[16:12];
    
    // Detect instruction types in memory stage
    and(xm_is_lw, ~xm_opcode[4], xm_opcode[3], ~xm_opcode[2], ~xm_opcode[1], ~xm_opcode[0]); // lw: 01000
    and(xm_is_sw, ~xm_opcode[4], ~xm_opcode[3], xm_opcode[2], xm_opcode[1], xm_opcode[0]); // sw: 00111
    
    // ALU output register
    register_32 XM_O (
        .q(xm_o),
        .d(alu_result),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // PC register for jal
    register_32 XM_PC (
        .q(xm_PC),
        .d(dx_PC),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // B register (for memory store operations)
    register_32 XM_B (
        .q(xm_B),
        .d(dx_B),     // contains register value to store for sw
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // Instruction register
    register_32 XM_IR (
        .q(xm_ir),
        .d(dx_ir),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // ~~~~~~~~~ memory stage ~~~~~~~~~
    
    // For lw/sw, address_dmem needs to be ALU result (rs + immediate)
    assign address_dmem = xm_o;
    
    // Data to write to memory (for sw) comes from the B register
    assign data = xm_B;
    
    // Write enable for memory is high only for sw instruction
    assign wren = xm_is_sw;
    
    // ~~~~~~~~~ memory/writeback pipeline regs ~~~~~~~~~
    
    wire [31:0] mw_o;       // ALU result (for arithmetic ops)
    wire [31:0] mw_d;       // Data memory value (for lw ops)
    wire [31:0] mw_ir;      // Instruction
    wire [31:0] mw_PC;      // PC value for jal
    
    // Extract opcode and registers from mw instruction
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
    
    // detect instruction types in writeback stage
    and(mw_is_lw, ~mw_opcode[4], mw_opcode[3], ~mw_opcode[2], ~mw_opcode[1], ~mw_opcode[0]); // lw: 01000
    
    wire mw_is_sw, mw_is_jr, mw_is_bne, mw_is_blt, mw_is_jal;
    and(mw_is_sw, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], mw_opcode[1], mw_opcode[0]); // sw: 00111
    and(mw_is_jr, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], ~mw_opcode[1], ~mw_opcode[0]); // jr: 00100
    and(mw_is_bne, ~mw_opcode[4], ~mw_opcode[3], ~mw_opcode[2], mw_opcode[1], ~mw_opcode[0]); // bne: 00010
    and(mw_is_blt, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], mw_opcode[1], ~mw_opcode[0]); // blt: 00110
    and(mw_is_jal, ~mw_opcode[4], ~mw_opcode[3], ~mw_opcode[2], mw_opcode[1], mw_opcode[0]); // jal: 00011
    
    // combined branch signal
    wire mw_is_branch;
    or(mw_is_branch, mw_is_bne, mw_is_blt);

    // ALU output register
    register_32 MW_O (
        .q(mw_o),
        .d(xm_o),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // PC register for jal return address
    register_32 MW_PC (
        .q(mw_PC),
        .d(xm_PC),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // data register - holds data from memory for lw
    register_32 MW_D (
        .q(mw_d),
        .d(q_dmem),  // wire memory output to MW_D register
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // Instruction register
    register_32 MW_IR (
        .q(mw_ir),
        .d(xm_ir),
        .clk(~clock),
        .en(1'b1),
        .clr(reset)
    );

    // ~~~~~~~~~ writeback stage ~~~~~~~~~
    
    // select data to write to register file
    // lw: memory data
    // jal: PC+1 (return address)
    // other instructions: ALU result
    wire [31:0] regwrite_data;
    assign regwrite_data = mw_is_jal ? mw_PC : (mw_is_lw ? mw_d : mw_o);
    
    // Disable register write for sw, jr, and branch instructions
    wire reg_write_enable;
    assign reg_write_enable = mw_is_jal || (~mw_is_sw && ~mw_is_jr && ~mw_is_branch);
    assign ctrl_writeEnable = reg_write_enable;
    
    // select destination register
    // jal: $r31
    // other instructions: $rd
    wire [4:0] dest_reg;
    assign dest_reg = mw_is_jal ? 5'd31 : mw_rd;
    assign ctrl_writeReg = dest_reg;
    
    assign data_writeReg = regwrite_data;

endmodule