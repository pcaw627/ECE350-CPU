module tb_rotate_left_by_S_5;
  
  // Inputs
  reg [4:0] d;
  reg clk;
  reg clr;
  reg [2:0] s;
  
  // Outputs
  wire [4:0] q;
  
  // Instantiate the module to be tested
  rotate_left_by_S_5 uut (
    .d(d),
    .clk(clk),
    .clr(clr),
    .s(s),
    .q(q)
  );
  
  // Clock generation
  always begin
    #5 clk = ~clk;  // Toggle clock every 5 time units
  end
  
  // Test stimulus
  initial begin
    // Initialize inputs
    clk = 0;
    clr = 0;
    s = 3'd0;
    
    // Apply reset
    clr = 1;
    #10 clr = 0;  // Release reset after 10 time units
    
    // Display header for the test
    $display("Time\tclk\td\tclr\ts\tPreshift (d)\tPostshift (q)");
    $monitor("%0t\t%b\t%b\t%b\t%d\t%b\t%b", $time, clk, d, clr, s, d, q);
    
    // Iterate through all 32 possible values of d
    for (d = 5'b00000; d <= 5'b11111; d = d + 1) begin
      // Test all possible shift values from s = 0 to s = 5
      for (s = 3'd0; s <= 3'd5; s = s + 1) begin
        // Wait for a couple of clock cycles to observe the change
        #10;
      end
    end
    
    // End of test
    $finish;
  end
  
endmodule
