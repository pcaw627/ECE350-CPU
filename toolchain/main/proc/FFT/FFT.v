module FFT(
    input clock,
    input start_FFT,
    input [4:0] LoadDataAddr,
    input [15:0] data_real_in,
    input [15:0] data_imag_in,
    input LoadDataWrite, // TODO: LoadDataWrite: what select bit do we do for this mux?
    input ACLR,

    output FFT_done,
    output [15:0] G_real_out, 
    output [15:0] G_imag_out, 
    output [15:0] H_real_out,
    output [15:0] H_imag_out
);

// assign G_real_out = G_real;
// assign G_imag_out = G_imag;
// assign H_real_out = H_real;
// assign H_imag_out = H_imag;

wire FFT_done_internal;
assign FFT_done = FFT_done_internal;

wire Bank0WriteEN, Bank1WriteEN, MemBankReadSelect;

wire [3:0] twiddle_address;
wire [4:0] MemA_address, MemB_address;
wire mem_write;
wire [2:0] level;

// get outputs from AGU
AGU fft_AGU(
    .start_FFT(start_FFT),
    .clock(clock),
    .MemA_address(MemA_address),
    .MemB_address(MemB_address),
    .twiddle_address(twiddle_address),
    .mem_write(mem_write),
    .FFT_done(FFT_done_internal),
    .level(level));

// use LUT to convert twiddle address to twiddle factor. 
reg [15:0] twiddle_real [0:15];
reg [15:0] twiddle_imag [0:15];
wire [15:0] twiddlefactor_real, twiddlefactor_imag;
wire [15:0] twiddlefactor_real_6delay, twiddlefactor_imag_6delay;

// real values lookup table
initial begin
    twiddle_real[0]  = 16'h7fff;
    twiddle_real[1]  = 16'h7d89;
    twiddle_real[2]  = 16'h7641;
    twiddle_real[3]  = 16'h6a6d;
    twiddle_real[4]  = 16'h5a82;
    twiddle_real[5]  = 16'h471c;
    twiddle_real[6]  = 16'h30fb;
    twiddle_real[7]  = 16'h18f9;
    twiddle_real[8]  = 16'h0000;
    twiddle_real[9]  = 16'he707;
    twiddle_real[10] = 16'hcf05;
    twiddle_real[11] = 16'hb8e4;
    twiddle_real[12] = 16'ha57e;
    twiddle_real[13] = 16'h9593;
    twiddle_real[14] = 16'h89bf;
    twiddle_real[15] = 16'h8277;
end

// imaginary values lookup table
initial begin
    twiddle_imag[0]  = 16'h0000;
    twiddle_imag[1]  = 16'h18f9;  // discrepancy between waveform and table
    twiddle_imag[2]  = 16'h30fb;
    twiddle_imag[3]  = 16'h471c;
    twiddle_imag[4]  = 16'h5a82;
    twiddle_imag[5]  = 16'h6a6d;
    twiddle_imag[6]  = 16'h7641;
    twiddle_imag[7]  = 16'h7d89;
    twiddle_imag[8]  = 16'h7fff;
    twiddle_imag[9]  = 16'h7d89;
    twiddle_imag[10] = 16'h7641;
    twiddle_imag[11] = 16'h6a6d;
    twiddle_imag[12] = 16'h5a82;
    twiddle_imag[13] = 16'h471c;
    twiddle_imag[14] = 16'h30fb;
    twiddle_imag[15] = 16'h18f9;
end


assign twiddlefactor_real = twiddle_real[twiddle_address];
assign twiddlefactor_imag = twiddle_imag[twiddle_address];
wire [15:0] G_real, G_imag, H_real, H_imag, Xr, Xi, Yr, Yi;

multi_clock_delay #(.WIDTH(16), .CYCLES(6)) mcd_tw_real_6delay(
    .q(twiddlefactor_real_6delay),
    .d(twiddlefactor_real),
    .clr(ACLR), // TODO: confirm that this clear should be ACLR
    .clk(~clock)
);

multi_clock_delay #(.WIDTH(16), .CYCLES(6)) mcd_tw_imag_6delay(
    .q(twiddlefactor_imag_6delay),
    .d(twiddlefactor_imag),
    .clr(ACLR), // TODO: confirm that this clear should be ACLR
    .clk(~clock)
);





// manipulate memwrite control signal & addresses from AGU before 
// sending them to DMEM (top circuits page 19)

wire memwrite_7delay, memwrite_8delay, memwrite_7delay_dff_out, memwrite_tff_out;

multi_clock_delay #(.WIDTH(1), .CYCLES(7)) scd_memwrite_7delay(
    .q(memwrite_7delay),
    .d(mem_write),
    .clr(ACLR), // TODO: confirm that this clear should be ACLR
    .clk(clock)
);

multi_clock_delay #(.WIDTH(1), .CYCLES(8)) scd_memwrite_8delay(
    .q(memwrite_8delay),
    .d(mem_write),
    .clr(ACLR),
    .clk(clock)
);

