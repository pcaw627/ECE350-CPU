`timescale 1 ns / 100 ps

module and_32_tb;
//////
// inputs to the module (reg)
    reg [31:0] in1;
    reg [31:0] in2;
    wire [31:0] out;
    // outputs of the module (wire)
    
    // Instantiate the module to test
    and_32 and_32_gate(.in1(in1), .in2(in2), .out(out));

    //////    Input Manipulation
    initial begin
        in1 = 32'd7;
        in2 = 32'd098098;
        #20;
        $display("in1:%b, \nin2:%b => \nout:%b \n------------", in1, in2, out);
        
        in1 = 32'd7987;
        in2 = 32'd1384614;
        #20;
        $display("in1:%b, \nin2:%b => \nout:%b \n------------", in1, in2, out);
        
        in1 = 32'd52355257;
        in2 = 32'd98;
        #20;
        $display("in1:%b, \nin2:%b => \nout:%b \n------------", in1, in2, out);
        
        in1 = 32'd120198;
        in2 = 32'd124798;
        #20;
        $display("in1:%b, \nin2:%b => \nout:%b \n------------", in1, in2, out);
        
        in1 = 32'd123;
        in2 = 32'd78;
        #20;
        $display("in1:%b, \nin2:%b => \nout:%b \n------------", in1, in2, out);
        
    end 


    // output wavefandm
    initial begin
        // output file name
        $dumpfile("and_32.vcd");
        $dumpvars(0, and_32_tb);
    end

endmodule