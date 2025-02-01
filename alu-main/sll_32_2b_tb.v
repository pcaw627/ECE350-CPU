`timescale 1 ns / 100 ps

module sll_32_2b_tb;
//////
// inputs to the module (reg)
    reg [31:0] in;
    wire [31:0] out;
    // outputs of the module (wire)
    
    // Instantiate the module to test
    sll_32_2b sll_32_gate(.in(in),.out(out));

    //////    Input Manipulation
    initial begin
        in = 32'd7;
        #20;
        $display("in:%b => out:%b", in, out);
        
        in = 32'd7987;
        #20;
        $display("in:%b => out:%b", in, out);
        
        in = 32'd52355257;
        #20;
        $display("in:%b => out:%b", in, out);
        
        in = 32'd120198;
        #20;
        $display("in:%b => out:%b", in, out);
        
        in = 32'd123;
        #20;
        $display("in:%b => out:%b", in, out);
        
    end 


    // output waveform
    initial begin
        // output file name
        $dumpfile("sll_32_2b.vcd");
        $dumpvars(0, sll_32_2b_tb);
    end

endmodule