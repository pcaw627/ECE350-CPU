`timescale 1ns/1ps

module single_clock_delay_tb();
    // Parameters
    parameter WIDTH = 3;
    parameter CLK_PERIOD = 10; // 10ns = 100MHz clock
    
    // Testbench signals
    reg clk;
    reg clr;
    reg [WIDTH-1:0] d;
    wire [WIDTH-1:0] q;
    
    // Instantiate the Device Under Test (DUT)
    single_clock_delay #(.WIDTH(WIDTH)) dut (
        .q(q),
        .d(d),
        .clr(clr),
        .clk(clk)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Stimulus and monitoring
    initial begin
        // Initialize signals
        clr = 1;
        d = 0;
        
        // Reset the DUT
        #(CLK_PERIOD*2);
        clr = 0;
        #(CLK_PERIOD);
        
        // Test case 1: Increment input value every cycle
        $display("Test case 1: Incrementing input pattern");
        repeat (2**WIDTH) begin
            d = d + 1;
            #(CLK_PERIOD);
            $display("Time: %0t, Input d: %b, Output q: %b", $time, d, q);
        end
        
        // Test case 2: Toggle all bits
        $display("Test case 2: Toggle all bits");
        d = {WIDTH{1'b0}};
        #(CLK_PERIOD);
        d = {WIDTH{1'b1}};
        #(CLK_PERIOD);
        $display("Time: %0t, Input d: %b, Output q: %b", $time, d, q);
        
        // Test case 3: Walking ones pattern
        $display("Test case 3: Walking ones pattern");
        d = {{(WIDTH-1){1'b0}}, 1'b1};
        for (integer i = 0; i < WIDTH; i = i + 1) begin
            #(CLK_PERIOD);
            $display("Time: %0t, Input d: %b, Output q: %b", $time, d, q);
            d = d << 1;
        end
        
        // Test case 4: Verify reset behavior
        $display("Test case 4: Verify reset behavior");
        d = {WIDTH{1'b1}};
        #(CLK_PERIOD);
        clr = 1;
        #(CLK_PERIOD);
        $display("Time: %0t, Input d: %b, Output q: %b, Clear: %b", $time, d, q, clr);
        clr = 0;
        #(CLK_PERIOD);
        
        // End simulation
        #(CLK_PERIOD*2);
        $display("Testbench completed");
        $finish;
    end
    
    // Self-checking logic
    reg [WIDTH-1:0] expected_q;
    
    always @(posedge clk) begin
        if (clr) begin
            expected_q <= {WIDTH{1'b0}};
        end else begin
            expected_q <= d;
        end
    end
    
    // Check for errors at negative edge of clock to avoid race conditions
    always @(negedge clk) begin
        if (q !== expected_q) begin
            $display("ERROR at time %0t: Expected q = %b, Actual q = %b", $time, expected_q, q);
        end
    end
    
    // Generate VCD dump file for waveform viewing
    initial begin
        $dumpfile("single_clock_delay_tb.vcd");
        $dumpvars(0, single_clock_delay_tb);
    end
    
endmodule