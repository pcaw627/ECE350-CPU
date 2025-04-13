`timescale 1 ns / 100 ps
module AGU_tb;

reg clock;
reg start_FFT;

wire [4:0] MemA_address;
wire [4:0] MemB_address;
wire [3:0] twiddle_address;
wire mem_write;
wire FFT_done;

AGU dut(
    .clock(clock),
    .start_FFT(start_FFT),
    .MemA_address(MemA_address),
    .MemB_address(MemB_address),
    .twiddle_address(twiddle_address),
    .mem_write(mem_write),
    .FFT_done(FFT_done)
);

// Clock generation
always begin
    #5 clock = ~clock;  // Toggle clock every 5 time units
end


initial begin
    clock = 0;
    start_FFT = 0;

    #50
    start_FFT = 1;
    #25
    start_FFT = 0;


    // Display header for the test
    $display("Time \t clock \t start_FFT \t MemA_address \t MemB_address \t twiddle_address \t mem_write \t FFT_done");
    $monitor("%0t\t%b\t%b\t%d\t%d\t%d\t%b\t%b", $time, clock, start_FFT, MemA_address, MemB_address, twiddle_address, mem_write, FFT_done);

    // let him cook
    #4000
    // End of test
    $finish;

end


// output wavefandm
initial begin
    // output file name
    $dumpfile("AGU.vcd");
    $dumpvars(0, AGU_tb);
end


endmodule