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
    BTNC,
    
    BTNU_out,
    BTND_out,
    BTNL_out,
    BTNR_out,
    BTNC_out,

    // ADC In
    adc_sample,
    adc_ready,

    // Audio controls
    sample_ready,
    audio_out
    

);

    // Control signals
    input clock, reset, BTNU, BTND, BTNL, BTNR, BTNC, adc_ready;
    input [15:0] adc_sample;

    output BTNU_out, BTND_out, BTNL_out, BTNR_out, BTNC_out;
    output reg [15:0] audio_out;
    output reg sample_ready;

    assign BTNU_out = BTNU;
    assign BTND_out = BTND;
    assign BTNL_out = BTNL;
    assign BTNR_out = BTNR;
    assign BTNC_out = BTNC;
    
    
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
        .data_operandA((adc_ready & (ifid_instr_out[26:22] == 5'd18)) ? 32'd1 : data_readRegA), // for branch, we set regA = $rd
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

    reg [15:0] fft_regs [0:63]; // holding values in between fft, modulation, and ifft

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
    always @(posedge clock or posedge fft_reset) begin
        if (fft_reset) begin
            fft_count <= 7'd0;
        end else begin
            fft_count <= ex_is_fft ? (fft_count + 1'b1) : fft_count;
        end
    end
    
    reg [7:0] ifft_count;
    always @(posedge clock or posedge fft_reset) begin
        if (fft_reset) begin
            ifft_count <= 7'd0;
        end else if (ifft_in_en) begin
            ifft_in_im <= fft_regs[ifft_count-2];
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
    integer i;
    always @(adc_ready) begin
        for (i=0; i<63; i=i+1) begin
            fft_regs[i] <= fft_regs[i+1];
        end
        fft_regs[63] <= adc_sample;
    end

    // wire [15:0] adc_data_out [0:63];
        // assign adc_data_out [0] = 16'h0000;
        // assign adc_data_out [1] = 16'h0C8B;
        // assign adc_data_out [2] = 16'h18F8;
        // assign adc_data_out [3] = 16'h2527;
        // assign adc_data_out [4] = 16'h30FB;
        // assign adc_data_out [5] = 16'h3C56;
        // assign adc_data_out [6] = 16'h471C;
        // assign adc_data_out [7] = 16'h5133;
        // assign adc_data_out [8] = 16'h5A81;
        // assign adc_data_out [9] = 16'h62F1;
        // assign adc_data_out [10] = 16'h6A6C;
        // assign adc_data_out [11] = 16'h70E1;
        // assign adc_data_out [12] = 16'h7640;
        // assign adc_data_out [13] = 16'h7A7C;
        // assign adc_data_out [14] = 16'h7D89;
        // assign adc_data_out [15] = 16'h7F61;
        // assign adc_data_out [16] = 16'h7FFF;
        // assign adc_data_out [17] = 16'h7F61;
        // assign adc_data_out [18] = 16'h7D89;
        // assign adc_data_out [19] = 16'h7A7C;
        // assign adc_data_out [20] = 16'h7640;
        // assign adc_data_out [21] = 16'h70E1;
        // assign adc_data_out [22] = 16'h6A6C;
        // assign adc_data_out [23] = 16'h62F1;
        // assign adc_data_out [24] = 16'h5A81;
        // assign adc_data_out [25] = 16'h5133;
        // assign adc_data_out [26] = 16'h471C;
        // assign adc_data_out [27] = 16'h3C56;
        // assign adc_data_out [28] = 16'h30FB;
        // assign adc_data_out [29] = 16'h2527;
        // assign adc_data_out [30] = 16'h18F8;
        // assign adc_data_out [31] = 16'h0C8B;
        // assign adc_data_out [32] = 16'h0000;
        // assign adc_data_out [33] = 16'hF375;
        // assign adc_data_out [34] = 16'hE708;
        // assign adc_data_out [35] = 16'hDAD9;
        // assign adc_data_out [36] = 16'hCF05;
        // assign adc_data_out [37] = 16'hC3AA;
        // assign adc_data_out [38] = 16'hB8E4;
        // assign adc_data_out [39] = 16'hAECD;
        // assign adc_data_out [40] = 16'hA57F;
        // assign adc_data_out [41] = 16'h9D0F;
        // assign adc_data_out [42] = 16'h9594;
        // assign adc_data_out [43] = 16'h8F1F;
        // assign adc_data_out [44] = 16'h89C0;
        // assign adc_data_out [45] = 16'h8584;
        // assign adc_data_out [46] = 16'h8277;
        // assign adc_data_out [47] = 16'h809F;
        // assign adc_data_out [48] = 16'h8001;
        // assign adc_data_out [49] = 16'h809F;
        // assign adc_data_out [50] = 16'h8277;
        // assign adc_data_out [51] = 16'h8584;
        // assign adc_data_out [52] = 16'h89C0;
        // assign adc_data_out [53] = 16'h8F1F;
        // assign adc_data_out [54] = 16'h9594;
        // assign adc_data_out [55] = 16'h9D0F;
        // assign adc_data_out [56] = 16'hA57F;
        // assign adc_data_out [57] = 16'hAECD;
        // assign adc_data_out [58] = 16'hB8E4;
        // assign adc_data_out [59] = 16'hC3AA;
        // assign adc_data_out [60] = 16'hCF05;
        // assign adc_data_out [61] = 16'hDAD9;
        // assign adc_data_out [62] = 16'hE708;
        // assign adc_data_out [63] = 16'hF375;


    //assign fft_in_re = adc_data_out[fft_count-1];


    sdf_fft  #(.WIDTH(16)) U_FFT  (
      .clock        (clock),
      .reset        (fft_reset),
      .data_in_en   (fft_in_en),
      .data_in_real (fft_regs[63]),
      .data_in_imag (16'd0),
      .data_out_en  (fft_out_en),
      .data_out_real(fft_out_re),
      .data_out_imag(fft_out_im) // 16'd0 will always be 0 bc imag is always 0
    );

   function integer bitrev6;       // 6‑bit bit‑reverse
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
            fft_regs [bitrev6(fft_data_out_count)] <= fft_out_im; // inverse bit order for output
        end
    end


    wire ex_is_mod = (idex_instr_out[31:27] == 5'b11000);
    wire [5:0] ex_mod_index = (idex_instr_out[21:17]-1)<<2;
    wire [15:0] ex_mod_operandA = ex_operandA[15:0];
    wire [15:0] mod_out1, mod_out2, mod_out3, mod_out4;
    wallace_16 mod_mult1(
        .a(ex_mod_operandA),
        .b(fft_regs[ex_mod_index]),
        .product(),
        .product_hi(mod_out1),
        .product_lo(),
        .ovf()
    );  
    wallace_16 mod_mult2(
        .a(ex_mod_operandA),
        .b(fft_regs[ex_mod_index+1]),
        .product(),
        .product_hi(mod_out2),
        .product_lo(),
        .ovf()
    );      
    wallace_16 mod_mult3(
        .a(ex_mod_operandA),
        .b(fft_regs[ex_mod_index+2]),
        .product(),
        .product_hi(mod_out3),
        .product_lo(),
        .ovf()
    );      
    wallace_16 mod_mult4(
        .a(ex_mod_operandA),
        .b(fft_regs[ex_mod_index+3]),
        .product(),
        .product_hi(mod_out4),
        .product_lo(),
        .ovf()
    );  

    always @(negedge clock) begin
        if (ex_is_mod) begin
            fft_regs[ex_mod_index] <= mod_out1 <<< 1;
            fft_regs[ex_mod_index+1] <= mod_out2 <<< 1;
            fft_regs[ex_mod_index+2] <= mod_out3 <<< 1;
            fft_regs[ex_mod_index+3] <= mod_out4 <<< 1;
        end 
    end
    
    






    wire [15:0] fft_out_0 = fft_regs[0];
    wire [15:0] fft_out_1 = fft_regs[1];
    wire [15:0] fft_out_2 = fft_regs[2];
    wire [15:0] fft_out_3 = fft_regs[3];
    wire [15:0] fft_out_4 = fft_regs[4];
    wire [15:0] fft_out_5 = fft_regs[5];
    wire [15:0] fft_out_6 = fft_regs[6];
    wire [15:0] fft_out_7 = fft_regs[7];
    wire [15:0] fft_out_8 = fft_regs[8];
    wire [15:0] fft_out_9 = fft_regs[9];
    wire [15:0] fft_out_10 = fft_regs[10];
    wire [15:0] fft_out_11 = fft_regs[11];
    wire [15:0] fft_out_12 = fft_regs[12];
    wire [15:0] fft_out_13 = fft_regs[13];
    wire [15:0] fft_out_14 = fft_regs[14];
    wire [15:0] fft_out_15 = fft_regs[15];
    wire [15:0] fft_out_16 = fft_regs[16];
    wire [15:0] fft_out_17 = fft_regs[17];
    wire [15:0] fft_out_18 = fft_regs[18];
    wire [15:0] fft_out_19 = fft_regs[19];
    wire [15:0] fft_out_20 = fft_regs[20];
    wire [15:0] fft_out_21 = fft_regs[21];
    wire [15:0] fft_out_22 = fft_regs[22];
    wire [15:0] fft_out_23 = fft_regs[23];
    wire [15:0] fft_out_24 = fft_regs[24];
    wire [15:0] fft_out_25 = fft_regs[25];
    wire [15:0] fft_out_26 = fft_regs[26];
    wire [15:0] fft_out_27 = fft_regs[27];
    wire [15:0] fft_out_28 = fft_regs[28];
    wire [15:0] fft_out_29 = fft_regs[29];
    wire [15:0] fft_out_30 = fft_regs[30];
    wire [15:0] fft_out_31 = fft_regs[31];
    wire [15:0] fft_out_32 = fft_regs[32];
    wire [15:0] fft_out_33 = fft_regs[33];
    wire [15:0] fft_out_34 = fft_regs[34];
    wire [15:0] fft_out_35 = fft_regs[35];
    wire [15:0] fft_out_36 = fft_regs[36];
    wire [15:0] fft_out_37 = fft_regs[37];
    wire [15:0] fft_out_38 = fft_regs[38];
    wire [15:0] fft_out_39 = fft_regs[39];
    wire [15:0] fft_out_40 = fft_regs[40];
    wire [15:0] fft_out_41 = fft_regs[41];
    wire [15:0] fft_out_42 = fft_regs[42];
    wire [15:0] fft_out_43 = fft_regs[43];
    wire [15:0] fft_out_44 = fft_regs[44];
    wire [15:0] fft_out_45 = fft_regs[45];
    wire [15:0] fft_out_46 = fft_regs[46];
    wire [15:0] fft_out_47 = fft_regs[47];
    wire [15:0] fft_out_48 = fft_regs[48];
    wire [15:0] fft_out_49 = fft_regs[49];
    wire [15:0] fft_out_50 = fft_regs[50];
    wire [15:0] fft_out_51 = fft_regs[51];
    wire [15:0] fft_out_52 = fft_regs[52];
    wire [15:0] fft_out_53 = fft_regs[53];
    wire [15:0] fft_out_54 = fft_regs[54];
    wire [15:0] fft_out_55 = fft_regs[55];
    wire [15:0] fft_out_56 = fft_regs[56];
    wire [15:0] fft_out_57 = fft_regs[57];
    wire [15:0] fft_out_58 = fft_regs[58];
    wire [15:0] fft_out_59 = fft_regs[59];
    wire [15:0] fft_out_60 = fft_regs[60];
    wire [15:0] fft_out_61 = fft_regs[61];
    wire [15:0] fft_out_62 = fft_regs[62];
    wire [15:0] fft_out_63 = fft_regs[63];



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
    always @(posedge clock) begin
        if (fft_reset) begin
            ifft_data_out_count <= 5'd0;
        end
        if (ifft_out_en) begin
            ifft_data_out_count <= ex_is_ifft ? (ifft_data_out_count + 1'b1) : ifft_data_out_count;
            fft_regs [bitrev6(ifft_data_out_count)] <= ifft_out_re; // inverse bit order for output
        end  
        // audio signals for output / take in sample       
        if (idex_instr_out[26:22] == 5'b10011) begin
            sample_ready <= 1'b1;  
            audio_out <= fft_regs[63];
        end else begin
            sample_ready <= 1'b0;  
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