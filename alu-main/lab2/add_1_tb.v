`timescale 1 ns / 100 ps

module add_1_tb;
//////
// inputs to the module (reg)
    reg A, B, Cin;
    // outputs of the module (wire)
    wire S, Cout;
    // Instantiate the module to test
    add_1 adder(.A(A),.B(B),.Cin(Cin),.S(S),.Cout(Cout));

    /////// Input Initialization
    // Initialize the inputs and specify the runtime
    initial begin
        // Initialize the inputs to 0
        A = 0;
        B = 0;
        Cin = 0;
        // Set a time delay, in nanoseconds
        #80;
        // Ends the testbench
        $finish;
    end

    //////    Input Manipulation
    // Toggle input A every 10 nanoseconds
    always
        #10 A = ~A;
    // Toggle input B every 20 nanoseconds
    always
        #20 B = ~B;
    // Toggle input Cin every 40 nanoseconds
    always
        #40 Cin = ~Cin;
    // Print the inputs and outputs whenever inputs change

    
    //////  Output Results   //////
    always @(A, B, Cin) begin
        // Small Delay so outputs can stabilize
        #1;
        $display("A:%b, B:%b, Cin:%b => S:%b, Cout:%b", A, B, Cin, S, Cout);

    end

    // output waveform
    initial begin
        // output file name
        $dumpfile("add_1.vcd");
        $dumpvars(0, add_1_tb);
    end

endmodule