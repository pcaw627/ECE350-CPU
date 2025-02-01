
`timescale 1 ns / 100 ps

module comp_8_tb;
//////
// inputs to the module (reg)
    reg EQ1, GT1;
    reg [7:0] A, B;
    // outputs of the module (wire)
    wire EQ0, GT0;
    // Instantiate the module to test
    comp_8 compare(.EQ1(EQ1), .GT1(GT1), .A(A), .B(B), .EQ0(EQ0), .GT0(GT0));

    //////    Input Manipulation
    
    
    initial begin
        GT1 = 1'b0;
        EQ1 = 1'b1;

        A = 8'b00000000;
        B = 8'b00000000;
        #20;
        $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);
        

        A = 8'b00000000;
        B = 8'b00100000;
        #20;
        $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);
        

        A = 8'b00010000;
        B = 8'b00000000;
        #20;
        $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);
        

        A = 8'b10101010;
        B = 8'b10101010;
        #20;
        $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);
        

        A = 8'b00000000;
        B = 8'b00000001;
        #20;
        $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);
        

        A = 8'b01000000;
        B = 8'b01000000;
        #20;
        $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);

        
        GT1 = 1'b0;
        EQ1 = 1'b0;
        A = 8'b10101010;
        B = 8'b10101010;
        #20;
        $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);
        
        GT1 = 1'b1;
        EQ1 = 1'b0;
        A = 8'b10101010;
        B = 8'b10101010;
        #20;
        $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);
    end 

    
    // output waveform
    initial begin
        // output file name
        $dumpfile("comp_8.vcd");
        $dumpvars(0, comp_8_tb);
    end

endmodule