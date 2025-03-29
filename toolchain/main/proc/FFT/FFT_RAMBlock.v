module FFT_RAMBlock (
    input LoadDataWrite,
    input LoadEnable,
    input Bank0WriteEN,
    input Bank1WriteEN,
    input [15:0] Data_real_in, 
    input [15:0] Data_imag_in, 
    input RWAddrEN,
    input BankReadEnable, 
    input [4:0] LoadDataAddr,
    input [4:0] ReadGAddr,
    input [4:0] ReadHAddr,
    input [4:0] WriteGAddr
    input [4:0] WriteHAddr,
    input [15:0] Xr,
    input [15:0] Xi,
    input [15:0] Yr,
    input [15:0] Yi,
    
    // check bit widths for these...
    output [15:0] G_real, 
    output [15:0] G_imag, 
    output [15:0] H_real, 
    output [15:0] H_imag);


    wire [15:0] DataA_r, DataA_c, DataB_r, DataB0_c;

    assign DataA_r = LoadEnable ? Xr : Data_real_in; // Load Enable is not specified
    assign DataA_c = LoadEnable ? Xi : Data_imag_in;

    wire [4:0] addrA0;
    assign addrA0 = LoadEnable ? WriteGAddr : (RWAddrEN ? ReadGAddr : LoadDataAddr);
    assign addrB0 = RWAddrEN ? WriteHAddr : ReadHAddr;

    assign DataA0_c = LoadEnable ? Xi : Data_imag_in;

    wire [15:0] Bank0_A_r_out, Bank0_A_c_out, Bank0_B_r_out, Bank0_B_c_out, 
                Bank1_A_r_out, Bank1_A_c_out, Bank1_B_r_out, Bank1_B_c_out;

    // use prebuilt RAM modules for purple blocks

    // membank 0 and 1, each with real and imaginary component. each of the four components has a RAM module associated to it
    FFT_BankRAM bank0 (
        .clock(clock),
        .A_en(Bank0WriteEN), // wtf is up with loadwriteenable
        .B_en(Bank0WriteEN),
        .A_dataInR(DataA_r),
        .A_dataInC(DataA_c),
        .B_dataInR(Yr)
        .B_dataInC(Yi),
        .A_addr(addrA0),
        .B_addr(addrB0),
        .A_dataOutR(Bank0_A_r_out),
        .A_dataOutC(Bank0_A_c_out),
        .B_dataOutR(Bank0_B_r_out),
        .B_dataOutC(Bank0_B_c_out)
    );

    assign DataB0_c

    FFT_BankRAM bank1 (
        .clock(clock),
        .A_en(Bank1WriteEN), // wtf is up with loadwriteenable
        .B_en(Bank1WriteEN),
        .A_dataInR(DataB_r),
        .A_dataInC(DataB_c),
        .B_dataInR(Yr)
        .B_dataInC(Yi),
        .A_addr(addrA1),
        .B_addr(addrB1),
        .A_dataOutR(Bank1_A_r_out),
        .A_dataOutC(Bank1_A_c_out),
        .B_dataOutR(Bank1_B_r_out),
        .B_dataOutC(Bank1_B_c_out)
    );

    


endmodule