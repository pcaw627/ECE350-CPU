module FFT_BankRAM (
    input A_en, B_en, clock,
    input [15:0] A_dataInR, A_dataInC, B_dataInR, B_dataInC,
    input [4:0] A_addr, B_addr,
    output [15:0] A_dataOutR, A_dataOutC, B_dataOutR, B_dataOutC
);

    FFT_PurpleRAM realRAM(
        .clock(clock),
        .A_en(A_en),
        .B_en(B_en),
        .A_dataIn(A_dataInR),
        .B_dataIn(B_dataInR),
        .A_addr(A_addr),
        .B_addr(B_addr),
        .A_dataOut(A_dataOutR),
        .B_dataOut(B_dataOutR)
    );

    FFT_PurpleRAM complexRAM(
        .clock(clock),
        .A_en(A_en),
        .B_en(B_en),
        .A_dataIn(A_dataInC),
        .B_dataIn(B_dataInC),
        .A_addr(A_addr),
        .B_addr(B_addr),
        .A_dataOut(A_dataOutC),
        .B_dataOut(B_dataOutC)
    );


endmodule