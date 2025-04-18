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
    // PC and control wires
    wire [31:0] PC_current, PC_next, PC_plus_1;
    wire stall, control_flow_taken, control_branch_or_jump, control_branch_taken, jr_flush;
    
    // FD stage
    wire [31:0] fd_ir, fd_PC, fd_immediate, fd_target, jal_fd_addr, jal_ret_addr;
    wire [4:0] fd_opcode, fd_rd, fd_rs, fd_rt, fd_shamt, fd_ALUop;
    wire fd_is_sw, fd_is_lw, fd_is_bne, fd_is_blt, fd_is_branch, fd_is_jr, fd_is_bex, fd_is_setx, jal_fd_active;
    wire fd_rs_not_zero, fd_rd_not_zero, fd_rt_not_zero;
    
    // DX stage
    wire [31:0] dx_ir, dx_PC, dx_A, dx_B, dx_immediate, dx_target, dx_link;
    wire [4:0] dx_opcode, dx_rd, dx_rs, dx_rt, dx_shamt, dx_ALUop, dx_ALUop_final;
    wire dx_is_lw, dx_is_sw, dx_is_bne, dx_is_blt, dx_is_jr, dx_is_setx;
    wire dx_is_rtype, dx_is_addi, dx_is_memory_read, dx_is_addimmediate, dx_use_immediate;
    wire dx_is_ADD, dx_is_SUB, dx_writes_reg, dx_take_branch, jal_ex_active, dx_exception_code_flag;
    wire [31:0] jal_ex_addr, dx_branch_target, dx_exception_code;
    
    // XM stage
    wire [31:0] xm_ir, xm_o, xm_B, xm_PC, xm_link, jal_mem_addr, xm_exception_code, xm_immediate;
    wire [4:0] xm_opcode, xm_rd, xm_rs, xm_rt;
    wire xm_is_lw, xm_is_sw, xm_is_jr, xm_is_rtype, xm_is_addi, xm_writes_reg, jal_mem_active, xm_exception_code_flag;
    
    // MW stage
    wire [31:0] mw_ir, mw_o, mw_d, mw_PC, mw_immediate, mw_target, mw_link, jal_wb_addr, mw_exception_code;
    wire [4:0] mw_opcode, mw_rd, mw_rs, mw_rt, mw_shamt, mw_ALUop;
    wire mw_is_lw, mw_is_sw, mw_is_jr, mw_is_bne, mw_is_blt, mw_is_jal, mw_is_setx, mw_is_branch, jal_wb_active, mw_exception_code_flag;
    
    // ALU wires
    wire [31:0] main_alu_A, main_alu_B, alu_result, branch_comp_result, branch_target, branch_N;
    wire alu_isNotEqual, alu_isLessThan, alu_overflow;
    wire branch_comp_isNotEqual, branch_comp_isLessThan, branch_comp_overflow, bne_result, blt_result, bne_take, blt_take;
    
    // bypass wires
    wire [31:0] bypassA_value, bypassB_value;
    wire bypassX_to_A, bypassX_to_B, bypassM_to_A, bypassM_to_B;
    wire regA_match_dx, regB_match_dx, regA_match_xm, regB_match_xm;
    wire bypassX_exception, bypassX_exception_B, bypassM_exception, bypassM_exception_B;
    wire bypassException_to_A, bypassException_to_B;
    wire [31:0] exception_bypass_value;
    
    // JR bypass wires
    wire jr_needs_bypass, jr_bypass_from_X, jr_bypass_from_M, jr_bypass_from_W;
    wire [31:0] jr_bypassed_target;
    
    // SW bypass wires
    wire sw_needs_bypass_B, sw_bypass_from_X, sw_bypass_from_M;
    wire [31:0] sw_bypassed_data;
    
    // Jump/Branch wires
    wire is_jump, is_jal, is_bne, is_bex, bex_condition, bex_taken;
    wire [31:0] jump_target, jr_target, bex_target, next_pc;
    
    // MULTDIV wires
    wire ctrl_MULT, ctrl_DIV, multdiv_exception, multdiv_resultRDY, multdiv_start_valid, multdiv_counter_clear;
    wire md_counter_is_zero, multdiv_done, dx_is_MULT, dx_is_DIV, dx_is_MULTDIV;
    wire [31:0] multdiv_result, multdiv_bypass_value;
    wire [5:0] multdiv_counter;
    
    // Misc wires
    wire [31:0] regwrite_data, jal_val, setx_value, rstatus_value;
    wire normal_write_enable, reg_write_enable;
    wire [4:0] normal_dest_reg;


    wire sw_bypass_from_M_using_dmem, lw_in_mem_stage;
    wire [31:0] lw_dmem_data;

    // Replace or add these lines to fix the SW bypass logic

    // Detect when we have a LW in memory stage
    and(lw_in_mem_stage, xm_is_lw, 1'b1);

    // Check if LW's destination in memory stage matches SW's source in decode stage
    // and we need to bypass memory data to SW
    and(sw_bypass_from_M_using_dmem, fd_is_sw, (fd_rd == xm_rd), lw_in_mem_stage, fd_rd_not_zero);

    // Use memory data (q_dmem) when we have a LW->SW bypass
    assign sw_bypassed_data = sw_bypass_from_X ? alu_result : 
                            sw_bypass_from_M_using_dmem ? q_dmem :
                            sw_bypass_from_M ? xm_o : 
                            data_readRegB; // default to original regfile output


    
    // after this, the rd of the sw insn can then be accessible from the regfile, to be used as rs for the addi insn.
    // then run a WX bypass on em

    // if add_sw_stall, mux in nop to XM.
    wire wx_stall = ((dx_is_lw) && ((fd_rs == dx_rd) || ((fd_rt == dx_rd) && (fd_is_sw)) 
        || (fd_is_blt || dx_is_MULTDIV))) || (dx_is_sw && ((fd_rs == dx_rd) || ((fd_rt == dx_rd) && (fd_is_lw))));
    wire wx_stall_delayed1, wx_stall_delayed2;
    dffe_ref wx_stall_dff1 (.q(wx_stall_delayed1), .d(wx_stall), .en(1'b1), .clr(1'b0), .clk(~clock));
    dffe_ref wx_stall_dff2 (.q(wx_stall_delayed2), .d(wx_stall_delayed1), .en(1'b1), .clr(1'b0), .clk(~clock));









    
    // ~~~~~~~~~ fetch: program counter ~~~~~~~~~

    // detect different jump/branch instructions
    and(is_jump, ~q_imem[31], ~q_imem[30], ~q_imem[29], ~q_imem[28], q_imem[27]);
    and(is_jal, ~q_imem[31], ~q_imem[30], ~q_imem[29], q_imem[28], q_imem[27]);
    and(is_bne, ~q_imem[31], ~q_imem[30], ~q_imem[29], q_imem[28], ~q_imem[27]);
    and(fd_is_jr, ~fd_opcode[4], ~fd_opcode[3], fd_opcode[2], ~fd_opcode[1], ~fd_opcode[0]);  // detect jr instruction at fd stage
    and(mw_is_jr, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], ~mw_opcode[1], ~mw_opcode[0]);
    and(xm_is_jr, ~xm_opcode[4], ~xm_opcode[3], xm_opcode[2], ~xm_opcode[1], ~xm_opcode[0]);

    // Add detection for exceptions
    assign dx_exception_code_flag = (dx_exception_code == 32'b0) ? 1'b0 : 1'b1;
    assign xm_exception_code_flag = (xm_exception_code == 32'b0) ? 1'b0 : 1'b1;

    // Check if exception in X stage could affect rs of current instruction
    and(bypassX_exception, dx_exception_code_flag, (fd_rs == 5'd30), fd_rs_not_zero);
    // Check if exception in M stage could affect rs of current instruction
    and(bypassM_exception, xm_exception_code_flag, (fd_rs == 5'd30), fd_rs_not_zero);
    // Combined signal for exception bypass to A
    or(bypassException_to_A, bypassX_exception, bypassM_exception);

    // Check if exception in X stage could affect rt of current instruction
    and(bypassX_exception_B, dx_exception_code_flag, (fd_rt == 5'd30), fd_rt_not_zero);
    // Check if exception in M stage could affect rt of current instruction
    and(bypassM_exception_B, xm_exception_code_flag, (fd_rt == 5'd30), fd_rt_not_zero);
    // Combined signal for exception bypass to B
    or(bypassException_to_B, bypassX_exception_B, bypassM_exception_B);

    // Determine the exception code value to bypass
    assign exception_bypass_value = bypassX_exception || bypassX_exception_B ? dx_exception_code : 
                                (bypassM_exception || bypassM_exception_B) ? xm_exception_code : 32'd0;

    // Check if JR's target register (fd_rd) matches a destination in pipeline
    assign jr_bypass_from_X = fd_is_jr && (fd_rd == dx_rd) && dx_writes_reg && fd_rd_not_zero;
    assign jr_bypass_from_M = fd_is_jr && (fd_rd == xm_rd) && xm_writes_reg && fd_rd_not_zero;
    assign jr_bypass_from_W = fd_is_jr && (fd_rd == mw_rd) && reg_write_enable && fd_rd_not_zero;
    or(jr_needs_bypass, jr_bypass_from_X, jr_bypass_from_M, jr_bypass_from_W);

    // Select bypassed data based on matching stage
    assign jr_bypassed_target = jr_bypass_from_X ? alu_result : 
                            jr_bypass_from_M ? xm_o : 
                            jr_bypass_from_W ? regwrite_data :
                            data_readRegA; // Default to register file value

    assign jump_target = {5'd0, q_imem[26:0]}; // for direct jump instructions, target is in the instruction
    assign jr_target = jr_bypassed_target;

    // PC control logic
    assign next_pc = is_jump || is_jal ? jump_target : 
                    fd_is_jr ? jr_target : 
                    bex_taken ? bex_target :
                    dx_take_branch ? dx_branch_target : 
                    PC_next;

    alu PC_increment (.data_operandA(32'd1), .data_operandB(PC_current), .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(5'b00000), .data_result(PC_plus_1), .isNotEqual(), .isLessThan(), .overflow());
    assign PC_next = PC_plus_1;
    
    register_32 PC (.q(PC_current), .d(next_pc), .clk(~clock), .en(~stall && ~wx_stall), .clr(reset)); // PC register
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

    register_32 FD_PC_reg (.q(fd_PC), .d(control_branch_or_jump ? 32'd0 : PC_current), .clk(~clock), .en(~stall && ~wx_stall), .clr(reset));
    register_32 FD_IR_reg (.q(fd_ir), .d(control_branch_or_jump ? 32'd0 : q_imem), .clk(~clock), .en(~stall && ~wx_stall), .clr(reset));

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
    and(fd_is_sw, ~fd_opcode[4], ~fd_opcode[3], fd_opcode[2], fd_opcode[1], fd_opcode[0]); // sw: 00111
    and(fd_is_lw, ~fd_opcode[4], fd_opcode[3], ~fd_opcode[2], ~fd_opcode[1], ~fd_opcode[0]); // lw: 01000
    and(fd_is_bne, ~fd_opcode[4], ~fd_opcode[3], ~fd_opcode[2], fd_opcode[1], ~fd_opcode[0]); // bne: 00010
    and(fd_is_blt, ~fd_opcode[4], ~fd_opcode[3], fd_opcode[2], fd_opcode[1], ~fd_opcode[0]); // blt: 00110
    
    // combined branch signal
    or(fd_is_branch, fd_is_bne, fd_is_blt);

    dffe_ref jal_fd (.q(jal_fd_active), .d(is_jal), .clk(~clock), .en(~stall && ~wx_stall), .clr(reset));

    register_32 jal_fd_reg (.q(jal_fd_addr), .d(is_jal ? jal_ret_addr : 32'd0), 
                            .clk(~clock), .en(~stall && ~wx_stall), .clr(reset));

    
    // register reads based on instruction type
    // branches: $rs in A, $rd in B
    // jr: $rd in A (target)
    // sw: $rd in B (data to store), $rs in A (address base)
    // other instructions: $rs in A, $rt in B
    assign ctrl_readRegA = fd_is_bex ? 5'd30 : (fd_is_jr ? fd_rd : fd_rs);
    assign ctrl_readRegB = fd_is_sw ? fd_rd : (fd_is_branch ? fd_rd : fd_rt);

    // ~~~~~~~~~~~~~~~~~~~~ BEX - SETX ~~~~~~~~~~~~~~~~~~~~~~
    and(is_bex, q_imem[31], ~q_imem[30], q_imem[29], q_imem[28], ~q_imem[27]); // 10110
    and(fd_is_bex, fd_opcode[4], ~fd_opcode[3], fd_opcode[2], fd_opcode[1], ~fd_opcode[0]); // 10110
    and(fd_is_setx, fd_opcode[4], ~fd_opcode[3], fd_opcode[2], ~fd_opcode[1], fd_opcode[0]); // 10101

    // bex branch logic
    assign bex_condition = (data_readRegA != 32'd0); // for bex: if $rstatus != 0
    and(bex_taken, fd_is_bex, bex_condition);

    // (similar to j target)
    assign bex_target = {5'd0, fd_ir[26:0]};

    // ~~~~~~~~~ decode/execute pipeline regs ~~~~~~~~~
    
    // (reg A and B are modified to use bypass, all changes to bypass should be done through these vars)
    register_32 DX_PC (.q(dx_PC), .d(fd_PC), .clk(~clock), .en(~stall), .clr(reset)); // PC reg
    register_32 DX_IR (.q(dx_ir), .d(wx_stall ? 32'd0 : control_branch_or_jump ? 32'd0 : fd_ir), .clk(~clock), .en(~stall), .clr(reset)); // Instruction reg
    // A reg ($rs value or $rd for jr)
    register_32 DX_A_reg (.q(dx_A), .d(control_branch_or_jump ? 32'd0 : bypassA_value), .clk(~clock), .en(~stall), .clr(reset));
    // B reg ($rt or $rd value depending on instruction)
    register_32 DX_B_reg (.q(dx_B), .d(control_branch_or_jump ? 32'd0 : bypassB_value), .clk(~clock), .en(~stall), .clr(reset));
    // link reg (for flush-proof jal)
    register_32 DX_link (.q(dx_link), .d(control_branch_or_jump ? 32'd0 : fd_PC), .clk(~clock), .en(~stall), .clr(reset));

    // ~~~~~~~~~ execute: main ALU + regfile ~~~~~~~~~

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BYPASS BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // Detect when we need to bypass from X->D
    // check if insn in X stage will write to register file
    and(dx_is_rtype, ~dx_opcode[4], ~dx_opcode[3], ~dx_opcode[2], ~dx_opcode[1], ~dx_opcode[0]);
    and(dx_is_addi, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], ~dx_opcode[1], dx_opcode[0]);
    and(dx_is_memory_read, ~dx_opcode[4], dx_opcode[3], ~dx_opcode[2], ~dx_opcode[1], ~dx_opcode[0]); // lw
    or(dx_writes_reg, dx_is_rtype, dx_is_addi, dx_is_memory_read);

    // bypass from X stage to A if dest of insn in execute matches rs of insn in D
    // AND if the insn in X stage writes to a register AND rs isn't r0
    or(fd_rs_not_zero, fd_rs[4], fd_rs[3], fd_rs[2], fd_rs[1], fd_rs[0]);
    or(fd_rd_not_zero, fd_rd[4], fd_rd[3], fd_rd[2], fd_rd[1], fd_rd[0]);
    or(fd_rt_not_zero, fd_rt[4], fd_rt[3], fd_rt[2], fd_rt[1], fd_rt[0]);

    assign regA_match_dx = (fd_rs == dx_rd) && fd_rs_not_zero;
    assign regB_match_dx = (fd_rt == dx_rd) && fd_rt_not_zero;

    and(bypassX_to_A, dx_writes_reg, regA_match_dx);
    and(bypassX_to_B, dx_writes_reg, regB_match_dx);

    // detect when we need to bypass from M->D
    // check if insn in M will write to register file
    and(xm_is_rtype, ~xm_opcode[4], ~xm_opcode[3], ~xm_opcode[2], ~xm_opcode[1], ~xm_opcode[0]);
    and(xm_is_addi, ~xm_opcode[4], ~xm_opcode[3], xm_opcode[2], ~xm_opcode[1], xm_opcode[0]);
    or(xm_writes_reg, xm_is_rtype, xm_is_addi, xm_is_lw);

    assign regA_match_xm = (fd_rs == xm_rd) && fd_rs_not_zero;
    assign regB_match_xm = (fd_rt == xm_rd) && fd_rt_not_zero;
    and(bypassM_to_A, xm_writes_reg, regA_match_xm);
    and(bypassM_to_B, xm_writes_reg, regB_match_xm);

    // ========== BYPASS DATA SELECTION ==========
    assign bypassA_value = bypassException_to_A ? exception_bypass_value :
                      bypassX_to_A ? (dx_is_MULTDIV && multdiv_resultRDY ? multdiv_result : alu_result) : 
                      bypassM_to_A ? xm_o : 
                      data_readRegA;
                      
    assign bypassB_value = bypassException_to_B ? exception_bypass_value :
                      fd_is_sw ? sw_bypassed_data :
                      bypassX_to_B ? (dx_is_MULTDIV && multdiv_resultRDY ? multdiv_result : alu_result) : 
                      bypassM_to_B ? xm_o : 
                      data_readRegB;
                      
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BYPASS END ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // Detect branch instructions in execute stage
    and(dx_is_bne, ~dx_opcode[4], ~dx_opcode[3], ~dx_opcode[2], dx_opcode[1], ~dx_opcode[0]); // bne: 00010
    and(dx_is_blt, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], dx_opcode[1], ~dx_opcode[0]); // blt: 00110
    
    // detect other instruction types in execute stage
    and(dx_is_lw, ~dx_opcode[4], dx_opcode[3], ~dx_opcode[2], ~dx_opcode[1], ~dx_opcode[0]); // lw: 01000
    and(dx_is_sw, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], dx_opcode[1], dx_opcode[0]); // sw: 00111
    
    and(dx_is_jr, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], ~dx_opcode[1], ~dx_opcode[0]); // jr: 00100
    
    // branch comparison logic
    // bne: branch if $rd != $rs (B != A)
    // blt: branch if $rd < $rs (B < A)
    
    // for comparison, we need an ALU or comparator. if B - A == 0, then B == A. if B - A < 0, then B < A
    alu branch_comp_alu(  // branch comparison ALU
        .data_operandA(dx_B),  // $rd
        .data_operandB(dx_A),  // $rs
        .ctrl_ALUopcode(5'b00001), // subtract B - A
        .ctrl_shiftamt(5'b00000),
        .data_result(branch_comp_result),
        .isNotEqual(branch_comp_isNotEqual),    // $rd != $rs
        .isLessThan(branch_comp_isLessThan),    // $rd < $rs
        .overflow(branch_comp_overflow)
    );

    assign control_branch_taken = (dx_is_bne && branch_comp_isNotEqual) || (dx_is_blt && branch_comp_isLessThan);
    or(control_flow_taken, is_jump, is_jal, fd_is_jr, bex_taken, control_branch_taken);
    dffe_ref jr_flush_dff (.q(jr_flush), .d(xm_is_jr), .clk(~clock), .en(1'b1), .clr(reset));

    // Update control_branch_or_jump to use delayed jr_flush instead of fd_is_jr
    assign control_branch_or_jump = control_branch_taken || is_jump || is_jal || jr_flush || bex_taken;

    alu jal_pc_inc (.data_operandA(PC_current), .data_operandB(32'd1), 
                    .ctrl_ALUopcode(5'b00000), .ctrl_shiftamt(5'b00000), 
                    .data_result(jal_ret_addr), .isNotEqual(), .isLessThan(), .overflow());

    // branch conditions
    assign bne_result = branch_comp_isNotEqual;
    assign blt_result = branch_comp_isLessThan;
    
    // determine if branch should be taken
    and(bne_take, dx_is_bne, bne_result);
    and(blt_take, dx_is_blt, blt_result);
    or(dx_take_branch, bne_take, blt_take);
    
    // calculate branch target: PC+1+immediate
    cla_32 branch_adder (.A(dx_PC), .B(dx_immediate), .Cin(1'b1), .Sum(dx_branch_target), .Cout(), .signed_ovf());
    
    // For arithmetic/memory operations
    and(dx_is_addimmediate, ~dx_opcode[4], ~dx_opcode[3], dx_opcode[2], ~dx_opcode[1], dx_opcode[0]);  // addi -> dx_opcode 00101
    
    // Use immediate for addi, lw, sw
    or(dx_use_immediate, dx_is_addimmediate, dx_is_lw, dx_is_sw);
    
    // Select ALU inputs
    // wire alu_A_bypass_ctrl = (dx_rs == xm_rd) ? xm_o : 
    //                         ((dx_rs == mw_rd) ? mw_o : 
    //                                             dx_A); // $rs

    assign main_alu_A = wx_stall_delayed2 ? mw_d : dx_A;// alu_A_bypass_ctrl; // if there's a load dependency (wx) prioritize that
    assign main_alu_B = dx_use_immediate ? dx_immediate : (dx_B);
    
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

    // ~~~~~~~~~ multdiv ~~~~~~~~~~~~~~~~~~
    
    and (dx_is_MULT, dx_is_rtype, ~dx_ALUop_final[4], ~dx_ALUop_final[3], dx_ALUop_final[2], 
        dx_ALUop_final[1], ~dx_ALUop_final[0]);
    and (dx_is_DIV, dx_is_rtype, ~dx_ALUop_final[4], ~dx_ALUop_final[3], dx_ALUop_final[2], 
        dx_ALUop_final[1], dx_ALUop_final[0]);
    or (dx_is_MULTDIV, dx_is_MULT, dx_is_DIV);

    // mult is instant but for div it's pretty much guaranteed to be 32 (33?) cycles
    assign md_counter_is_zero = (multdiv_counter == 6'd0);

    and (multdiv_start_valid, dx_is_MULTDIV, md_counter_is_zero);
    and(ctrl_MULT, dx_is_MULT, multdiv_start_valid);
    and(ctrl_DIV, dx_is_DIV, multdiv_start_valid);
    
    or (multdiv_counter_clear, ~dx_is_MULTDIV, multdiv_resultRDY);
    counter_6 multdiv_count(.count(multdiv_counter), .clk(~clock), .clr(multdiv_counter_clear), .en(1'b1));
    
    multdiv md(
        .data_operandA(dx_A), .data_operandB(dx_B),
        .ctrl_MULT(ctrl_MULT), .ctrl_DIV(ctrl_DIV),
        .clock(clock), .data_result(multdiv_result), .data_exception(multdiv_exception), .data_resultRDY(multdiv_resultRDY)
    );

    and(dx_is_setx, dx_opcode[4], ~dx_opcode[3], dx_opcode[2], ~dx_opcode[1], dx_opcode[0]); // 10101

    assign setx_value = {5'd0, dx_ir[26:0]}; // Take the 27-bit target field

    // xm will need result from multdiv if we did that operation, use mux from op
    wire [31:0] dx_out = mw_is_jr ? alu_result : 
                    dx_is_MULTDIV ? (multdiv_resultRDY ? multdiv_result : multdiv_bypass_value) : 
                     dx_is_setx ? setx_value :
                     alu_result;


    dffe_ref jal_ex (.q(jal_ex_active), .d(jal_fd_active), .clk(~clock), .en(~stall), .clr(reset));

    register_32 jal_ex_reg (.q(jal_ex_addr), .d(jal_fd_addr), 
                            .clk(~clock), .en(~stall), .clr(reset));


    // ~~~~~~~~~~~ FFT and INV FFT handling ~~~~~~~~~~~~~~~~~~~~~  
    
    wire dx_is_FFT, dx_is_INVFFT, dx_is_FFTCLR;
    and (dx_is_FFT, ~dx_opcode[4], dx_opcode[3], ~dx_opcode[2], ~dx_opcode[1], ~dx_opcode[0]); // FFT: 01000
    and (dx_is_INVFFT, ~dx_opcode[4], dx_opcode[3], ~dx_opcode[2], ~dx_opcode[1], dx_opcode[0]); // INV FFT: 01001
    and (dx_is_FFTCLR, ~dx_opcode[4], dx_opcode[3], ~dx_opcode[2], dx_opcode[1], ~dx_opcode[0]); // FFT CLR: 01010
    
    wire dx_FFT_real_data_in = dx_ir[15:0];
    wire FFT_done;

    FFT fft(
        .clock(clock),
        .start_FFT(dx_is_FFT),
        .[4:0] LoadDataAddr(),
        .[15:0] data_real_in(dx_FFT_real_data_in),
        .[15:0] data_imag_in(16'd0),
        .LoadDataWrite(*******idk man*************), // TODO: LoadDataWrite: what select bit do we do for this mux?
        .ACLR(dx_is_FFTCLR), //consider adding clear signal to 
        .FFT_done(FFT_done),
        .G_real_out(), // TODO: write G and H signals to main CPU DMEM after FFTdone goes high 
        .G_imag_out(), 
        .H_real_out(),
        .H_imag_out()
    );











    // ~~~~~~~~~~~ END FFT and INV FFT handling ~~~~~~~~~~~~~~~~~~~~~  
    
    
    
    
    // ~~~~~~~~~~~ STALL handling ~~~~~~~~~~~~~~~~~~~~~  
    
    wire md_stall, fft_stall, invfft_stall;
    and(md_stall, dx_is_MULTDIV, ~multdiv_resultRDY);
    and(fft_stall, dx_is_FFT, ~FFT_done);
    // and(invfft_stall, dx_is_INVFFT, ~INVFFT_done); // uncomment when INVFFT is written

    // or (stall, md_stall, fft_stall, invfft_stall); // uncomment when INVFFT is written
    or (stall, md_stall, fft_stall);


    // ~~~~~~~~~~~ exception handling ~~~~~~~~~~~~~~~~~~~~~  
    and(dx_is_ADD, dx_is_rtype, (dx_ALUop == 5'b00000));
    and(dx_is_SUB, dx_is_rtype, (dx_ALUop == 5'b00001));

    assign dx_exception_code = (dx_is_ADD & alu_overflow)  ? 32'd1 :
                               (dx_is_addimmediate & alu_overflow) ? 32'd2 :
                               (dx_is_SUB & alu_overflow)  ? 32'd3 :
                               (dx_is_MULT & multdiv_exception) ? 32'd4 :
                               (dx_is_DIV & multdiv_exception) ? 32'd5 : 32'd0;

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MULTDIV BYPASS ~~~~~~~~~~~~~~~~
    // signal for when multdiv result is valid and should be used for bypass
    assign multdiv_done = (dx_is_MULTDIV && multdiv_resultRDY);

    // store the multdiv result for bypass (for conflicts with imm insns)
    register_32 MULTDIV_BYPASS_REG (.q(multdiv_bypass_value), .d(multdiv_result), .clk(~clock), .en(multdiv_resultRDY), .clr(reset));
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END MULTDIV BYPASS ~~~~~~~~~~~~~~~~

    // ~~~~~~~~~ execution/memory pipeline regs ~~~~~~~~~
    
    assign xm_opcode = xm_ir[31:27];
    assign xm_rd = xm_ir[26:22];
    assign xm_rs = xm_ir[21:17];
    assign xm_rt = xm_ir[16:12];
    
    // detect instruction types in memory stage
    and(xm_is_lw, ~xm_opcode[4], xm_opcode[3], ~xm_opcode[2], ~xm_opcode[1], ~xm_opcode[0]); // lw: 01000
    and(xm_is_sw, ~xm_opcode[4], ~xm_opcode[3], xm_opcode[2], xm_opcode[1], xm_opcode[0]); // sw: 00111
    
    // ALU output register
    register_32 XM_O (.q(xm_o), .d(mw_is_jr ? dx_out : (control_branch_or_jump ? 32'd0 : dx_out)), .clk(~clock), .en(~stall), .clr(reset));

    // PC register for jal
    register_32 XM_PC (.q(xm_PC), .d(dx_PC), .clk(~clock), .en(~stall), .clr(reset));

    // B register (for memory store operations)
    register_32 XM_B (.q(xm_B), .d(control_branch_or_jump ? 32'd0 : dx_B), // contains register value to store for sw
        .clk(~clock), .en(~stall), .clr(reset));

    register_32 XM_IR (.q(xm_ir), .d(jr_flush ? dx_ir : control_branch_or_jump ? 32'd0 : dx_ir), .clk(~clock), .en(~stall), .clr(reset));

    register_32 XM_EXCEPTION (.q(xm_exception_code), .d(control_branch_or_jump ? 32'd0 : dx_exception_code), .clk(~clock), .en(~stall), .clr(reset));

    // jal link reg
    register_32 XM_link (.q(xm_link), .d(dx_link), .clk(~clock), .en(~stall), .clr(reset));

    // ~~~~~~~~~ memory stage ~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MEM BYPASS
    
    // check at fd_rd (source reg for SW's data) for matches with recent dest regs in pipeline (that means dx and xm)
    assign sw_bypass_from_X = fd_is_sw && (fd_rd == dx_rd) && dx_writes_reg && fd_rd_not_zero;
    assign sw_bypass_from_M = fd_is_sw && (fd_rd == xm_rd) && xm_writes_reg && fd_rd_not_zero;
    or(sw_needs_bypass_B, sw_bypass_from_X, sw_bypass_from_M);

    // select the bypassed data based on matching stage
    // assign sw_bypassed_data = sw_bypass_from_X ? alu_result : 
    //                         sw_bypass_from_M ? xm_o : 
    //                         data_readRegB; // default to original regfile output

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END MEM BYPASS
    
    // For lw/sw, address_dmem needs to be ALU result (rs + immediate)
    assign address_dmem = xm_o;
    
    // data to write to memory (for sw) comes from the B register (and is already prepped for bypass)
    assign data =  (xm_rs == mw_rd) ? xm_B : mw_o;
    
    // write enable for memory is high only for sw instruction
    assign wren = xm_is_sw;

    dffe_ref jal_mem (.q(jal_mem_active), .d(jal_ex_active), .clk(~clock), .en(~stall), .clr(reset));
    register_32 jal_mem_reg (.q(jal_mem_addr), .d(jal_ex_addr), .clk(~clock), .en(~stall), .clr(reset));
    
    // ~~~~~~~~~ memory/writeback pipeline regs ~~~~~~~~~
    
    // Extract opcode and registers from mw instruction
    assign mw_opcode = mw_ir[31:27];
    assign mw_rd = mw_ir[26:22];
    assign mw_rs = mw_ir[21:17];
    assign mw_rt = mw_ir[16:12];
    assign mw_shamt = mw_ir[11:7];
    assign mw_ALUop = mw_ir[6:2];

    dffe_ref jal_wb (.q(jal_wb_active), .d(jal_mem_active), .clk(~clock), .en(1'b1), .clr(reset));

    register_32 jal_wb_reg (.q(jal_wb_addr), .d(jal_mem_addr), .clk(~clock), .en(1'b1), .clr(reset));

    // i type: opcode, rd, rs are the same, the rest is immediate
    assign xm_immediate = {{15{xm_ir[16]}}, xm_ir[16:0]};  // we sign extend here
    assign mw_immediate = {{15{mw_ir[16]}}, mw_ir[16:0]};  // we sign extend here

    assign mw_target = {5'd0, mw_ir[26:0]}; // j1 type: opcode is the same, the rest is target
    
    // detect instruction types in writeback stage
    and(mw_is_lw, ~mw_opcode[4], mw_opcode[3], ~mw_opcode[2], ~mw_opcode[1], ~mw_opcode[0]); // lw: 01000
    and(mw_is_sw, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], mw_opcode[1], mw_opcode[0]); // sw: 00111
    and(mw_is_bne, ~mw_opcode[4], ~mw_opcode[3], ~mw_opcode[2], mw_opcode[1], ~mw_opcode[0]); // bne: 00010
    and(mw_is_blt, ~mw_opcode[4], ~mw_opcode[3], mw_opcode[2], mw_opcode[1], ~mw_opcode[0]); // blt: 00110
    and(mw_is_jal, ~mw_opcode[4], ~mw_opcode[3], ~mw_opcode[2], mw_opcode[1], mw_opcode[0]); // jal: 00011
    and(mw_is_setx, mw_opcode[4], ~mw_opcode[3], mw_opcode[2], ~mw_opcode[1], mw_opcode[0]); // setx: 10101

    // combined branch signal
    or(mw_is_branch, mw_is_bne, mw_is_blt);

    // ALU output register
    register_32 MW_O (.q(mw_o), .d(jr_flush ? xm_o : control_branch_or_jump ? 32'd0 : xm_o), .clk(~clock), .en(1'b1), .clr(reset));

    // PC register for jal return address
    register_32 MW_PC (.q(mw_PC), .d(xm_PC), .clk(~clock), .en(1'b1), .clr(reset));

    // data register - holds data from memory for lw
    register_32 MW_D (.q(mw_d), .d(control_branch_or_jump ? 32'd0 : q_dmem),  // wire memory output to MW_D register
        .clk(~clock), .en(1'b1), .clr(reset));

    register_32 MW_IR (.q(mw_ir), .d(control_branch_or_jump ? 32'd0 : xm_ir), .clk(~clock), .en(1'b1), .clr(reset));

    register_32 MW_EXCEPTION (.q(mw_exception_code), .d(control_branch_or_jump ? 32'd0 : xm_exception_code), .clk(~clock), .en(~stall), .clr(reset));
    assign mw_exception_code_flag = (mw_exception_code == 32'b0) ? 1'b0 : 1'b1; // any nonzero exception code is exception raised! this carries into writeback stage
    
    // jal link reg
    register_32 MW_link (.q(mw_link), .d(xm_link), .clk(~clock), .en(~stall), .clr(reset));

    // ~~~~~~~~~ writeback stage ~~~~~~~~~
    
    // select data to write to register file
    // lw: memory data
    // jal: PC+1 (return address)
    // other instructions: ALU result
    assign mw_is_jal = mw_ir[31:27] == 5'b00011;
    assign jal_val = jal_wb_addr;

    assign regwrite_data = mw_exception_code_flag ? mw_exception_code : 
                            (mw_is_lw ? mw_d : 
                            mw_o);
    
    // normal register write enable logic (**excluding** JAL)
    assign normal_write_enable = ~mw_is_sw && ~mw_is_jr && ~mw_is_branch;

    // normal destination register select
    assign normal_dest_reg = mw_exception_code_flag ? 5'd30 : 
                            mw_is_setx ? 5'd30 :
                            mw_rd;

    assign ctrl_writeReg = jal_wb_active ? 5'd31 : normal_dest_reg; // select destination register with JAL priority
    assign data_writeReg = jal_wb_active ? jal_val : regwrite_data; // select write data with JAL priority

    // disable register write for sw, jr, and branch instructions
    assign reg_write_enable = mw_is_jal || (~mw_is_sw && ~mw_is_jr && ~mw_is_branch);
    assign ctrl_writeEnable = reg_write_enable;
endmodule