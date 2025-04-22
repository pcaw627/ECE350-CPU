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
    data_readRegB,                  // I: Data from port B of RegFile


    // FPGA IN/OUT
    BTNU,
    BTND,
    BTNL,
    BTNR,
    BTNC

);

    // Control signals
    input clock, reset, BTNU, BTND, BTNL, BTNR, BTNC;
    output BTNU_out, BTND_out, BTNL_out, BTNR_out, BTNC_out;
  
    
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
    // (stall is defined later in the EX stage.)
    assign pc_we = ~stall;
    
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
    assign we_ifid = ~stall;
    
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
    assign we_idex = ~stall; // flush during jump
    
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


    localparam WIDTH = 16;

    // FFT & IFFT Multi-cycle operations


    // FFT opcode = 01000

    reg [15:0] adc_fft_regs [0:63];
    reg [15:0] fft_mod_regs [0:63]; 
    reg [15:0] mod_ifft_regs [0:63];
    reg [15:0] ifft_out_regs [0:63];

    integer reg_idx;
    initial begin
        for (reg_idx=0; reg_idx<64; reg_idx+=1) begin
            //adc_fft_regs[reg_idx] = 16'd0;
            fft_mod_regs[reg_idx] = 16'd0;
            mod_ifft_regs[reg_idx] = 16'd0;
            ifft_out_regs[reg_idx] = 16'd0;
        end
    end 

    wire  fft_in_en, fft_reset, fft_reset_unsynced;
    wire [WIDTH-1:0] fft_in_re,  fft_in_im;
    wire fft_out_en;
    wire [WIDTH-1:0] fft_out_re, fft_out_im;
    // inverse FFT
    wire ifft_in_en;
    wire [WIDTH-1:0] ifft_in_re;
    reg [WIDTH-1:0] ifft_in_im;
    wire ifft_out_en;
    wire [WIDTH-1:0] ifft_out_re, ifft_out_im;

    wire ex_is_fft, ex_is_ifft;
    assign ex_is_fft = (idex_instr_out[31:27] == 5'b10000);
    assign ex_is_ifft = (idex_instr_out[31:27] == 5'b10001);


    reg [7:0] fft_count;
    always @(posedge clock) begin
        if (fft_reset) begin
            fft_count <= 7'd0;
        end else begin
            fft_count <= ex_is_fft ? (fft_count + 1'b1) : fft_count;
        end
    end
    
    reg [7:0] ifft_count;
    always @(posedge clock) begin
        if (fft_reset) begin
            ifft_count <= 7'd0;
        end else if (ifft_in_en) begin
            ifft_in_im <= mod_ifft_regs[ifft_count-2];
            // ifft_in_im <= fft_regs[bitrev6(ifft_count-2)];
            ifft_count <= ex_is_ifft ? (ifft_count + 1'b1) : ifft_count;
        end else begin
            ifft_count <= ex_is_ifft ? (ifft_count + 1'b1) : ifft_count;
        end
    end

    
    assign fft_reset_unsynced = reset | ((ifid_instr_out[31:27] == 5'b10000) | (ifid_instr_out[31:27] == 5'b10001));
    dffe_ref fft_dff (.q(fft_reset), .d(fft_reset_unsynced), .en(1'b1), .clk(clock), .clr(1'b0));
    assign fft_in_en = (fft_count < 65) & (fft_count>0);
    assign ifft_in_en = (ifft_count < 67) & (ifft_count>2);

    // // take adc output and shift it so the 12 bit input matches the 16 bits needed for fft
    // assign fft_in_re = {adc_data_out, 4'd0};

    wire [15:0] adc_data_out [0:63]; 

    wire [15:0] adc_data_out_test;

    initial begin
        adc_fft_regs[0] <= 16'h0000;
        adc_fft_regs[1] <= 16'h0C8B;
        adc_fft_regs[2] <= 16'h18F8;
        adc_fft_regs[3] <= 16'h2527;
        adc_fft_regs[4] <= 16'h30FB;
        adc_fft_regs[5] <= 16'h3C56;
        adc_fft_regs[6] <= 16'h471C;
        adc_fft_regs[7] <= 16'h5133;
        adc_fft_regs[8] <= 16'h5A81;
        adc_fft_regs[9] <= 16'h62F1;
        adc_fft_regs[10] <= 16'h6A6C;
        adc_fft_regs[11] <= 16'h70E1;
        adc_fft_regs[12] <= 16'h7640;
        adc_fft_regs[13] <= 16'h7A7C;
        adc_fft_regs[14] <= 16'h7D89;
        adc_fft_regs[15] <= 16'h7F61;
        adc_fft_regs[16] <= 16'h7FFF;
        adc_fft_regs[17] <= 16'h7F61;
        adc_fft_regs[18] <= 16'h7D89;
        adc_fft_regs[19] <= 16'h7A7C;
        adc_fft_regs[20] <= 16'h7640;
        adc_fft_regs[21] <= 16'h70E1;
        adc_fft_regs[22] <= 16'h6A6C;
        adc_fft_regs[23] <= 16'h62F1;
        adc_fft_regs[24] <= 16'h5A81;
        adc_fft_regs[25] <= 16'h5133;
        adc_fft_regs[26] <= 16'h471C;
        adc_fft_regs[27] <= 16'h3C56;
        adc_fft_regs[28] <= 16'h30FB;
        adc_fft_regs[29] <= 16'h2527;
        adc_fft_regs[30] <= 16'h18F8;
        adc_fft_regs[31] <= 16'h0C8B;
        adc_fft_regs[32] <= 16'h0000;
        adc_fft_regs[33] <= 16'hF375;
        adc_fft_regs[34] <= 16'hE708;
        adc_fft_regs[35] <= 16'hDAD9;
        adc_fft_regs[36] <= 16'hCF05;
        adc_fft_regs[37] <= 16'hC3AA;
        adc_fft_regs[38] <= 16'hB8E4;
        adc_fft_regs[39] <= 16'hAECD;
        adc_fft_regs[40] <= 16'hA57F;
        adc_fft_regs[41] <= 16'h9D0F;
        adc_fft_regs[42] <= 16'h9594;
        adc_fft_regs[43] <= 16'h8F1F;
        adc_fft_regs[44] <= 16'h89C0;
        adc_fft_regs[45] <= 16'h8584;
        adc_fft_regs[46] <= 16'h8277;
        adc_fft_regs[47] <= 16'h809F;
        adc_fft_regs[48] <= 16'h8001;
        adc_fft_regs[49] <= 16'h809F;
        adc_fft_regs[50] <= 16'h8277;
        adc_fft_regs[51] <= 16'h8584;
        adc_fft_regs[52] <= 16'h89C0;
        adc_fft_regs[53] <= 16'h8F1F;
        adc_fft_regs[54] <= 16'h9594;
        adc_fft_regs[55] <= 16'h9D0F;
        adc_fft_regs[56] <= 16'hA57F;
        adc_fft_regs[57] <= 16'hAECD;
        adc_fft_regs[58] <= 16'hB8E4;
        adc_fft_regs[59] <= 16'hC3AA;
        adc_fft_regs[60] <= 16'hCF05;
        adc_fft_regs[61] <= 16'hDAD9;
        adc_fft_regs[62] <= 16'hE708;
        adc_fft_regs[63] <= 16'hF375;
    end

    assign adc_data_out [0] = 16'h0000;
    assign adc_data_out [1] = 16'h0C8B;
    assign adc_data_out [2] = 16'h18F8;
    assign adc_data_out [3] = 16'h2527;
    assign adc_data_out [4] = 16'h30FB;
    assign adc_data_out [5] = 16'h3C56;
    assign adc_data_out [6] = 16'h471C;
    assign adc_data_out [7] = 16'h5133;
    assign adc_data_out [8] = 16'h5A81;
    assign adc_data_out [9] = 16'h62F1;
    assign adc_data_out [10] = 16'h6A6C;
    assign adc_data_out [11] = 16'h70E1;
    assign adc_data_out [12] = 16'h7640;
    assign adc_data_out [13] = 16'h7A7C;
    assign adc_data_out [14] = 16'h7D89;
    assign adc_data_out [15] = 16'h7F61;
    assign adc_data_out [16] = 16'h7FFF;
    assign adc_data_out [17] = 16'h7F61;
    assign adc_data_out [18] = 16'h7D89;
    assign adc_data_out [19] = 16'h7A7C;
    assign adc_data_out [20] = 16'h7640;
    assign adc_data_out [21] = 16'h70E1;
    assign adc_data_out [22] = 16'h6A6C;
    assign adc_data_out [23] = 16'h62F1;
    assign adc_data_out [24] = 16'h5A81;
    assign adc_data_out [25] = 16'h5133;
    assign adc_data_out [26] = 16'h471C;
    assign adc_data_out [27] = 16'h3C56;
    assign adc_data_out [28] = 16'h30FB;
    assign adc_data_out [29] = 16'h2527;
    assign adc_data_out [30] = 16'h18F8;
    assign adc_data_out [31] = 16'h0C8B;
    assign adc_data_out [32] = 16'h0000;
    assign adc_data_out [33] = 16'hF375;
    assign adc_data_out [34] = 16'hE708;
    assign adc_data_out [35] = 16'hDAD9;
    assign adc_data_out [36] = 16'hCF05;
    assign adc_data_out [37] = 16'hC3AA;
    assign adc_data_out [38] = 16'hB8E4;
    assign adc_data_out [39] = 16'hAECD;
    assign adc_data_out [40] = 16'hA57F;
    assign adc_data_out [41] = 16'h9D0F;
    assign adc_data_out [42] = 16'h9594;
    assign adc_data_out [43] = 16'h8F1F;
    assign adc_data_out [44] = 16'h89C0;
    assign adc_data_out [45] = 16'h8584;
    assign adc_data_out [46] = 16'h8277;
    assign adc_data_out [47] = 16'h809F;
    assign adc_data_out [48] = 16'h8001;
    assign adc_data_out [49] = 16'h809F;
    assign adc_data_out [50] = 16'h8277;
    assign adc_data_out [51] = 16'h8584;
    assign adc_data_out [52] = 16'h89C0;
    assign adc_data_out [53] = 16'h8F1F;
    assign adc_data_out [54] = 16'h9594;
    assign adc_data_out [55] = 16'h9D0F;
    assign adc_data_out [56] = 16'hA57F;
    assign adc_data_out [57] = 16'hAECD;
    assign adc_data_out [58] = 16'hB8E4;
    assign adc_data_out [59] = 16'hC3AA;
    assign adc_data_out [60] = 16'hCF05;
    assign adc_data_out [61] = 16'hDAD9;
    assign adc_data_out [62] = 16'hE708;
    assign adc_data_out [63] = 16'hF375;
    


    assign fft_in_re = adc_fft_regs[fft_count-1];


    sdf_fft  #(.WIDTH(16)) U_FFT  (
      .clock        (clock),
      .reset        (fft_reset),
      .data_in_en   (fft_in_en),
      .data_in_real (fft_in_re),
      .data_in_imag (16'd0),
      .data_out_en  (fft_out_en),
      .data_out_real(fft_out_re),
      .data_out_imag(fft_out_im) // 16'd0 will always be 0 bc imag is always 0
    );

   function integer bitrev6;       // 6-bit bit-reverse
      input integer idx;
      integer j;
      begin
         bitrev6 = 0;
         for (j = 0; j < 6; j = j + 1)
            bitrev6 = bitrev6 | (((idx >> j) & 1) << (5 - j));
      end
   endfunction

    reg [5:0] fft_data_out_count;
    always @(posedge clock or posedge fft_reset) begin
        if (fft_reset) begin
            fft_data_out_count <= 5'd0;
        end else if (fft_out_en) begin
            fft_data_out_count <= ex_is_fft ? (fft_data_out_count + 1'b1) : fft_data_out_count;
            fft_mod_regs [bitrev6(fft_data_out_count)] <= fft_out_im; // inverse bit order for output
        end
    end


    wire ex_is_mod = (idex_instr_out[31:27] == 5'b11000);
    wire [5:0] ex_mod_index = (idex_instr_out[21:17]-1)<<2;
    wire [15:0] ex_mod_operandA = ex_operandA[15:0];
    wire [15:0] mod_out1, mod_out2, mod_out3, mod_out4;
    wallace_16 mod_mult1(
        .a(ex_mod_operandA),
        .b(fft_mod_regs[ex_mod_index]),
        .product(),
        .product_hi(mod_out1),
        .product_lo(),
        .ovf()
    );  
    wallace_16 mod_mult2(
        .a(ex_mod_operandA),
        .b(fft_mod_regs[ex_mod_index+1]),
        .product(),
        .product_hi(mod_out2),
        .product_lo(),
        .ovf()
    );      
    wallace_16 mod_mult3(
        .a(ex_mod_operandA),
        .b(fft_mod_regs[ex_mod_index+2]),
        .product(),
        .product_hi(mod_out3),
        .product_lo(),
        .ovf()
    );      
    wallace_16 mod_mult4(
        .a(ex_mod_operandA),
        .b(fft_mod_regs[ex_mod_index+3]),
        .product(),
        .product_hi(mod_out4),
        .product_lo(),
        .ovf()
    );  

    always @(posedge clock) begin
        if (ex_is_mod) begin
            mod_ifft_regs[ex_mod_index] <= mod_out1 <<< 1;
            mod_ifft_regs[ex_mod_index+1] <= mod_out2 <<< 1;
            mod_ifft_regs[ex_mod_index+2] <= mod_out3 <<< 1;
            mod_ifft_regs[ex_mod_index+3] <= mod_out4 <<< 1;
        end 
    end
    
    
// FFT output flat wires
wire [15:0] fft_out_flat0;
wire [15:0] fft_out_flat1;
wire [15:0] fft_out_flat2;
wire [15:0] fft_out_flat3;
wire [15:0] fft_out_flat4;
wire [15:0] fft_out_flat5;
wire [15:0] fft_out_flat6;
wire [15:0] fft_out_flat7;
wire [15:0] fft_out_flat8;
wire [15:0] fft_out_flat9;
wire [15:0] fft_out_flat10;
wire [15:0] fft_out_flat11;
wire [15:0] fft_out_flat12;
wire [15:0] fft_out_flat13;
wire [15:0] fft_out_flat14;
wire [15:0] fft_out_flat15;
wire [15:0] fft_out_flat16;
wire [15:0] fft_out_flat17;
wire [15:0] fft_out_flat18;
wire [15:0] fft_out_flat19;
wire [15:0] fft_out_flat20;
wire [15:0] fft_out_flat21;
wire [15:0] fft_out_flat22;
wire [15:0] fft_out_flat23;
wire [15:0] fft_out_flat24;
wire [15:0] fft_out_flat25;
wire [15:0] fft_out_flat26;
wire [15:0] fft_out_flat27;
wire [15:0] fft_out_flat28;
wire [15:0] fft_out_flat29;
wire [15:0] fft_out_flat30;
wire [15:0] fft_out_flat31;
wire [15:0] fft_out_flat32;
wire [15:0] fft_out_flat33;
wire [15:0] fft_out_flat34;
wire [15:0] fft_out_flat35;
wire [15:0] fft_out_flat36;
wire [15:0] fft_out_flat37;
wire [15:0] fft_out_flat38;
wire [15:0] fft_out_flat39;
wire [15:0] fft_out_flat40;
wire [15:0] fft_out_flat41;
wire [15:0] fft_out_flat42;
wire [15:0] fft_out_flat43;
wire [15:0] fft_out_flat44;
wire [15:0] fft_out_flat45;
wire [15:0] fft_out_flat46;
wire [15:0] fft_out_flat47;
wire [15:0] fft_out_flat48;
wire [15:0] fft_out_flat49;
wire [15:0] fft_out_flat50;
wire [15:0] fft_out_flat51;
wire [15:0] fft_out_flat52;
wire [15:0] fft_out_flat53;
wire [15:0] fft_out_flat54;
wire [15:0] fft_out_flat55;
wire [15:0] fft_out_flat56;
wire [15:0] fft_out_flat57;
wire [15:0] fft_out_flat58;
wire [15:0] fft_out_flat59;
wire [15:0] fft_out_flat60;
wire [15:0] fft_out_flat61;
wire [15:0] fft_out_flat62;
wire [15:0] fft_out_flat63;

// IFFT output flat wires
wire [15:0] ifft_out_flat0;
wire [15:0] ifft_out_flat1;
wire [15:0] ifft_out_flat2;
wire [15:0] ifft_out_flat3;
wire [15:0] ifft_out_flat4;
wire [15:0] ifft_out_flat5;
wire [15:0] ifft_out_flat6;
wire [15:0] ifft_out_flat7;
wire [15:0] ifft_out_flat8;
wire [15:0] ifft_out_flat9;
wire [15:0] ifft_out_flat10;
wire [15:0] ifft_out_flat11;
wire [15:0] ifft_out_flat12;
wire [15:0] ifft_out_flat13;
wire [15:0] ifft_out_flat14;
wire [15:0] ifft_out_flat15;
wire [15:0] ifft_out_flat16;
wire [15:0] ifft_out_flat17;
wire [15:0] ifft_out_flat18;
wire [15:0] ifft_out_flat19;
wire [15:0] ifft_out_flat20;
wire [15:0] ifft_out_flat21;
wire [15:0] ifft_out_flat22;
wire [15:0] ifft_out_flat23;
wire [15:0] ifft_out_flat24;
wire [15:0] ifft_out_flat25;
wire [15:0] ifft_out_flat26;
wire [15:0] ifft_out_flat27;
wire [15:0] ifft_out_flat28;
wire [15:0] ifft_out_flat29;
wire [15:0] ifft_out_flat30;
wire [15:0] ifft_out_flat31;
wire [15:0] ifft_out_flat32;
wire [15:0] ifft_out_flat33;
wire [15:0] ifft_out_flat34;
wire [15:0] ifft_out_flat35;
wire [15:0] ifft_out_flat36;
wire [15:0] ifft_out_flat37;
wire [15:0] ifft_out_flat38;
wire [15:0] ifft_out_flat39;
wire [15:0] ifft_out_flat40;
wire [15:0] ifft_out_flat41;
wire [15:0] ifft_out_flat42;
wire [15:0] ifft_out_flat43;
wire [15:0] ifft_out_flat44;
wire [15:0] ifft_out_flat45;
wire [15:0] ifft_out_flat46;
wire [15:0] ifft_out_flat47;
wire [15:0] ifft_out_flat48;
wire [15:0] ifft_out_flat49;
wire [15:0] ifft_out_flat50;
wire [15:0] ifft_out_flat51;
wire [15:0] ifft_out_flat52;
wire [15:0] ifft_out_flat53;
wire [15:0] ifft_out_flat54;
wire [15:0] ifft_out_flat55;
wire [15:0] ifft_out_flat56;
wire [15:0] ifft_out_flat57;
wire [15:0] ifft_out_flat58;
wire [15:0] ifft_out_flat59;
wire [15:0] ifft_out_flat60;
wire [15:0] ifft_out_flat61;
wire [15:0] ifft_out_flat62;
wire [15:0] ifft_out_flat63;

// IFFT output flat wires
wire [15:0] mod_out_flat0;
wire [15:0] mod_out_flat1;
wire [15:0] mod_out_flat2;
wire [15:0] mod_out_flat3;
wire [15:0] mod_out_flat4;
wire [15:0] mod_out_flat5;
wire [15:0] mod_out_flat6;
wire [15:0] mod_out_flat7;
wire [15:0] mod_out_flat8;
wire [15:0] mod_out_flat9;
wire [15:0] mod_out_flat10;
wire [15:0] mod_out_flat11;
wire [15:0] mod_out_flat12;
wire [15:0] mod_out_flat13;
wire [15:0] mod_out_flat14;
wire [15:0] mod_out_flat15;
wire [15:0] mod_out_flat16;
wire [15:0] mod_out_flat17;
wire [15:0] mod_out_flat18;
wire [15:0] mod_out_flat19;
wire [15:0] mod_out_flat20;
wire [15:0] mod_out_flat21;
wire [15:0] mod_out_flat22;
wire [15:0] mod_out_flat23;
wire [15:0] mod_out_flat24;
wire [15:0] mod_out_flat25;
wire [15:0] mod_out_flat26;
wire [15:0] mod_out_flat27;
wire [15:0] mod_out_flat28;
wire [15:0] mod_out_flat29;
wire [15:0] mod_out_flat30;
wire [15:0] mod_out_flat31;
wire [15:0] mod_out_flat32;
wire [15:0] mod_out_flat33;
wire [15:0] mod_out_flat34;
wire [15:0] mod_out_flat35;
wire [15:0] mod_out_flat36;
wire [15:0] mod_out_flat37;
wire [15:0] mod_out_flat38;
wire [15:0] mod_out_flat39;
wire [15:0] mod_out_flat40;
wire [15:0] mod_out_flat41;
wire [15:0] mod_out_flat42;
wire [15:0] mod_out_flat43;
wire [15:0] mod_out_flat44;
wire [15:0] mod_out_flat45;
wire [15:0] mod_out_flat46;
wire [15:0] mod_out_flat47;
wire [15:0] mod_out_flat48;
wire [15:0] mod_out_flat49;
wire [15:0] mod_out_flat50;
wire [15:0] mod_out_flat51;
wire [15:0] mod_out_flat52;
wire [15:0] mod_out_flat53;
wire [15:0] mod_out_flat54;
wire [15:0] mod_out_flat55;
wire [15:0] mod_out_flat56;
wire [15:0] mod_out_flat57;
wire [15:0] mod_out_flat58;
wire [15:0] mod_out_flat59;
wire [15:0] mod_out_flat60;
wire [15:0] mod_out_flat61;
wire [15:0] mod_out_flat62;
wire [15:0] mod_out_flat63;


assign fft_out_flat0 = fft_mod_regs[0];
assign fft_out_flat1 = fft_mod_regs[1];
assign fft_out_flat2 = fft_mod_regs[2];
assign fft_out_flat3 = fft_mod_regs[3];
assign fft_out_flat4 = fft_mod_regs[4];
assign fft_out_flat5 = fft_mod_regs[5];
assign fft_out_flat6 = fft_mod_regs[6];
assign fft_out_flat7 = fft_mod_regs[7];
assign fft_out_flat8 = fft_mod_regs[8];
assign fft_out_flat9 = fft_mod_regs[9];
assign fft_out_flat10 = fft_mod_regs[10];
assign fft_out_flat11 = fft_mod_regs[11];
assign fft_out_flat12 = fft_mod_regs[12];
assign fft_out_flat13 = fft_mod_regs[13];
assign fft_out_flat14 = fft_mod_regs[14];
assign fft_out_flat15 = fft_mod_regs[15];
assign fft_out_flat16 = fft_mod_regs[16];
assign fft_out_flat17 = fft_mod_regs[17];
assign fft_out_flat18 = fft_mod_regs[18];
assign fft_out_flat19 = fft_mod_regs[19];
assign fft_out_flat20 = fft_mod_regs[20];
assign fft_out_flat21 = fft_mod_regs[21];
assign fft_out_flat22 = fft_mod_regs[22];
assign fft_out_flat23 = fft_mod_regs[23];
assign fft_out_flat24 = fft_mod_regs[24];
assign fft_out_flat25 = fft_mod_regs[25];
assign fft_out_flat26 = fft_mod_regs[26];
assign fft_out_flat27 = fft_mod_regs[27];
assign fft_out_flat28 = fft_mod_regs[28];
assign fft_out_flat29 = fft_mod_regs[29];
assign fft_out_flat30 = fft_mod_regs[30];
assign fft_out_flat31 = fft_mod_regs[31];
assign fft_out_flat32 = fft_mod_regs[32];
assign fft_out_flat33 = fft_mod_regs[33];
assign fft_out_flat34 = fft_mod_regs[34];
assign fft_out_flat35 = fft_mod_regs[35];
assign fft_out_flat36 = fft_mod_regs[36];
assign fft_out_flat37 = fft_mod_regs[37];
assign fft_out_flat38 = fft_mod_regs[38];
assign fft_out_flat39 = fft_mod_regs[39];
assign fft_out_flat40 = fft_mod_regs[40];
assign fft_out_flat41 = fft_mod_regs[41];
assign fft_out_flat42 = fft_mod_regs[42];
assign fft_out_flat43 = fft_mod_regs[43];
assign fft_out_flat44 = fft_mod_regs[44];
assign fft_out_flat45 = fft_mod_regs[45];
assign fft_out_flat46 = fft_mod_regs[46];
assign fft_out_flat47 = fft_mod_regs[47];
assign fft_out_flat48 = fft_mod_regs[48];
assign fft_out_flat49 = fft_mod_regs[49];
assign fft_out_flat50 = fft_mod_regs[50];
assign fft_out_flat51 = fft_mod_regs[51];
assign fft_out_flat52 = fft_mod_regs[52];
assign fft_out_flat53 = fft_mod_regs[53];
assign fft_out_flat54 = fft_mod_regs[54];
assign fft_out_flat55 = fft_mod_regs[55];
assign fft_out_flat56 = fft_mod_regs[56];
assign fft_out_flat57 = fft_mod_regs[57];
assign fft_out_flat58 = fft_mod_regs[58];
assign fft_out_flat59 = fft_mod_regs[59];
assign fft_out_flat60 = fft_mod_regs[60];
assign fft_out_flat61 = fft_mod_regs[61];
assign fft_out_flat62 = fft_mod_regs[62];
assign fft_out_flat63 = fft_mod_regs[63];

assign ifft_out_flat0 = ifft_out_regs[0];
assign ifft_out_flat1 = ifft_out_regs[1];
assign ifft_out_flat2 = ifft_out_regs[2];
assign ifft_out_flat3 = ifft_out_regs[3];
assign ifft_out_flat4 = ifft_out_regs[4];
assign ifft_out_flat5 = ifft_out_regs[5];
assign ifft_out_flat6 = ifft_out_regs[6];
assign ifft_out_flat7 = ifft_out_regs[7];
assign ifft_out_flat8 = ifft_out_regs[8];
assign ifft_out_flat9 = ifft_out_regs[9];
assign ifft_out_flat10 = ifft_out_regs[10];
assign ifft_out_flat11 = ifft_out_regs[11];
assign ifft_out_flat12 = ifft_out_regs[12];
assign ifft_out_flat13 = ifft_out_regs[13];
assign ifft_out_flat14 = ifft_out_regs[14];
assign ifft_out_flat15 = ifft_out_regs[15];
assign ifft_out_flat16 = ifft_out_regs[16];
assign ifft_out_flat17 = ifft_out_regs[17];
assign ifft_out_flat18 = ifft_out_regs[18];
assign ifft_out_flat19 = ifft_out_regs[19];
assign ifft_out_flat20 = ifft_out_regs[20];
assign ifft_out_flat21 = ifft_out_regs[21];
assign ifft_out_flat22 = ifft_out_regs[22];
assign ifft_out_flat23 = ifft_out_regs[23];
assign ifft_out_flat24 = ifft_out_regs[24];
assign ifft_out_flat25 = ifft_out_regs[25];
assign ifft_out_flat26 = ifft_out_regs[26];
assign ifft_out_flat27 = ifft_out_regs[27];
assign ifft_out_flat28 = ifft_out_regs[28];
assign ifft_out_flat29 = ifft_out_regs[29];
assign ifft_out_flat30 = ifft_out_regs[30];
assign ifft_out_flat31 = ifft_out_regs[31];
assign ifft_out_flat32 = ifft_out_regs[32];
assign ifft_out_flat33 = ifft_out_regs[33];
assign ifft_out_flat34 = ifft_out_regs[34];
assign ifft_out_flat35 = ifft_out_regs[35];
assign ifft_out_flat36 = ifft_out_regs[36];
assign ifft_out_flat37 = ifft_out_regs[37];
assign ifft_out_flat38 = ifft_out_regs[38];
assign ifft_out_flat39 = ifft_out_regs[39];
assign ifft_out_flat40 = ifft_out_regs[40];
assign ifft_out_flat41 = ifft_out_regs[41];
assign ifft_out_flat42 = ifft_out_regs[42];
assign ifft_out_flat43 = ifft_out_regs[43];
assign ifft_out_flat44 = ifft_out_regs[44];
assign ifft_out_flat45 = ifft_out_regs[45];
assign ifft_out_flat46 = ifft_out_regs[46];
assign ifft_out_flat47 = ifft_out_regs[47];
assign ifft_out_flat48 = ifft_out_regs[48];
assign ifft_out_flat49 = ifft_out_regs[49];
assign ifft_out_flat50 = ifft_out_regs[50];
assign ifft_out_flat51 = ifft_out_regs[51];
assign ifft_out_flat52 = ifft_out_regs[52];
assign ifft_out_flat53 = ifft_out_regs[53];
assign ifft_out_flat54 = ifft_out_regs[54];
assign ifft_out_flat55 = ifft_out_regs[55];
assign ifft_out_flat56 = ifft_out_regs[56];
assign ifft_out_flat57 = ifft_out_regs[57];
assign ifft_out_flat58 = ifft_out_regs[58];
assign ifft_out_flat59 = ifft_out_regs[59];
assign ifft_out_flat60 = ifft_out_regs[60];
assign ifft_out_flat61 = ifft_out_regs[61];
assign ifft_out_flat62 = ifft_out_regs[62];
assign ifft_out_flat63 = ifft_out_regs[63];


assign mod_out_flat0 = mod_ifft_regs[0];
assign mod_out_flat1 = mod_ifft_regs[1];
assign mod_out_flat2 = mod_ifft_regs[2];
assign mod_out_flat3 = mod_ifft_regs[3];
assign mod_out_flat4 = mod_ifft_regs[4];
assign mod_out_flat5 = mod_ifft_regs[5];
assign mod_out_flat6 = mod_ifft_regs[6];
assign mod_out_flat7 = mod_ifft_regs[7];
assign mod_out_flat8 = mod_ifft_regs[8];
assign mod_out_flat9 = mod_ifft_regs[9];
assign mod_out_flat10 = mod_ifft_regs[10];
assign mod_out_flat11 = mod_ifft_regs[11];
assign mod_out_flat12 = mod_ifft_regs[12];
assign mod_out_flat13 = mod_ifft_regs[13];
assign mod_out_flat14 = mod_ifft_regs[14];
assign mod_out_flat15 = mod_ifft_regs[15];
assign mod_out_flat16 = mod_ifft_regs[16];
assign mod_out_flat17 = mod_ifft_regs[17];
assign mod_out_flat18 = mod_ifft_regs[18];
assign mod_out_flat19 = mod_ifft_regs[19];
assign mod_out_flat20 = mod_ifft_regs[20];
assign mod_out_flat21 = mod_ifft_regs[21];
assign mod_out_flat22 = mod_ifft_regs[22];
assign mod_out_flat23 = mod_ifft_regs[23];
assign mod_out_flat24 = mod_ifft_regs[24];
assign mod_out_flat25 = mod_ifft_regs[25];
assign mod_out_flat26 = mod_ifft_regs[26];
assign mod_out_flat27 = mod_ifft_regs[27];
assign mod_out_flat28 = mod_ifft_regs[28];
assign mod_out_flat29 = mod_ifft_regs[29];
assign mod_out_flat30 = mod_ifft_regs[30];
assign mod_out_flat31 = mod_ifft_regs[31];
assign mod_out_flat32 = mod_ifft_regs[32];
assign mod_out_flat33 = mod_ifft_regs[33];
assign mod_out_flat34 = mod_ifft_regs[34];
assign mod_out_flat35 = mod_ifft_regs[35];
assign mod_out_flat36 = mod_ifft_regs[36];
assign mod_out_flat37 = mod_ifft_regs[37];
assign mod_out_flat38 = mod_ifft_regs[38];
assign mod_out_flat39 = mod_ifft_regs[39];
assign mod_out_flat40 = mod_ifft_regs[40];
assign mod_out_flat41 = mod_ifft_regs[41];
assign mod_out_flat42 = mod_ifft_regs[42];
assign mod_out_flat43 = mod_ifft_regs[43];
assign mod_out_flat44 = mod_ifft_regs[44];
assign mod_out_flat45 = mod_ifft_regs[45];
assign mod_out_flat46 = mod_ifft_regs[46];
assign mod_out_flat47 = mod_ifft_regs[47];
assign mod_out_flat48 = mod_ifft_regs[48];
assign mod_out_flat49 = mod_ifft_regs[49];
assign mod_out_flat50 = mod_ifft_regs[50];
assign mod_out_flat51 = mod_ifft_regs[51];
assign mod_out_flat52 = mod_ifft_regs[52];
assign mod_out_flat53 = mod_ifft_regs[53];
assign mod_out_flat54 = mod_ifft_regs[54];
assign mod_out_flat55 = mod_ifft_regs[55];
assign mod_out_flat56 = mod_ifft_regs[56];
assign mod_out_flat57 = mod_ifft_regs[57];
assign mod_out_flat58 = mod_ifft_regs[58];
assign mod_out_flat59 = mod_ifft_regs[59];
assign mod_out_flat60 = mod_ifft_regs[60];
assign mod_out_flat61 = mod_ifft_regs[61];
assign mod_out_flat62 = mod_ifft_regs[62];
assign mod_out_flat63 = mod_ifft_regs[63];


    // ifft opcode = 01001
    sdf_ifft #(.WIDTH(16)) U_IFFT (
      .clock        (clock),
      .reset        (fft_reset),
      .data_in_en   (ifft_in_en),
      .data_in_real (16'd0),
      .data_in_imag (ifft_in_im),
      .data_out_en  (ifft_out_en),
      .data_out_real(ifft_out_re),
      .data_out_imag() // 16'd0 will always be 0 bc imag is always 0
    );

    

    reg [5:0] ifft_data_out_count;
    always @(posedge clock or posedge fft_reset) begin
        if (fft_reset) begin
            ifft_data_out_count <= 5'd0;
        end else if (ifft_out_en) begin
            ifft_data_out_count <= ex_is_ifft ? (ifft_data_out_count + 1'b1) : ifft_data_out_count;
            ifft_out_regs [bitrev6(ifft_data_out_count)] <= ifft_out_re; // inverse bit order for output
        end
    end




    
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
    wire stall_multdiv, stall_fft, stall_ifft, stall;
    assign stall_multdiv = idex_isMultDiv_out & ~md_resultRDY;
    
    assign stall_fft = ex_is_fft & (fft_count != 8'd136);

    assign stall_ifft = ex_is_ifft & (ifft_count != 8'd138);


    assign stall = stall_multdiv | stall_fft | stall_ifft;


    wire we_exmem = ~stall;
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
    wire memwb_is_fft = memwb_instr_out[31:27] == 5'b10000;
    wire memwb_is_ifft = memwb_instr_out[31:27] == 5'b10001;
    wire memwb_is_mod = memwb_instr_out[31:27] == 5'b11000;




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
    
    assign ctrl_writeEnable = (is_storeWB | memwb_is_fft | memwb_is_ifft | memwb_is_mod) ? 1'b0 : 1'b1;
    
    
endmodule