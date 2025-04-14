module FFT_PurpleRAM (
    input clock, A_en, B_en,
    input [15:0] A_dataIn, B_dataIn,
    input [4:0] A_addr, B_addr,
    output [15:0] A_dataOut, B_dataOut
);

    wire A_en;
    wire [4:0] A_addr;
    wire [15:0] A_dataIn, A_dataOut;
    RAM #(.DATA_WIDTH(16), .ADDRESS_WIDTH(5), .DEPTH(32)) A(
        .clk(clock),
        .wEn(A_en),
        .addr(A_addr),
        .dataIn(A_dataIn),
        .dataOut(A_dataOut)
    );

    
    wire B_en;
    wire [4:0] B_addr;
    wire [15:0] B_dataIn, B_dataOut;
    RAM #(.DATA_WIDTH(16), .ADDRESS_WIDTH(5), .DEPTH(32)) B(
        .clk(clock),
        .wEn(B_en),
        .addr(B_addr),
        .dataIn(B_dataIn),
        .dataOut(B_dataOut)
    );

endmodule