dffe_ref memwrite_7delay_dff(
    .q(memwrite_7delay_dff_out),
    .d(memwrite_7delay),
    .clr(ACLR), // maybe change this back to 1'b0
    .clk(clock),
    .en(1'b1)
);

wire memwrite_7delay_and_out = ~memwrite_7delay && memwrite_7delay_dff_out;

tff memwrite_tff(.q(memwrite_tff_out), .t(memwrite_7delay_and_out), 
    .clr(ACLR), // TODO: confirm that this clear should be ACLR
    .clk(clock)
);

assign MemBankReadSelect = memwrite_tff_out;
assign Bank0WriteEN = memwrite_8delay && memwrite_tff_out;
assign Bank1WriteEN = memwrite_8delay && ~memwrite_tff_out;


// then input to BFU
BFU fft_BFU (
    .wreal_in(twiddlefactor_real_6delay), .wcomplex_in(twiddlefactor_imag_6delay), 
    .Areal_in(G_real), .Acomplex_in(G_imag), 
    .Breal_in(H_real), .Bcomplex_in(H_imag), 
    .Aprime_complex_out(Xi), .Bprime_complex_out(Yi), .Aprime_real_out(Xr), .Bprime_real_out(Yr)
);


// delay X and Y before going into DMEM
// put dflip flops here to delay signal
wire [15:0] Xr_del, Xi_del, Yr_del, Yi_del;
multi_clock_delay #(.WIDTH(16), .CYCLES(5)) dmem_input_Xi_delay (.q(Xi_del), .d(Xi), .clr(ACLR), .clk(clock));
multi_clock_delay #(.WIDTH(16), .CYCLES(5)) dmem_input_Xr_delay (.q(Xr_del), .d(Xr), .clr(ACLR), .clk(clock));
multi_clock_delay #(.WIDTH(16), .CYCLES(5)) dmem_input_Yi_delay (.q(Yi_del), .d(Yi), .clr(ACLR), .clk(clock));
multi_clock_delay #(.WIDTH(16), .CYCLES(5)) dmem_input_Yr_delay (.q(Yr_del), .d(Yr), .clr(ACLR), .clk(clock));

assign G_real_out = Xr; // FFT_done_internal ? Xr : 16'd0;
assign G_imag_out = Xi; // FFT_done_internal ? Xi : 16'd0;
assign H_real_out = Yr; // FFT_done_internal ? Yr : 16'd0;
assign H_imag_out = Yi; // FFT_done_internal ? Yi : 16'd0;

// WHY are there 8 16bit inputs on FFT diagram on p19, but just 6 16bit inputs in dmem diagram on p18?
// maybe add undelayed Xi Xr here...
// because the diagram is redundant


wire LoadEnable = LoadDataWrite;// && ~FFT_done_internal; // TODO: add additional logic that makes sure we're not writing concurrently

wire [4:0] LoadDataAddr_reversed;
assign LoadDataAddr_reversed = {LoadDataAddr[0], LoadDataAddr[1], LoadDataAddr[2], LoadDataAddr[3], LoadDataAddr[4]};

wire [4:0] MemA_address_9delay, MemB_address_9delay;
wire memwrite_9delay; // to determine RWAddrEN(); this signal determines when we switch between reading and loading addresses into DMEM

multi_clock_delay #(.WIDTH(5), .CYCLES(8)) mcd_memAaddr_9delay(
    .q(MemA_address_9delay),
    .d(MemA_address),
    .clr(1'b0), // maybe add ACLR back
    .clk(clock)
);

multi_clock_delay #(.WIDTH(5), .CYCLES(8)) mcd_memBaddr_9delay(
    .q(MemB_address_9delay),
    .d(MemB_address),
    .clr(1'b0), // maybe add ACLR back
    .clk(clock)
);

multi_clock_delay #(.WIDTH(1), .CYCLES(9)) mcd_memwrite_9delay(
    .q(memwrite_9delay),
    .d(mem_write),
    .clr(1'b0), // maybe add ACLR back
    .clk(clock)
);

wire level_parity = level[0];
wire level_parity_delayed;

multi_clock_delay #(.WIDTH(1), .CYCLES(9)) mcd_parity_9delay(
    .q(level_parity_delayed),
    .d(level_parity),
    .clr(1'b0), // maybe add ACLR back
    .clk(clock)
);

FFT_DMEM fft_data_memory (
    // inputs
    .clock(clock),
    .LoadDataWrite(LoadDataWrite),
    .LoadEnable(LoadEnable),
    .Bank0WriteEN(Bank0WriteEN),
    .Bank1WriteEN(Bank1WriteEN),
    .Data_real_in(data_real_in), // [15:0] 
    .Data_imag_in(data_imag_in),  // [15:0] 
    .RWAddrEN(~level_parity_delayed),
    .BankReadSelect(MemBankReadSelect),
    .LoadDataAddr(LoadDataAddr_reversed), // [4:0]    // NOTE: WHY is there both LoadDataAddr_reversed and LoadDataAddr going into the DMEM module on p19?
    .ReadGAddr(MemA_address), // [4:0]
    .ReadHAddr(MemB_address), // [4:0]
    .WriteGAddr(MemA_address_9delay), // [4:0]
    .WriteHAddr(MemB_address_9delay), // [4:0]
    .Xr(Xr_del), // [15:0] 
    .Xi(Xi_del), // [15:0] 
    .Yr(Yr_del), // [15:0] 
    .Yi(Yi_del), // [15:0] 
    // .Xr(Xr), // [15:0] 
    // .Xi(Xi), // [15:0] 
    // .Yr(Yr), // [15:0] 
    // .Yi(Yi), // [15:0] // delay is redundant in diagram on p19. already in dmem diagram p18. 
    
    // outputs
    .G_real(G_real), // [15:0] 
    .G_imag(G_imag), // [15:0] 
    .H_real(H_real), // [15:0]  
    .H_imag(H_imag) // [15:0] 
);




endmodule