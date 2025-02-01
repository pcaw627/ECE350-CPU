`timescale 1 ns / 100 ps

module cla_32_tb;
//////
// inputs to the module (reg)
    reg Cin;
    reg [31:0] A, B;
    // outputs of the module (wire)
    wire [31:0] Sum;
    wire Cout;
    // Instantiate the module to test
    cla_32 addsub(.Sum(Sum), .Cout(Cout), .A(A), .B(B), .Cin(Cin));

    //////    Input Manipulation
    initial begin
        Cin = 0;
        A = 32'd3;
        B = 32'd7;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 32'd39897;
        B = 32'd778;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 32'd25;
        B = 32'd32;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 32'b11111111111111111111111111111111;
        B = 32'd17;
        #20;
        $display("A:%b, B:%b, Cin:%b => S:%b, Cout:%b", A, B, Cin, Sum, Cout);
        
        Cin = 1;
        A = 32'd3;
        B = 32'd7;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
    end 

    
    // output waveform
    initial begin
        // output file name
        $dumpfile("cla_32_debug.vcd");
        $dumpvars(0, cla_32_tb);
    end

endmodule