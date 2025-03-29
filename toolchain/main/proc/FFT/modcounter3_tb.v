`timescale 1ns / 1ps

module mod5counter3_tb;

  // Declare signals to drive the inputs and capture the outputs of the module
  reg clk;
  reg clr;
  reg en;
  wire [2:0] count;

  // Instantiate the mod5counter3 module
  mod5counter3 uut (
    .count(count),
    .clk(clk),
    .clr(clr),
    .en(en)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;  // Toggle clock every 5ns
  end

  // Initial block for stimulus
  initial begin
    // Initialize signals
    clk = 0;
    clr = 0;
    en = 0;

    // Display the result headers
    $display("Time\tclk\tclr\ten\tcount");
    $monitor("%0t\t%b\t%b\t%b\t%b", $time, clk, clr, en, count);

    // Apply reset and enable the counter
    #10 clr = 1;   // Apply reset
    #10 clr = 0;   // Release reset

    // Enable counting
    #10 en = 1;
    #10 en = 0;
    #10 en = 1;

    // Run the simulation for a few cycles
    #50;
    
    // Test with reset and enable variations
    #10 clr = 1;   // Apply reset
    #10 clr = 0;   // Release reset
    #10 en = 1;
    #50;

    // Test with counter disabled
    #10 en = 0;
    #20;

    // End the simulation
    $stop;
  end

endmodule
