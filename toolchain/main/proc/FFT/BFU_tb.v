`timescale 1 ns / 100 ps
module BFU_tb;

wire [4:0] MemA_address;
wire [4:0] MemB_address;
wire [3:0] twiddle_address;
wire mem_write;
wire FFT_done;

wire [15:0] Aprime_complex_out, Bprime_complex_out, Aprime_real_out, Bprime_real_out;
reg [15:0] wreal_in, wcomplex_in, Areal_in, Breal_in, Acomplex_in, Bcomplex_in;

BFU dut(
    .wreal_in(wreal_in), .wcomplex_in(wcomplex_in), 
    .Breal_in(Breal_in), .Bcomplex_in(Bcomplex_in), 
    .Areal_in(Areal_in), .Acomplex_in(Acomplex_in), 
    .Aprime_complex_out(Aprime_complex_out), .Bprime_complex_out(Bprime_complex_out), 
    .Aprime_real_out(Aprime_real_out), .Bprime_real_out(Bprime_real_out)
);


initial begin
    #50
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h03ff;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h03ff;
    Bcomplex_in = 16'h0000;


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Level 1 Values

    #25
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h03ff;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h03ff;
    Bcomplex_in = 16'h0000;

    #25
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h03ff;
    Acomplex_in = 16'h0000;
    Breal_in = 16'hfc01;
    Bcomplex_in = 16'h0000;

    #25
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h03ff;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h03ff;
    Bcomplex_in = 16'h0000;

    #25
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h0000;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h07fe;
    Bcomplex_in = 16'h0000;

    #25
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h0000;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h0000;
    Bcomplex_in = 16'h0000;
    
    #25
    wreal_in = 16'hx;
    wcomplex_in = 16'hx;
    Areal_in = 16'hx;
    Acomplex_in = 16'hx;
    Breal_in = 16'hx;
    Bcomplex_in = 16'hx;

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Level 2 Values

    #100
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h0000;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h0000;
    Bcomplex_in = 16'h0000;

    #25
    wreal_in = 16'h0000;
    wcomplex_in = 16'h7fff;
    Areal_in = 16'h07fe;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h07fe;
    Bcomplex_in = 16'h0000;

    #25
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h0000;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h0000;
    Bcomplex_in = 16'h0000;

    #25
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h07fe;
    Acomplex_in = 16'h07fd;
    Breal_in = 16'h07fe;
    Bcomplex_in = 16'hf803;

    #25
    wreal_in = 16'h7fff;
    wcomplex_in = 16'h0000;
    Areal_in = 16'h0000;
    Acomplex_in = 16'h0000;
    Breal_in = 16'h0000;
    Bcomplex_in = 16'h0000;



    // Display header for the test
    $display("Time \t Aprime_complex_out \t Bprime_complex_out \t Aprime_real_out \t Bprime_real_out");
    $monitor("%0t\t%h\t%h\t%h\t%h", $time, Aprime_complex_out, Bprime_complex_out, Aprime_real_out, Bprime_real_out);

    // let him cook
    #4000
    // End of test
    $finish;

end


// output wavefandm
initial begin
    // output file name
    $dumpfile("BFU.vcd");
    $dumpvars(0, BFU_tb);
end


endmodule