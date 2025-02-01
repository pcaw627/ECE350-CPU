`timescale 1 ns / 100 ps

module cla_8_tb;
//////
// inputs to the module (reg)
    reg Cin;
    reg [7:0] A, B;
    // outputs of the module (wire)
    wire [7:0] Sum;
    wire Cout;
    // Instantiate the module to test
    cla_8 addsub(.Sum(Sum), .Cout(Cout), .A(A), .B(B), .Cin(Cin));

    //////    Input Manipulation
    initial begin


        /////////////   Addition
        Cin = 1'b0;
        A = 8'b00000101;
        B = 8'b00000111;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 8'd244;
        B = 8'd16;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 8'd25;
        B = 8'd32;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 8'b11111111;
        B = 8'd17;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 8'd3;
        B = 8'd7;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);


        /////// Subtraction
        Cin = 1'b1;
        A = 8'b00000101;
        B = 8'b00000111;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 8'd244;
        B = 8'd16;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 8'd25;
        B = 8'd32;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 8'b11111111;
        B = 8'd17;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
        A = 8'd3;
        B = 8'd7;
        #20;
        $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", A, B, Cin, Sum, Cout);
        
    end 

    
    // output waveform
    initial begin
        // output file name
        $dumpfile("cla_8.vcd");
        $dumpvars(0, cla_8_tb);
    end

endmodule