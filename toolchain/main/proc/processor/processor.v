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
    wire pc_we;
    // (stall_multdiv is defined later in the EX stage.)
    assign pc_we = ~stall_multdiv;
    
    // PC register (latched on falling edge) now uses pc_we.
    wire [31:0] pc_in, pc_out;
    registerDFFE #(.WIDTH(32)) PC (
        .clock(~clock),
        .reset(reset),
        .we(pc_we),
        .d(pc_in),
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

    wire branchOrJump = isJump_ID || branchTaken;
    wire [31:0] pc_next;
    assign pc_next = isJump_ID        ? jump_address :     // basic jump
                    bexTaken         ? bex_address   :     // bex branch (if $rstatus != 0)
                    branchTaken      ? branch_target :     // other branches (bne/blt)
                    isJr_ID          ? data_readRegA :
                    isJal_ID         ? jal_address :
                                        pc_plus_1;
    assign pc_in = pc_next;

    // Send PC to instruction memory
    assign address_imem = pc_out;
    
    // IF/ID pipeline latch for instruction
    wire [31:0] ifid_instr_out;

    wire flushControl = isJump_ID || branchTaken || bexTaken || isJr_ID || isJal_ID;
    wire we_ifid;
    assign we_ifid = ~stall_multdiv;
    
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
        .d(flushControl ? 32'd0 : pc_plus_1), // Latch the current PC
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
    wire isMult = (isRtype && (func == 5'b00110));  // "mult" func
    wire isDiv  = (isRtype && (func == 5'b00111));    // "div"  func
    wire isMultDiv_ID = isMult || isDiv; // instruction requires multdiv
    

    // Detect store/load
    wire isStore_ID  = (opcode == 5'b00111); // sw
    wire isLoad_ID   = (opcode == 5'b01000); // lw

    // Detect branch (bne) with opcode 00010.
    wire isBranch_ID_local = isBranch_NE_ID || isBranch_LT_ID;
    // Detect bxe
    wire isBex_ID = (ifid_instr_out[31:27] == 5'b10110);

    // For branch instructions, we assume the two registers to compare are in fields:
    //   rd and rs (i.e. bne $rd, $rs, N), so we override regfile reads.
    wire [4:0] branch_regA = rd;
    wire [4:0] branch_regB = rs;


    // For non-branch, for store, use: A = rd, B = rs; for others: A = rs, B = rt.
    wire [4:0] ctrlA, ctrlB;

    assign ctrlA = (isBranch_ID_local || isJr_ID || isBex_ID) ?
                (isBex_ID ? 5'd30 : rd) : rs;
    // If branch, read from 'rs' in port B; if store, read from 'rs'; else read 'rt'.
    assign ctrlB = isBranch_ID_local ? rs : (isStore_ID ? rd : rt);
    
    assign ctrl_readRegA = ctrlA;
    assign ctrl_readRegB = ctrlB;

    wire [31:0] branch_cmp_result;
    wire branch_cmp_notEqual, branch_is_less;
    alu branch_cmp(
        .data_operandA(data_readRegA), // for branch, we set regA = $rd
        .data_operandB(data_readRegB), // and regB = $rs
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
    wire [31:0] idex_A_out, idex_B_out;
    wire we_idex;  // pipeline register enable (also gated by stall)
    assign we_idex = ~stall_multdiv; // flush during jump
    
    registerDFFE #(.WIDTH(32)) ID_EX_A (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(branchOrJump ? 32'd0 : data_readRegA),
        .q(idex_A_out)
    );
    registerDFFE #(.WIDTH(32)) ID_EX_B (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(branchOrJump ? 32'd0 : data_readRegB),
        .q(idex_B_out)
    );
    
    // Also latch the instruction into ID/EX
    wire [31:0] idex_instr_out;
    registerDFFE #(.WIDTH(32)) ID_EX_INSTR (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(branchOrJump ? 32'd0 : ifid_instr_out),
        .q(idex_instr_out)
    );
    
    // Also latch the isMultDiv flag into EX
    wire idex_isMultDiv_out;
    registerDFFE #(.WIDTH(1)) ID_EX_ISMULTDIV (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(isMultDiv_ID),
        .q(idex_isMultDiv_out)
    );

    // Latch isStore/isLoad into EX
    wire idex_isStore_out, idex_isLoad_out;
    registerDFFE #(.WIDTH(1)) ID_EX_ISSTORE (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(isStore_ID),
        .q(idex_isStore_out)
    );
    registerDFFE #(.WIDTH(1)) ID_EX_ISLOAD (
        .clock(~clock),
        .reset(reset),
        .we(we_idex),
        .d(isLoad_ID),
        .q(idex_isLoad_out)
    );


    wire [31:0] idex_link_out;
    registerDFFE #(.WIDTH(32)) ID_EX_LINK(
        .clock(~clock),
        .reset(reset),
        .we(we_idex),  // same enable as your ID->EX pipeline
        // flush if branchOrJump?  (You can flush with "branchOrJump ? 32'd0 : link_address_ID")
        .d(branchOrJump ? 32'd0 : ifid_pc_out),
        .q(idex_link_out)
    );


    /*------------------ EX STAGE -----------------------*/
    wire [4:0] ex_opcode = idex_instr_out[31:27];
    wire [4:0] ex_func   = idex_instr_out[6:2];

    wire isRtypeEx = (ex_opcode == 5'b00000);
    
    wire [31:0] ex_operandA = idex_A_out;
    wire [31:0] ex_operandB;

    //wire is_loadOrsave = (ex_func == 5'b00111) || (ex_func == 5'b01000)
    // Sign-extend immediate [16:0] to 32 bits (adjust if necessary)
    wire signed [31:0] ex_immediate = {{15{idex_instr_out[16]}}, idex_instr_out[16:0]};
    assign ex_operandB = isRtypeEx ? idex_B_out : ex_immediate;
    
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
    
    // Generate one-cycle start pulse: high only when the instruction is mult/div and counter is zero.
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



    // Stall Logic for Mult/Div

    // Stall the pipeline (IF/ID, ID/EX, EX/MEM) if the multdiv operation hasn't completed.
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
         .d(branchOrJump ? 1'd0 : ex_exception),
         .q(exmem_exception)
    );
    wire [31:0] exmem_excode;
    registerDFFE #(.WIDTH(32)) EX_MEM_EXCODE (
         .clock(~clock),
         .reset(reset),
         .we(we_exmem),
         .d(branchOrJump ? 32'd0 : ex_exception_code),
         .q(exmem_excode)
    );

    // EX/MEM pipeline latches
    wire [31:0] exmem_result_out;
    registerDFFE #(.WIDTH(32)) EX_MEM_RESULT (
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d(branchOrJump ? 32'd0 : ex_result),
        .q(exmem_result_out)
    );
    
    wire [31:0] exmem_instr_out;
    registerDFFE #(.WIDTH(32)) EX_MEM_INSTR (
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d(branchOrJump ? 32'd0 : idex_instr_out),
        .q(exmem_instr_out)
    );
    
    wire [31:0] exmem_Bdata_out;
    registerDFFE #(.WIDTH(32)) EX_MEM_BDATA (
        .clock(~clock),
        .reset(reset),
        .we(we_exmem),
        .d(branchOrJump ? 32'd0 : idex_B_out),
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
    assign data = exmem_Bdata_out;      // store data

    // memory read data
    wire [31:0] mem_data_out = q_dmem;

    // Decide the MEM result; if load, take mem_data_out else take exmem_result_out
    wire [31:0] mem_result = exmem_isLoad ? mem_data_out : exmem_result_out;

    // MEM/WB pipeline latches
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
