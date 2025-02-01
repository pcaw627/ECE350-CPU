`timescale 1 ns / 100 ps

module rca2bit_tb;
//////
// inputs to the module (reg)
    wire [1:0] A, B;
    wire Cin;
    // outputs of the module (wire)
    wire [1:0] S;
    wire Cout;
    // Instantiate the module to test
    rca2bit rca2bit(.A(A),.B(B),.Cin(Cin),.S(S),.Cout(Cout));

    /////// Input Initialization
    // Initialize the inputs and specify the runtime

    integer i;
    assign {Cin, A, B} = i[4:0];

    initial begin

        for (i=0; i<32; i++) begin
            #20;
            $display("A:%b, B:%b, C:%b => S:%b, Cout:%b", A, B, Cin, S, Cout);
        end

        $finish;
    end
    

    
    // //////  Output Results   //////
    // always @(A, B, Cin) begin
    //     // Small Delay so outputs can stabilize
    //     #1;
    //     $display("A:%b, B:%b, Cin:%b => S:%b, Cout:%b", A, B, Cin, S, Cout);

    // end

    // output waveform
    initial begin
        // output file name
        $dumpfile("rca2bit.vcd");
        $dumpvars(0, rca2bit_tb);
    end

endmodule