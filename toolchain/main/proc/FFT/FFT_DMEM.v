module FFT_DMEM (
    input clock,
    input LoadDataWrite,
    input LoadEnable,
    input Bank0WriteEN,
    input Bank1WriteEN,
    input [15:0] Data_real_in, 
    input [15:0] Data_imag_in, 
    input RWAddrEN,
    input BankReadSelect,
    input [4:0] LoadDataAddr,
    input [4:0] ReadGAddr,
    input [4:0] ReadHAddr,
    input [4:0] WriteGAddr,
    input [4:0] WriteHAddr,
    input [15:0] Xr,
    input [15:0] Xi,
    input [15:0] Yr,
    input [15:0] Yi,
    
    output [15:0] G_real, 
    output [15:0] G_imag, 
    output [15:0] H_real, 
    output [15:0] H_imag);


    wire Bank0_A_WR, Bank0_B_WR;
    single_clock_delay #(.WIDTH(1)) Bank0_B_WR_delay (.q(Bank0_B_WR), .d(Bank0WriteEN), .clr(1'b0), .clk(~clock));
    
    delay_mux_1bitselect #(.WIDTH(1)) Bank0_A_WR_mux(
        .clock(~clock),
        .select(LoadEnable), // TODO: LoadDataWrite: what select bit do we do for this mux?
        .in0(Bank0WriteEN),
        .in1(LoadDataWrite),
        .out(Bank0_A_WR));

    wire [15:0] DataA0_r, DataA0_i, DataB_r, DataB_i;
    wire [4:0] addrA0, addrA1, addrB0, addrB1;
    wire [15:0] DataA1_r, DataA1_i;

    delay_mux_1bitselect #(.WIDTH(16)) DataA0_r_mux(
        .clock(~clock),
        .select(LoadEnable),
        .in0(Xr),
        .in1(Data_real_in),
        .out(DataA0_r));

    delay_mux_2bitselect #(.WIDTH(5)) addrA0_mux(
        .clock(~clock),
        .select({LoadEnable, RWAddrEN}),
        .in0(WriteGAddr),
        .in1(ReadGAddr),
        .in2(LoadDataAddr),
        .in3(LoadDataAddr),
        .out(addrA0));

    single_clock_delay #(.WIDTH(16)) DataB_r_delay (.q(DataB_r), .d(Yr), .clr(1'b0), .clk(clock));
    
    delay_mux_1bitselect #(.WIDTH(5)) addrB0_mux(
        .clock(~clock),
        .select(RWAddrEN),
        .in0(WriteHAddr),
        .in1(ReadHAddr),
        .out(addrB0));
    
    delay_mux_1bitselect #(.WIDTH(16)) DataA0_i_mux(
        .clock(~clock),
        .select(LoadEnable),
        .in0(Xi),
        .in1(Data_imag_in),
        .out(DataA0_i));
    
    single_clock_delay #(.WIDTH(16)) DataB_i_delay (.q(DataB_i), .d(Yi), .clr(1'b0), .clk(~clock));
    
    single_clock_delay #(.WIDTH(16)) DataA1_r_delay (.q(DataA1_r), .d(Xr), .clr(1'b0), .clk(~clock));
    
    delay_mux_2bitselect #(.WIDTH(5)) addrA1_mux(
        .clock(~clock),
        .select({RWAddrEN, LoadEnable}),
        .in0(ReadGAddr),
        .in1(LoadDataAddr),
        .in2(WriteGAddr),
        .in3(LoadDataAddr),
        .out(addrA1));
    
    delay_mux_1bitselect #(.WIDTH(5)) addrB1_mux(
        .clock(~clock),
        .select(RWAddrEN),
        .in0(ReadHAddr),
        .in1(WriteHAddr),
        .out(addrB1));

    single_clock_delay #(.WIDTH(16)) DataA1_i_delay (.q(DataA1_i), .d(Xi), .clr(1'b0), .clk(~clock));
    
    wire Bank1WriteEN_delay;
    single_clock_delay #(.WIDTH(1)) Bank1_WR_delay (.q(Bank1WriteEN_delay), .d(Bank1WriteEN), .clr(1'b0), .clk(~clock));
    
    wire [15:0] Bank0_A_r_out, Bank0_A_c_out, Bank0_B_r_out, Bank0_B_c_out, 
                Bank1_A_r_out, Bank1_A_c_out, Bank1_B_r_out, Bank1_B_c_out;

    // use prebuilt RAM modules for purple blocks

    // membank 0 and 1, each with real and imaginary component. each of the four components has a RAM module associated to it
    FFT_BankRAM bank0 (
        .clock(clock),
        .A_en(Bank0_A_WR),
        .B_en(Bank0_B_WR),
        .A_dataInR(DataA0_r),
        .A_dataInC(DataA0_i),
        .B_dataInR(DataB_r),
        .B_dataInC(DataB_i),
        .A_addr(addrA0),
        .B_addr(addrB0),
        .A_dataOutR(Bank0_A_r_out),
        .A_dataOutC(Bank0_A_c_out),
        .B_dataOutR(Bank0_B_r_out),
        .B_dataOutC(Bank0_B_c_out)
    );

    FFT_BankRAM bank1 (
        .clock(clock),
        .A_en(Bank1WriteEN_delay),
        .B_en(Bank1WriteEN_delay),
        .A_dataInR(DataA1_r),
        .A_dataInC(DataA1_i),
        .B_dataInR(DataB_r),
        .B_dataInC(DataB_i),
        .A_addr(addrA1),
        .B_addr(addrB1),
        .A_dataOutR(Bank1_A_r_out),
        .A_dataOutC(Bank1_A_c_out),
        .B_dataOutR(Bank1_B_r_out),
        .B_dataOutC(Bank1_B_c_out)
    );

    assign G_real = BankReadSelect ? Bank1_A_r_out : Bank0_A_r_out;
    assign G_imag = BankReadSelect ? Bank1_A_c_out : Bank0_A_c_out;
    assign H_real = BankReadSelect ? Bank1_B_r_out : Bank0_B_r_out;
    assign H_imag = BankReadSelect ? Bank1_B_c_out : Bank0_B_c_out;
    
endmodule