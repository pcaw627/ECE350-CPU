`timescale 1 ns / 100 ps

module sll_32_tb;
//////
// inputs to the module (reg)
    reg [31:0] in;
    reg [4:0] shamt;
    wire [31:0] out;
    // outputs of the module (wire)
    
    // Instantiate the module to test
    sll_32 sll_32_gate(.in(in),.out(out), .shamt(shamt));

    //////    Input Manipulation
    initial begin
        shamt = 5'b00001;
        in = 32'd7;
        #20;
        $display("in:%b, shamt:%b => out:%b", in, shamt, out);
        
        shamt = 5'b00001;
        in = 32'd7987;
        #20;
        $display("in:%b, shamt:%b => out:%b", in, shamt, out);
        
        shamt = 5'd11;
        in = 32'd52355257;
        #20;
        $display("in:%b, shamt:%b => out:%b", in, shamt, out);  
        
        shamt = 5'd2;
        in = 32'd120198;
        #20;
        $display("in:%b, shamt:%b => out:%b", in, shamt, out);
        
        shamt = 5'd31;
        in = 32'd123;
        #20;
        $display("in:%b, shamt:%b => out:%b", in, shamt, out);
        
        shamt = 5'b01000;
        in = 32'd123;
        #20;
        $display("in:%b, shamt:%b => out:%b", in, shamt, out);

        shamt = 5'b10000;
        in = 32'd123;
        #20;
        $display("in:%b, shamt:%b => out:%b", in, shamt, out);
        
    end 


    // output waveform
    initial begin
        // output file name
        $dumpfile("sll_32.vcd");
        $dumpvars(0, sll_32_tb);
    end

endmodule