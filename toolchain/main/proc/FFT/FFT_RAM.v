module FFT_RAM (
    input LoadDataWrite,
    input Bank0WriteEN,
    input Bank1WriteEN,
    input [15:0] Data_real_in, 
    input [15:0] Data_imag_in, 
    input RWAddrEN,
    input BankReadEnable, 
    input [4:0] LoadDataAddr,
    input [4:0] ReadAddr,
    input [4:0] WriteAddr,
    input [15:0] Xr,
    input [15:0] Xi,
    input [15:0] Yr,
    input [15:0] Yi,
    
    // check bit widths for these...
    output [15:0] G_real, 
    output [15:0] G_imag, 
    output [15:0] H_real, 
    output [15:0] H_imag);

    // use prebuilt RAM modules for purple blocks

    // membank 0 and 1, each with real and imaginary component. each of the four components has a RAM module associated to it

endmodule