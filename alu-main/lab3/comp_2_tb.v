`timescale 1 ns / 100 ps

module comp_2_tb;
//////
// inputs to the module (reg)
    wire EQ1, GT1;
    wire [1:0] A, B;
    // outputs of the module (wire)
    wire EQ0, GT0;
    // Instantiate the module to test
    comp_2 compare(.EQ1(EQ1), .GT1(GT1), .A(A), .B(B), .EQ0(EQ0), .GT0(GT0));

    /////// Input Initialization
    // Initialize the inputs and specify the runtime
    // initial begin
    //     // Initialize the inputs to 0
    //     GT1 = 1'b0;
    //     EQ1 = 1'b0;
    //     A = 2'b0;
    //     B = 2'b0;
    //     // Set a time delay, in nanoseconds
    //     #160;
    //     // Ends the testbench
    //     $finish;
    // end

    //////    Input Manipulation
    
    integer i;
    assign {GT1, EQ1, A, B} = i[5:0];

    initial begin

        for (i=0; i<64; i++) begin
            #20;
            $display("GT1:%b, EQ1:%b, A:%b, B:%b => GT0:%b, EQ0:%b", GT1, EQ1, A, B, GT0, EQ0);
        end

        $finish;
    end
    
    // //////  Output Results   //////
    // always @(GT1, EQ1, A, B, GT0, EQ0) begin
    //     // Small Delay so outputs can stabilize
    //     #1;
    //     $display("A:%b, B:%b, Cin:%b => S:%b, Cout:%b", A, B, Cin, S, Cout);

    // end

    // output waveform
    initial begin
        // output file name
        $dumpfile("comp_2.vcd");
        $dumpvars(0, comp_2_tb);
    end

endmodule