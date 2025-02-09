`timescale 1 ns / 100 ps

module decode_32_tb;
//////
// inputs to the module (reg)
    wire [31:0] in;
    // outputs of the module (wire)
    wire [4:0] select;
    wire [31:0] out;
    // Instantiate the module to test
    decode_32 decode32(out, select, in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31);

    /////// Input Initialization
    // Initialize the inputs and specify the runtime

    integer i;
    assign {select} = i[4:0];

    assign in0 = 0;
    assign in1 = 1;
    assign in2 = 2;
    assign in3 = 3;
    assign in4 = 4;
    assign in5 = 5;
    assign in6 = 6;
    assign in7 = 7;
    assign in8 = 8;
    assign in9 = 9;
    assign in10 = 10;
    assign in11 = 11;
    assign in12 = 12;
    assign in13 = 13;
    assign in14 = 14;
    assign in15 = 15;
    assign in16 = 16;
    assign in17 = 17;
    assign in18 = 18;
    assign in19 = 19;
    assign in20 = 20;
    assign in21 = 21;
    assign in22 = 22;
    assign in23 = 23;
    assign in24 = 24;
    assign in25 = 25;
    assign in26 = 26;
    assign in27 = 27;
    assign in28 = 28;
    assign in29 = 29;
    assign in30 = 30;
    assign in31 = 31;


    initial begin

        for (i=0; i<32; i++) begin
            #20;
            // $display("A:%b, B:%b, C:%b => S:%b, Cout:%b", A, B, Cin, S, Cout);
            $display("select:%b => output:%b", select, out);
        end

        $finish;
    end
    

    // output waveform
    initial begin
        // output file name
        $dumpfile("mux_32.vcd");
        $dumpvars(0, mux_32_tb);
    end

endmodule

// iverilog -o mux_32 -s mux_32_tb .\mux_32.v .\mux_16.v .\mux_8.v .\mux_4.v .\mux2bit.v .\mux_32_tb.v
// 