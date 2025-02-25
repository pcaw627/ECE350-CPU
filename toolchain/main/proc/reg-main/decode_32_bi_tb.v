`timescale 1 ns / 100 ps

module decode_32_bi_tb;
//////
// inputs to the module (reg)
    // wire [31:0] in;
    // outputs of the module (wire)
    wire [4:0] select;
    wire [31:0] out;
    // Instantiate the module to test
    decode_32_bi decode32(.select(select), .out(out));

    /////// Input Initialization
    // Initialize the inputs and specify the runtime

    integer i;
    assign {select} = i[4:0];


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
        $dumpfile("decode_32_bi.vcd");
        $dumpvars(0, decode_32_bi_tb);
    end

endmodule

// iverilog -o reg-main/decode_32_bi -c reg-main/decode_32_bi_FileList.txt -Wimplicit
// vvp .\reg-main\decode_32_bi