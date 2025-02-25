`timescale 1 ns / 100 ps

module and_1_tb;
//////
// inputs to the module (reg)
    reg in1, in2;
    wire out;
    // outputs of the module (wire)
    
    // Instantiate the module to test
    and_1 and_1_gate(.in1(in1),.in2(in2),.out(out));

    /////// Input Initialization
    // Initialize the inputs and specify the runtime
    initial begin
        // Initialize the inputs to 0
        in1 = 0;
        in2 = 0;
        // Set a time delay, in nanoseconds
        #40;
        // Ends the testbench
        $finish;
    end

    //////    Input Manipulation ///////

    // Toggle input A every 10 nanoseconds
    always
        #10 in1 = ~in1;

    // Toggle input B every 20 nanoseconds
    always
        #20 in2 = ~in2;
    // Print the inputs and outputs whenever inputs change

    
    //////  Output Results   //////
    always @(in1, in2, out) begin
        // Small Delay so outputs can stabilize
        #1;
        $display("in1:%b, in2:%b => out:%b", in1, in2, out);

    end

    // output wavefandm
    initial begin
        // output file name
        $dumpfile("and_1.vcd");
        $dumpvars(0, and_1_tb);
    end

endmodule