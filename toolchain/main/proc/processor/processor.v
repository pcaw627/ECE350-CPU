/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission.
 * You are to implement a 5-stage pipelined processor in this module, accounting for hazards 
 * and implementing bypasses as necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the testbench can 
 * see which controls signal you activate when. Therefore, there needs to be a way to "inject" 
 * imem, dmem, and regfile interfaces from some external controller module. The skeleton file, 
 * Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
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
    
    /* YOUR CODE STARTS HERE */
    
    /*------------------ IF STAGE -----------------------*/
    
    // Define a dedicated PC write-enable.
    wire pc_we, stall_load;
    // (stall_multdiv is defined later in the EX stage.)
    assign pc_we = ~stall_multdiv;
    
    // PC register (latched on falling edge) now uses pc_we.
    wire [31:0] pc_in, pc_out;
    registerDFFE #(.WIDTH(32)) PC (
        .clock(~clock),
        .reset(reset),
        .we(pc_we),
        .d(stall_load ? pc_out : pc_in),
        .q(pc_out)
    );
    
    // PC increment by 1
    wire [31:0] pc_plus_1;
    wire dummy1, dummy2, dummy3;
    alu pc_increment(
        .data_operandA(pc_out),
        .data_operandB(32'd1),
        .ctrl_ALUopcode(5'b00000),
        .data_result(pc_plus_1),
        .ctrl_shiftamt(5'b00000),
        .isLessThan(dummy1),
        .isNotEqual(dummy2),
        .overflow(dummy3)
    );

     // --- Jump Logic: ---
    wire isJump_ID = (ifid_instr_out[31:27] == 5'b00001); // basic jump
    wire isJal_ID = (ifid_instr_out[31:27] == 5'b00011);
    wire isJr_ID = (ifid_instr_out[31:27] == 5'b00100);
    


    wire [26:0] jump_target_27 = ifid_instr_out[26:0];
    wire [31:0] jump_address   = {5'b0, jump_target_27};

    wire [26:0] jal_target_27 = ifid_instr_out[26:0];
    wire [31:0] jal_address   = {5'b0, jal_target_27};


    // --- Branch Logic: ---
    wire isBranch_NE_ID = (ifid_instr_out[31:27] == 5'b00010);
    wire isBranch_LT_ID = (ifid_instr_out[31:27] == 5'b00110);
    wire signed [31:0] branch_immediate = {{16{ifid_instr_out[15]}}, ifid_instr_out[15:0]};
    
    wire [31:0] branch_target;
    alu branch_adder(
        .data_operandA(pc_out),
        .data_operandB(branch_immediate),
        .ctrl_ALUopcode(5'b00000),  // addition
        .data_result(branch_target),
        .ctrl_shiftamt(5'b00000),
        .isLessThan(), .isNotEqual(), .overflow()
    );


    // JR bypassing logic
    // Define destination and write flag for the ID/EX instruction.
    wire [4:0] idex_rd = idex_instr_out[26:22];
    wire idex_isRtype = (idex_instr_out[31:27] == 5'b00000);
    wire idex_isAddi  = (idex_instr_out[31:27] == 5'b00101);
    wire idex_writes = idex_isRtype || idex_isAddi; 

    // Bypass if the ID/EX stage instruction writes to the same register as jr (field from IF/ID)
    wire jr_forward_from_idex;
    assign jr_forward_from_idex = idex_writes && (idex_rd != 5'd0) &&
                                (idex_rd == ifid_instr_out[26:22]);

    // Choose the proper operand for the second input:
    wire [31:0] idex_operandB_for_jr;
    assign idex_operandB_for_jr = idex_isAddi ? 
        { {15{idex_instr_out[16]}}, idex_instr_out[16:0] } :   // use sign-extended immediate for addi
        idex_B_out;                                             // otherwise, use the register value

    // Instantiate a jr bypass ALU that computes the result in the ID/EX stage.
    wire [31:0] idex_jr_result, idex_A_out;
    alu jr_alu (
        .data_operandA(idex_A_out),
        .data_operandB(idex_operandB_for_jr),
        .ctrl_ALUopcode(idex_isAddi ? 5'b00000 : idex_instr_out[6:2]),
        .data_result(idex_jr_result),
        .ctrl_shiftamt(5'd0),
        .isLessThan(), .isNotEqual(), .overflow()
    );



    wire jr_forward_from_mem;
    assign jr_forward_from_mem = exmem_writes & (exmem_rd_effective != 5'd0) & (exmem_rd_effective == ifid_instr_out[26:22]);

    wire jr_forward_from_wb;
    assign jr_forward_from_wb = memwb_writes & (memwb_rd_effective != 5'd0) & (memwb_rd_effective == ifid_instr_out[26:22]);

    // Choose the correct jr data: priority to ID/EX, then EX/MEM, then MEM/WB, otherwise use regfile data.
    wire [31:0] jr_data;
    assign jr_data = jr_forward_from_idex ? idex_jr_result :
                 jr_forward_from_mem   ? exmem_result_out :
                 jr_forward_from_wb    ? memwb_result_out :
                                         data_readRegA;
                                          

    // --- Branch Bypassing Logic ---
    
    wire [4:0] branch_regA = rd;
    wire [4:0] branch_regB = rs;
    
    // Check if the instruction in ID/EX writes to the register needed by the branch.
    wire branchA_forward_from_idex = idex_writes && (idex_rd != 5'd0) && (idex_rd == branch_regA);
    wire branchB_forward_from_idex = idex_writes && (idex_rd != 5'd0) && (idex_rd == branch_regB);
    
    // Also check for EX/MEM and MEM/WB stage forwarding.
    wire branchA_forward_from_mem = exmem_writes && (exmem_rd != 5'd0) && (exmem_rd == branch_regA);
    wire branchB_forward_from_mem = exmem_writes && (exmem_rd != 5'd0) && (exmem_rd == branch_regB);
    
    wire branchA_forward_from_wb = memwb_writes && (memwb_rd != 5'd0) && (memwb_rd == branch_regA);
    wire branchB_forward_from_wb = memwb_writes && (memwb_rd != 5'd0) && (memwb_rd == branch_regB);
    
    // If the ID/EX stage is forwarding, use the computed result (idex_jr_result).
    // Otherwise, check EX/MEM then MEM/WB; if none, use the regfile output.
    wire [31:0] branch_operandA;
    assign branch_operandA = branchA_forward_from_idex ? idex_jr_result :
                               branchA_forward_from_mem ? exmem_result_out :
                               branchA_forward_from_wb ? memwb_result_out :
                               data_readRegA;
    
    wire [31:0] branch_operandB;
    assign branch_operandB = branchB_forward_from_idex ? idex_jr_result :
                               branchB_forward_from_mem ? exmem_result_out :
                               branchB_forward_from_wb ? memwb_result_out :
                               data_readRegB;


    // Hazard Detection for lw 
    wire lw_hazard;
    assign lw_hazard = idex_isLoad_out && (
          (idex_instr_out[26:22] == ctrl_readRegA) || (idex_instr_out[26:22] == ctrl_readRegB)
    );

    // Additional hazard detection for branch instructions
    wire branch_lw_hazard;
    assign branch_lw_hazard = ((ifid_instr_out[31:27] == 5'b00010) || // bne
                            (ifid_instr_out[31:27] == 5'b00110)) && // blt
                            (idex_isLoad_out &&
                            (
                                (idex_instr_out[26:22] == ifid_instr_out[26:22]) || // branch’s first register (rd)
                                (idex_instr_out[26:22] == ifid_instr_out[21:17])    // branch’s second register (rs)
                            ));
    
    wire branch_hazard_detected;
    assign branch_hazard_detected = branch_lw_hazard;

    wire branch_stall_flag_next;
    wire branch_stall_flag;
    assign branch_stall_flag_next = branch_hazard_detected ? 1'b1 :
                                    (branch_counter == 6'd2 ? 1'b0 : branch_stall_flag);

    // Latch the branch stall flag.
    registerDFFE #(.WIDTH(1)) BRANCH_STALL_FLAG (
        .clock(~clock),
        .reset(reset),
        .we(1'b1),
        .d(branch_stall_flag_next),
        .q(branch_stall_flag)
    );

    // Instantiate the counter. When the branch stall flag is high, the counter counts
    wire [5:0] branch_counter;
    counter6 BRANCH_COUNTER (
        .count(branch_counter),
        .clk(~clock),
        .clr(~branch_stall_flag), // Clear the counter when the flag is low
        .en(branch_stall_flag)
    );

    // The extra stall signal for branch lw hazard is:
    wire stall_branch;
    assign stall_branch = branch_stall_flag;

    wire jr_lw_hazard;
    assign jr_lw_hazard = isJr_ID && idex_isLoad_out &&
                      (idex_instr_out[26:22] == ifid_instr_out[26:22]);

    // Latch the lw->jr hazard for two cycles:
    wire jr_stall_flag_next;
    wire jr_stall_flag; // This flag will be high for two cycles after a hazard is detected.

    // When a hazard is detected, set the flag; once the counter reaches 2, clear it.
    assign jr_stall_flag_next = jr_lw_hazard ? 1'b1 :
                                (jr_counter == 6'd2 ? 1'b0 : jr_stall_flag);

    // Use a DFFE register to hold the flag:
    registerDFFE #(.WIDTH(1)) JR_STALL_FLAG (
        .clock(~clock),
        .reset(reset),
        .we(1'b1),
        .d(jr_stall_flag_next),
        .q(jr_stall_flag)
    );

    // Instantiate the provided counter6. When jr_stall_flag is high, count; otherwise, clear.
    wire [5:0] jr_counter;
    counter6 JR_COUNTER (
        .count(jr_counter),
        .clk(~clock),
        .clr(~jr_stall_flag),
        .en(jr_stall_flag)
    );

    // The extra stall signal for lw->jr is then:
    wire stall_jr;
    assign stall_jr = jr_stall_flag;


    wire jal_hazard_detected;
    assign jal_hazard_detected = ((ifid_instr_out[31:27] == 5'b00011) &&  // JAL opcode
                                (q_imem[31:27] == 5'b00111)); // sw

    wire jal_stall_flag_next;
    wire jal_stall_flag;
    assign jal_stall_flag_next = jal_hazard_detected ? 1'b1 :
                                (jal_counter == 6'd2 ? 1'b0 : jal_stall_flag);

    // Latch the stall flag.
    registerDFFE #(.WIDTH(1)) JAL_STALL_FLAG (
        .clock(~clock),
        .reset(reset),
        .we(1'b1),
        .d(jal_stall_flag_next),
        .q(jal_stall_flag)
    );

    // The counter counts only when the stall flag is high; it resets (clr) when the flag is low.
    wire [5:0] jal_counter;
    counter6 JAL_COUNTER (
        .count(jal_counter),
        .clk(~clock),
        .clr(~jal_stall_flag),
        .en(jal_stall_flag)
    );

    // The extra stall signal for a jal hazard is then:
    wire stall_jal;
    assign stall_jal = jal_stall_flag;

    // check for multiplcation hazard with lw
    wire mult_lw_hazard;
    assign mult_lw_hazard = (ifid_instr_out[31:27] == 5'b00000 &&  // R-type
                            ifid_instr_out[6:2] == 5'b00110) &&   // mult function code (00110)
                            idex_isLoad_out &&                       // lw is in ID/EX
                            ( (idex_instr_out[26:22] == ifid_instr_out[21:17]) || // lw writes to first source
                            (idex_instr_out[26:22] == ifid_instr_out[16:12])    // or lw writes to second source
                            );
    
    wire mult_stall_flag_next;
    wire mult_stall_flag;
    assign mult_stall_flag_next = mult_lw_hazard ? 1'b1 :
                                    (mult_counter == 6'd5 ? 1'b0 : mult_stall_flag);

    registerDFFE #(.WIDTH(1)) MULT_STALL_FLAG (
        .clock(~clock),
        .reset(reset),
        .we(1'b1),
        .d(mult_stall_flag_next),
        .q(mult_stall_flag)
    );

    // Count cycles while the flag is high.
    wire [5:0] mult_counter;
    counter6 MULT_COUNTER (
        .count(mult_counter),
        .clk(~clock),
        .clr(~mult_stall_flag),  // Clear counter when flag is low.
        .en(mult_stall_flag)
    );

    // The extra stall signal for mult lw hazard is:
    wire stall_mult;
    assign stall_mult = mult_stall_flag;


    wire jr_jal_hazard;
    assign jr_jal_hazard = (ifid_instr_out[31:27] == 5'b00100) &&   // jr opcode
                        (ifid_instr_out[26:22] == 5'd31)  &&    // jr uses r31
                        (idex_instr_out[31:27] == 5'b00011);      // preceding instruction is jal

    assign stall_load = lw_hazard || stall_branch || stall_jr || stall_jal || stall_mult || jr_jal_hazard;

    wire branchOrJump = isJump_ID || branchTaken;
    wire [31:0] pc_next;
    assign pc_next = isJump_ID        ? jump_address :     // basic jump
                    bexTaken         ? bex_address   :     // bex branch (if $rstatus != 0)
                    branchTaken      ? branch_target :     // other branches (bne/blt)
                    isJr_ID          ? jr_data :
                    isJal_ID         ? jal_address :
                                        pc_plus_1;
    assign pc_in = pc_next;

    // Send PC to instruction memory
    assign address_imem = pc_out;
    
    // IF/ID pipeline latch for instruction
    wire [31:0] ifid_instr_out;

    wire flushControl = isJump_ID || branchTaken || bexTaken || isJal_ID || isJr_ID;
    wire we_ifid;
    assign we_ifid = ~stall_multdiv && ~stall_load;
    
    registerDFFE #(.WIDTH(32)) IFID_INSTR (
        .clock(~clock),
        .reset(reset),
        .we(we_ifid),
        .d(flushControl ? 32'd0 : q_imem), // When flushJump is high, load a NOP
        .q(ifid_instr_out)
    );
    wire [31:0] ifid_pc_out;
    registerDFFE #(.WIDTH(32)) IFID_PC (
        .clock(~clock),
        .reset(reset),
        .we(we_ifid),
        .d(stall_load ? ifid_pc_out : (flushControl ? 32'd0 : pc_plus_1)), // Latch the current PC
        .q(ifid_pc_out)
    );

    /*------------------ ID STAGE -----------------------*/
    
    wire [4:0] opcode = ifid_instr_out[31:27];
    wire [4:0] rd     = ifid_instr_out[26:22];
    wire [4:0] rs     = ifid_instr_out[21:17];
    wire [4:0] rt     = ifid_instr_out[16:12];
    wire [4:0] func   = ifid_instr_out[6:2];
    
    // For R-type instructions (opcode==0), detect mult/div
    wire isRtype = (opcode == 5'b00000);
    wire isMult = (isRtype && (func == 5'b00110));  // mult func
    wire isDiv  = (isRtype && (func == 5'b00111));    // div  func
    wire isMultDiv_ID = isMult || isDiv; // instruction requires multdiv
    

    // Detect store/load
    wire isStore_ID  = (opcode == 5'b00111); // sw
    wire isLoad_ID   = (opcode == 5'b01000); // lw

    // Detect branch (bne) with opcode 00010.
    wire isBranch_ID_local = isBranch_NE_ID || isBranch_LT_ID;
    // Detect bex
    wire isBex_ID = (ifid_instr_out[31:27] == 5'b10110);

    //   rd and rs (i.e. bne $rd, $rs, N), so we override regfile reads.
    //wire [4:0] branch_regA = rd;
    //wire [4:0] branch_regB = rs;


    // For non-branch, for store, use: A = rd, B = rs; for others: A = rs, B = rt.
    wire [4:0] ctrlA, ctrlB;

    assign ctrlA = (isBranch_ID_local || isJr_ID || isBex_ID) ?
                (isBex_ID ? 5'd30 : rd) : rs;
    // If branch, read from rs in port B; if store, read from rs; else read rt.
    assign ctrlB = isBranch_ID_local ? rs : (isStore_ID ? rd : rt);
    
    assign ctrl_readRegA = ctrlA;
    assign ctrl_readRegB = ctrlB;

    wire [31:0] branch_cmp_result;
    wire branch_cmp_notEqual, branch_is_less;
    alu branch_cmp(
        .data_operandA(branch_operandA), // for branch, we set regA = $rd
        .data_operandB(branch_operandB), // and regB = $rs
        .ctrl_ALUopcode(5'b00001),      // subtraction
        .data_result(branch_cmp_result),
        .ctrl_shiftamt(5'b00000),
        .isLessThan(branch_is_less), 
        .isNotEqual(branch_cmp_notEqual),
        .overflow()
    );
    
    wire branchTaken = (isBranch_NE_ID && branch_cmp_notEqual) || (isBranch_LT_ID && branch_is_less);
    wire bexTaken = isBex_ID && (data_readRegA != 32'd0);

    wire [31:0] bex_address = {5'b0, ifid_instr_out[26:0]};


    // ID/EX pipeline latches for register data
    wire [31:0] idex_B_out;
    wire we_idex;  // pipeline register enable (also gated by stall)
    assign we_idex = ~stall_multdiv; // flush during jump
    
    registerDFFE #(.WIDTH(32)) ID_EX_A (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(stall_load ? 32'd0 : (branchOrJump ? 32'd0 : data_readRegA)),
        .q(idex_A_out)
    );
    registerDFFE #(.WIDTH(32)) ID_EX_B (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(stall_load ? 32'd0 : (branchOrJump ? 32'd0 : data_readRegB)),
        .q(idex_B_out)
    );
    
    // Also latch the instruction into ID/EX
    wire [31:0] idex_instr_out;
    registerDFFE #(.WIDTH(32)) ID_EX_INSTR (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(stall_load ? 32'd0 : (branchOrJump ? 32'd0 : ifid_instr_out)),
        .q(idex_instr_out)
    );
    
    // Also latch the isMultDiv flag into EX
    wire idex_isMultDiv_out;
    registerDFFE #(.WIDTH(1)) ID_EX_ISMULTDIV (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(stall_load ? 1'd0 : isMultDiv_ID),
        .q(idex_isMultDiv_out)
    );


    // Latch isStore/isLoad into EX
    wire idex_isStore_out, idex_isLoad_out;
    registerDFFE #(.WIDTH(1)) ID_EX_ISSTORE (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(stall_load ? 1'b0 : isStore_ID),
        .q(idex_isStore_out)
    );
    registerDFFE #(.WIDTH(1)) ID_EX_ISLOAD (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(stall_load ? 1'b0 : isLoad_ID),
        .q(idex_isLoad_out)
    );


    wire [31:0] idex_link_out;
    registerDFFE #(.WIDTH(32)) ID_EX_LINK(
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(stall_load ? 32'd0 : (branchOrJump ? 32'd0 : ifid_pc_out)),
        .q(idex_link_out)
    );


    /*------------------ EX STAGE -----------------------*/
    wire [4:0] ex_opcode = idex_instr_out[31:27];
    wire [4:0] ex_func   = idex_instr_out[6:2];

    // for bypassing
    wire [4:0] ex_rs = idex_instr_out[21:17];
    wire [4:0] ex_rt = idex_instr_out[16:12];

    wire isRtypeEx = (ex_opcode == 5'b00000);
    
    wire [31:0] ex_operandA_pre = idex_A_out;
    wire [31:0] ex_operandB_pre;

    //wire is_loadOrsave = (ex_func == 5'b00111) || (ex_func == 5'b01000)
    // Sign-extend immediate [16:0] to 32 bits
    wire signed [31:0] ex_immediate = {{15{idex_instr_out[16]}}, idex_instr_out[16:0]};
    assign ex_operandB_pre = isRtypeEx ? idex_B_out : ex_immediate;
    
    // Single-cycle ALU operation (for non-multdiv instructions)

    // need to do the add for the lw/sw
    wire ex_isStore = idex_isStore_out;
    wire ex_isLoad  = idex_isLoad_out;

    wire [4:0] ex_alu_op 
      = ((idex_instr_out[31:27] == 5'b00111) || (idex_instr_out[31:27] == 5'b01000)) ? 5'b00000
      : (isRtypeEx) ? ex_func : 5'd0;

    wire [31:0] ex_alu_result;
    wire [4:0] ex_alu_shiftamt = idex_instr_out[11:7];
    wire ex_alu_Less, ex_alu_NE, ex_alu_overflow;
    
    // Bypassing Logic
    wire [4:0] exmem_rd = exmem_instr_out[26:22];
    wire [4:0] memwb_rd = memwb_instr_out[26:22];

    wire [4:0] exmem_op = exmem_instr_out[31:27];
    wire [4:0] memwb_op = memwb_instr_out[31:27];

    // checking for each of the writing type operations
    wire exmem_isRtype  = (exmem_op == 5'b00000);
    wire exmem_isAddi   = (exmem_op == 5'b00101);
    wire exmem_isLoad_B   = (exmem_op == 5'b01000);
    wire exmem_isBNE   = (exmem_op == 5'b00010);
    wire exmem_isJR   = (exmem_op == 5'b00100);
    wire exmem_isBLT   = (exmem_op == 5'b00110);
    wire exmem_isJal    = (exmem_op == 5'b00011);


    wire exmem_writes;
    assign exmem_writes = (exmem_isRtype | exmem_isAddi | exmem_isLoad_B | exmem_isBNE | exmem_isJR | exmem_isBLT | exmem_isJal);

    wire memwb_isRtype  = (memwb_op == 5'b00000);
    wire memwb_isAddi   = (memwb_op == 5'b00101);
    wire memwb_isLoad_B   = (memwb_op == 5'b01000);
    wire memwb_isBNE   = (memwb_op == 5'b00010);
    wire memwb_isJR   = (memwb_op == 5'b00100);
    wire memwb_isBLT   = (memwb_op == 5'b00110);
    wire memwb_isJal    = (memwb_op == 5'b00011);

    wire memwb_writes;
    assign memwb_writes = (memwb_isRtype | memwb_isAddi | memwb_isLoad_B | memwb_isBNE | memwb_isJR | memwb_isBLT | memwb_isJal);

    // Effective Destination for jal
    wire [4:0] exmem_rd_effective = (exmem_isJal) ? 5'd31 : exmem_instr_out[26:22];
    wire [4:0] memwb_rd_effective = (memwb_isJal) ? 5'd31 : memwb_instr_out[26:22];
    

    // For ALUinA (which uses ex_rs):
    wire sourceA_is_r30;
    assign sourceA_is_r30 = (ex_rs == 5'd30);
    wire force_forwardA_from_mem;
    assign force_forwardA_from_mem = sourceA_is_r30 && exmem_exception;
    wire force_forwardA_from_wb;
    assign force_forwardA_from_wb = sourceA_is_r30 && memwb_exception;

        
    wire forwardA_fromMem;
    assign forwardA_fromMem = exmem_writes & (exmem_rd_effective != 5'd0) & (exmem_rd_effective == ex_rs);

    wire forwardA_fromWb;
    assign forwardA_fromWb  = memwb_writes & (memwb_rd_effective != 5'd0) & (memwb_rd_effective == ex_rs);

    wire [1:0] new_forwardA_sel;
    assign new_forwardA_sel = (forwardA_fromMem || force_forwardA_from_mem) ? 2'b10 :
                              ((forwardA_fromWb || force_forwardA_from_wb) ? 2'b01 : 2'b00);

    // For ALUinB (which uses ex_rt):
    wire sourceB_is_r30;
    assign sourceB_is_r30 = (ex_rt == 5'd30);

    wire force_forwardB_from_mem = sourceB_is_r30 && exmem_exception;
    wire force_forwardB_from_wb  = sourceB_is_r30 && memwb_exception;

    wire forwardB_fromMem;
    assign forwardB_fromMem = exmem_writes & (exmem_rd_effective != 5'd0) & (exmem_rd_effective == ex_rt);

    wire forwardB_fromWb;
    assign forwardB_fromWb  = memwb_writes & (memwb_rd_effective != 5'd0) & (memwb_rd_effective == ex_rt);

    // new_forwardB_sel: 
    // 2'b10 means choose the EX/MEM bypass,
    // 2'b01 means choose the MEM/WB bypass,
    // 2'b00 means no bypass.
    wire [1:0] new_forwardB_sel;
    assign new_forwardB_sel = (forwardB_fromMem || force_forwardB_from_mem) ? 2'b10 :
                            ((forwardB_fromWb || force_forwardB_from_wb) ? 2'b01 : 2'b00);

    wire [1:0] forwardA_sel;
    assign forwardA_sel[1] = forwardA_fromMem;
    assign forwardA_sel[0] = (~forwardA_fromMem) & forwardA_fromWb; 



    // choose between the data values
    wire [31:0] bypassA_mem, bypassA_wb, bypassA_idex;
    assign bypassA_mem  = exmem_result_out;
    assign bypassA_wb   = memwb_result_out;
    assign bypassA_idex = ex_operandA_pre;

    wire [31:0] bypassA_mem_new;
    assign bypassA_mem_new = (sourceA_is_r30 && exmem_exception) ? exmem_excode
                              : exmem_result_out;
    wire [31:0] bypassA_wb_new;
    assign bypassA_wb_new = (sourceA_is_r30 && memwb_exception) ? memwb_excode
                             : memwb_result_out;
    
    // Then use these new signals in the mux:
    wire [31:0] ex_operandA;
    assign ex_operandA = (forwardA_sel == 2'b10) ? bypassA_mem_new  :
                         (forwardA_sel == 2'b01) ? bypassA_wb_new   :
                                                  bypassA_idex;


    wire [31:0] bypassB_mem, bypassB_wb, bypassB_idex;
    assign bypassB_mem  = exmem_result_out;
    assign bypassB_wb   = memwb_result_out;
    assign bypassB_idex = ex_operandB_pre;
    
    wire [31:0] bypassB_mem_new;
    assign bypassB_mem_new = (sourceB_is_r30 && exmem_exception) ? exmem_excode
                              : exmem_result_out;
    wire [31:0] bypassB_wb_new;
    assign bypassB_wb_new = (sourceB_is_r30 && memwb_exception) ? memwb_excode
                             : memwb_result_out;
        
    wire [31:0] ex_operandB;                     
    assign ex_operandB = (new_forwardB_sel == 2'b10) ? bypassB_mem_new  :
                        (new_forwardB_sel == 2'b01) ? bypassB_wb_new   :
                                                    bypassB_idex;

    alu ALU(
        .data_operandA  (ex_operandA),
        .data_operandB  (ex_operandB),
        .ctrl_ALUopcode (ex_alu_op),
        .data_result    (ex_alu_result),
        .ctrl_shiftamt  (ex_alu_shiftamt),
        .isLessThan     (ex_alu_Less),
        .isNotEqual     (ex_alu_NE),
        .overflow       (ex_alu_overflow)
    );
    
    // Multi-cycle (multdiv)
    wire [5:0] ex_cycle_counter;
    wire md_resultRDY;

    counter6 multdiv_count(
        .count(ex_cycle_counter), 
        .clk(~clock),
        .clr(~idex_isMultDiv_out || md_resultRDY),
        .en(1'b1)
    );
    
    // Generate one-cycle start pulse thats high only when the instruction is mult/div and counter is zero.
    wire multdiv_start;
    assign multdiv_start = idex_isMultDiv_out & (ex_cycle_counter == 6'd0);
    
    // Determine the type of mult/div operation based on the function field.
    wire ex_isMult = (idex_instr_out[6:2] == 5'b00110) & idex_isMultDiv_out;
    wire ex_isDiv  = (idex_instr_out[6:2] == 5'b00111) & idex_isMultDiv_out;
    
    // Generate one-cycle pulses for multdiv control signals.
    wire ctrl_MULT = ex_isMult & multdiv_start;
    wire ctrl_DIV  = ex_isDiv  & multdiv_start;
    
    // Instantiate the multdiv module.
    wire [31:0] md_result;
    wire md_exception;
    
    multdiv MULTDIV(
        .data_operandA (ex_operandA),
        .data_operandB (ex_operandB),
        .ctrl_MULT     (ctrl_MULT),
        .ctrl_DIV      (ctrl_DIV),
        .clock         (clock),
        .data_result   (md_result),
        .data_exception(md_exception),
        .data_resultRDY(md_resultRDY)
    );
    
    // Choose the final EX result: if mult/div, use multdiv result; otherwise use ALU result.
    wire [31:0] ex_result;
    wire is_setxEx = ex_func == 5'b10101;
    assign ex_result = is_setxEx ? {5'd0, idex_instr_out[26:0]} :
                        idex_isMultDiv_out ? md_result : ex_alu_result;
    
    // Exception Handling in EX Stage
    wire isAdd, isSub, isAddi, isMult_ex, isDiv_ex;
    assign isAdd   = isRtypeEx & (idex_instr_out[6:2] == 5'b00000);
    assign isSub   = isRtypeEx & (idex_instr_out[6:2] == 5'b00001);
    assign isAddi  = (idex_instr_out[31:27] == 5'b00101);
    assign isMult_ex = (idex_instr_out[6:2] == 5'b00110) & idex_isMultDiv_out;
    assign isDiv_ex  = (idex_instr_out[6:2] == 5'b00111) & idex_isMultDiv_out;
    
    // Exception flag in EX: high if an overflow/exception occurs.
    wire ex_exception;
    assign ex_exception = (((isAdd | isSub | isAddi) & ex_alu_overflow) |
                           ((isMult_ex | isDiv_ex) & md_exception));
    
    // Exception code: based on the operation type.
    // (add: 1, addi: 2, sub: 3, mult: 4, div: 5)
    wire [31:0] ex_exception_code;
    assign ex_exception_code = (isAdd  & ex_alu_overflow)  ? 32'd1 :
                               (isAddi & ex_alu_overflow) ? 32'd2 :
                               (isSub  & ex_alu_overflow)  ? 32'd3 :
                               (isMult_ex & md_exception) ? 32'd4 :
                               (isDiv_ex  & md_exception) ? 32'd5 : 32'd0;


    // Determine if the instruction in ID/EX is a store.
    wire isStore_EX;
    assign isStore_EX = (idex_instr_out[31:27] == 5'b00111);

    // Create bypass signals for store data.
    // compare the destination register of instructions in later stages
    // with the store source register (which for sw is in idex_instr_out[26:22]).
    wire store_forward_from_mem;
    assign store_forward_from_mem = exmem_writes && (exmem_rd != 5'd0) && (exmem_rd == idex_instr_out[26:22]);
    wire store_forward_from_wb;
    assign store_forward_from_wb = memwb_writes && (memwb_rd != 5'd0) && (memwb_rd == idex_instr_out[26:22]);

    // Select the correct store data.
    wire [31:0] store_data_bypassed;
    assign store_data_bypassed = store_forward_from_mem ? exmem_result_out :
                                 store_forward_from_wb ? memwb_result_out :
                                                         idex_B_out;


    // Stall Logic for Mult/Div

    // Stall the pipeline (Fetch, Decode, Execute) if the multdiv operation hasn't completed.
    wire stall_multdiv;
    assign stall_multdiv = idex_isMultDiv_out & ~md_resultRDY;
    
    wire we_exmem = ~stall_multdiv;
    wire we_memwb = 1'b1; // MEM->WB always updates

    // Latches for load/store
    wire exmem_isLoad, exmem_isStore;
    registerDFFE #(.WIDTH(1)) EX_MEM_ISLOAD (
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d(ex_isLoad),
        .q(exmem_isLoad)
    );
    registerDFFE #(.WIDTH(1)) EX_MEM_ISSTORE (
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d(ex_isStore),
        .q(exmem_isStore)
    );

    // Propagate Exception Signals through EX/MEM
    wire exmem_exception;
    registerDFFE #(.WIDTH(1)) EX_MEM_EXCEPTION (
         .clock(~clock),
         .reset(reset),
         .we(we_exmem),
         .d(ex_exception), //branchOrJump ? 1'd0 : 
         .q(exmem_exception)
    );
    wire [31:0] exmem_excode;
    registerDFFE #(.WIDTH(32)) EX_MEM_EXCODE (
         .clock(~clock),
         .reset(reset),
         .we(we_exmem),
         .d(ex_exception_code),
         .q(exmem_excode)
    );

    // EX/MEM pipeline latches
    wire [31:0] exmem_result_out;
    registerDFFE #(.WIDTH(32)) EX_MEM_RESULT (
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d(ex_result), 
        .q(exmem_result_out)
    );
    
    wire [31:0] exmem_instr_out;
    registerDFFE #(.WIDTH(32)) EX_MEM_INSTR (
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d(idex_instr_out), 
        .q(exmem_instr_out)
    );
    
    wire [31:0] exmem_Bdata_out;
    registerDFFE #(.WIDTH(32)) EX_MEM_BDATA (
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d((isStore_EX ? store_data_bypassed : idex_B_out)),
        .q(exmem_Bdata_out)
    );
    
    // jal latch
    wire [31:0] exmem_link_out;
    registerDFFE #(.WIDTH(32)) EX_MEM_LINK(
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d(idex_link_out),
        .q(exmem_link_out)
    );


    /*------------------ MEM STAGE -----------------------*/
    
    assign address_dmem = exmem_result_out;
    assign wren = exmem_isStore; // store => 1, else 0
    assign data = exmem_Bdata_out; // store data

    // memory read data
    wire [31:0] mem_data_out = q_dmem;

    // Decide the MEM result; if load, take mem_data_out else take exmem_result_out
    wire memwb_isStore;
    assign memwb_isStore = (memwb_instr_out[31:27] == 5'b00111); // sw opcode
    wire load_forward_from_store;

    assign load_forward_from_store = exmem_isLoad && memwb_isStore_flag &&
                                    (exmem_result_out == memwb_store_addr);

    wire [31:0] mem_result;
    assign mem_result = exmem_isLoad ? 
                        (load_forward_from_store ? memwb_store_data : mem_data_out)
                        : exmem_result_out;


    // MEM/WB pipeline latches
    wire memwb_isStore_flag;
    registerDFFE #(.WIDTH(1)) MEM_WB_ISSTORE (
        .clock(~clock),
        .reset(reset),
        .we(we_memwb),
        .d(exmem_isStore),
        .q(memwb_isStore_flag)
    );

    wire [31:0] memwb_result_out;
    registerDFFE #(.WIDTH(32)) MEM_WB_RESULT (
        .clock(~clock),
        .reset(reset),
        .we(we_memwb),
        .d(mem_result),
        .q(memwb_result_out)
    );
    
    wire [31:0] memwb_instr_out;
    registerDFFE #(.WIDTH(32)) MEM_WB_INSTR (
        .clock(~clock),
        .reset(reset),
        .we(we_memwb),
        .d(exmem_instr_out),
        .q(memwb_instr_out)
    );
    
    // Exceptions
    wire memwb_exception;
    registerDFFE #(.WIDTH(1)) MEM_WB_EXCEPTION (
         .clock(~clock),
         .reset(reset),
         .we(we_memwb),
         .d(exmem_exception),
         .q(memwb_exception)
    );
    wire [31:0] memwb_excode;
    registerDFFE #(.WIDTH(32)) MEM_WB_EXCODE (
         .clock(~clock),
         .reset(reset),
         .we(we_memwb),
         .d(exmem_excode),
         .q(memwb_excode)
    );

    // Latch the store data from EX/MEM into MEM/WB.
    wire [31:0] memwb_store_data;
    registerDFFE #(.WIDTH(32)) MEM_WB_STOREDATA (
        .clock(~clock),
        .reset(reset),
        .we(we_memwb),
        .d(exmem_Bdata_out),
        .q(memwb_store_data)
    );

    wire [31:0] memwb_store_addr;
    registerDFFE #(.WIDTH(32)) MEM_WB_STORE_ADDR (
        .clock(~clock),
        .reset(reset),
        .we(we_memwb),
        .d(exmem_result_out),
        .q(memwb_store_addr)
    );

    // jal latch
    wire [31:0] memwb_link_out;
    registerDFFE #(.WIDTH(32)) MEM_WB_LINK(
        .clock(~clock),
        .reset(reset),
        .we(we_memwb),
        .d(exmem_link_out),
        .q(memwb_link_out)
    );

    /*------------------ WB STAGE -----------------------*/
    
    // For R-type instructions, assume bits [26:22] indicate the destination register.
    // last check to make sure i don't run a failed jump as another operation
    wire failed_jump = (memwb_instr_out[31:27] == 5'b00010) || (memwb_instr_out[31:27] == 5'b00110) ||
                        (memwb_instr_out[31:27] == 5'b00100);

    wire is_jalWB = memwb_instr_out[31:27] == 5'b00011;
    wire is_setxWB = memwb_instr_out[31:27] == 5'b10101;
    wire is_storeWB = memwb_instr_out[31:27] == 5'b00111;

    wire [4:0] normal_rd = memwb_instr_out[26:22];
    wire [4:0] wb_rd;
    assign wb_rd = memwb_exception ? 5'd30 : 
                    (is_jalWB ? 5'd31 : 
                    is_setxWB ? 5'd30 : normal_rd);
                    
    assign ctrl_writeReg = (failed_jump) ? 5'b00000 : wb_rd;
    
    wire [31:0] wb_data;
    assign wb_data = memwb_exception ? memwb_excode : 
                    (is_jalWB ? memwb_link_out : memwb_result_out);
    assign data_writeReg = (failed_jump) ? 32'd0 : wb_data;
    
    assign ctrl_writeEnable = is_storeWB ? 1'b0 : 1'b1;
    
    
endmodule