`timescale 1 ns / 100 ps
module FFT_tb;

    reg clock, start_FFT, ACLR, LoadDataWrite;
    reg [4:0] LoadDataAddr;
    reg [15:0] data_real_in, data_imag_in;

    wire FFT_done;
    wire [15:0] G_real_out, G_imag_out, H_real_out, H_imag_out;

    FFT dut(
        .clock(clock),
        .start_FFT(start_FFT),
        .LoadDataAddr(LoadDataAddr),
        .data_real_in(data_real_in),
        .data_imag_in(data_imag_in),
        .LoadDataWrite(LoadDataWrite),
        .ACLR(ACLR),

        .FFT_done(FFT_done),
        .G_real_out(G_real_out), 
        .G_imag_out(G_imag_out), 
        .H_real_out(H_real_out),
        .H_imag_out(H_imag_out)
    );

    reg [63:0] FFT_out_real [0:31];
    reg [63:0] FFT_out_imag [0:31];

    // real values lookup table
    initial begin
        FFT_out_real[0]  = 64'h0000;
        FFT_out_real[1]  = 64'h0800;
        FFT_out_real[2]  = 64'h0000;
        FFT_out_real[3]  = 64'h07fd;
        FFT_out_real[4]  = 64'h0000;
        FFT_out_real[5]  = 64'h07fc;
        FFT_out_real[6]  = 64'h0000;
        FFT_out_real[7]  = 64'h07fc;
        FFT_out_real[8]  = 64'h0000;
        FFT_out_real[9]  = 64'h07fd;
        FFT_out_real[10] = 64'h0000;
        FFT_out_real[11] = 64'h07fc;
        FFT_out_real[12] = 64'h0000;
        FFT_out_real[13] = 64'h07fd;
        FFT_out_real[14] = 64'h0000;
        FFT_out_real[15] = 64'h07fd;
        FFT_out_real[16] = 64'h0000;
        FFT_out_real[17] = 64'h07fe;
        FFT_out_real[18] = 64'h0000;
        FFT_out_real[19] = 64'h07fd;
        FFT_out_real[20] = 64'h0000;
        FFT_out_real[21] = 64'h07fe;
        FFT_out_real[22] = 64'h0000;
        FFT_out_real[23] = 64'h07fe;
        FFT_out_real[24] = 64'h0000;
        FFT_out_real[25] = 64'h07fd;
        FFT_out_real[26] = 64'h0000;
        FFT_out_real[27] = 64'h07fe;
        FFT_out_real[28] = 64'h0000;
        FFT_out_real[29] = 64'h0801;
        FFT_out_real[30] = 64'h0000;
        FFT_out_real[31] = 64'h0805;
    end

    // imaginary values lookup table
    initial begin
        FFT_out_imag[0]  = 64'h0000;
        FFT_out_imag[1]  = 64'h511b;
        FFT_out_imag[2]  = 64'h0000;
        FFT_out_imag[3]  = 64'h1a54;
        FFT_out_imag[4]  = 64'h0000;
        FFT_out_imag[5]  = 64'h0ef2;
        FFT_out_imag[6]  = 64'h0000;
        FFT_out_imag[7]  = 64'h09bc;
        FFT_out_imag[8]  = 64'h0000;
        FFT_out_imag[9]  = 64'h068e;
        FFT_out_imag[10] = 64'h0000;
        FFT_out_imag[11] = 64'h0445;
        FFT_out_imag[12] = 64'h0000;
        FFT_out_imag[13] = 64'h026d;
        FFT_out_imag[14] = 64'h0000;
        FFT_out_imag[15] = 64'h00c9;
        FFT_out_imag[16] = 64'h0000;
        FFT_out_imag[17] = 64'hff37;
        FFT_out_imag[18] = 64'h0000;
        FFT_out_imag[19] = 64'hfd94;
        FFT_out_imag[20] = 64'h0000;
        FFT_out_imag[21] = 64'hfbbc;
        FFT_out_imag[22] = 64'h0000;
        FFT_out_imag[23] = 64'hf972;
        FFT_out_imag[24] = 64'h0000;
        FFT_out_imag[25] = 64'hf644;
        FFT_out_imag[26] = 64'h0000;
        FFT_out_imag[27] = 64'hf10f;
        FFT_out_imag[28] = 64'h0000;
        FFT_out_imag[29] = 64'he5a9;
        FFT_out_imag[30] = 64'h0000;
        FFT_out_imag[31] = 64'haee5;
    end

    
    always begin
        #10 clock = ~clock;
    end

    initial begin
        #1
        clock = 0;
        start_FFT = 0;
        ACLR = 1;
        LoadDataWrite = 1;
        LoadDataAddr = 5'b00000;
        data_real_in = 16'h0000;
        data_imag_in = 16'h0000;

        
        // init
            #99
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h00;

        // load positive data signal (16'h03ff == 1)
            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h01;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h02;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h03;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h04;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h05;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h06;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h07;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h08;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h09;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h0a;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h0b;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h0c;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h0d;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h0e;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'h03ff;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h0f;


        // load negative data signal (16'hfc01 == -1)
            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h10;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h11;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h12;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h13;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h14;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h15;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h16;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h17;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h18;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h19;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h1a;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h1b;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h1c;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h1d;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h1e;

            #20
            LoadDataWrite = 1;
            data_imag_in = 16'h0000;
            data_real_in = 16'hfc01;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h1f;


        // finished data loading
            #20
            LoadDataWrite = 0;
            data_imag_in = 16'h0000;
            data_real_in = 16'h0000;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h00;

            #100
            LoadDataWrite = 0;
            data_imag_in = 16'h0000;
            data_real_in = 16'h0000;
            ACLR = 1;
            start_FFT = 0;
            LoadDataAddr = 5'h00;

            #50
            LoadDataWrite = 0;
            data_imag_in = 16'h0000;
            data_real_in = 16'h0000;
            ACLR = 0;
            start_FFT = 1;
            LoadDataAddr = 5'h00;

            #50
            LoadDataWrite = 0;
            data_imag_in = 16'h0000;
            data_real_in = 16'h0000;
            ACLR = 0;
            start_FFT = 0;
            LoadDataAddr = 5'h00;


        // Display header for the test
        $display("Time \t Aprime_complex_out \t Bprime_complex_out \t Aprime_real_out \t Bprime_real_out");
        $monitor("%0t\t%h\t%h\t%h\t%h", $time, G_imag_out, H_imag_out, G_real_out, H_real_out);

        // let him cook
        #6000
        // End of test
        $finish;

    end


    // output wavefandm
    initial begin
        // output file name
        $dumpfile("FFT.vcd");
        $dumpvars(0, FFT_tb);
    end


endmodule

// clear; iverilog -o FFT -s FFT_tb -c FileList.txt; vvp .\FFT
// gtkwave .\FFT.vcd .\FFT.gtkw