`timescale 1ns/1ps

module sdf_tb;
  // Parameters
  localparam WIDTH     = 16;
  localparam N_SAMPLES = 64;
  real       TWO_PI    = 6.283185307179586;
  real       amplitude;

  // DUT Signals
  reg                     clock;
  reg                     reset;
  reg                     di_en;
  reg   [WIDTH-1:0]       di_re, di_im;
  wire                    do_en;
  wire  [WIDTH-1:0]       do_re, do_im;

  // Instantiate the 64-point FFT
  sdf_fft #(.WIDTH(WIDTH)) uut (
    .clock  (clock),
    .reset  (reset),
    .di_en  (di_en),
    .di_re  (di_re),
    .di_im  (di_im),
    .do_en  (do_en),
    .do_re  (do_re),
    .do_im  (do_im)
  );

  // Clock generation: 10 ns period
  initial clock = 0;
  always #5 clock = ~clock;
// Generate sine-wave input
  integer i;
  real    angle;
  real    sin_val;

  initial begin
    // Compute amplitude for full-scale signed input
    amplitude = (2**(WIDTH-1)) - 1;

    // Reset sequence
    reset = 1;
    di_en = 0;
    di_re = 0;
    di_im = 0;
    repeat (2) @(posedge clock);
    reset = 0;

    // Stream N_SAMPLES of sine-wave
    for (i = 0; i < N_SAMPLES; i = i + 1) begin
      angle   = TWO_PI * i / N_SAMPLES;
      sin_val = amplitude * $sin(angle);
      @(posedge clock);
      di_en = 1;
      di_re = $rtoi(sin_val);
      di_im = 0;
    end

    // Turn off input
    @(posedge clock);
    di_en = 0;
  end

// Monitor FFT output
  always @(posedge clock) begin
    if (do_en) begin
      $display("%0t ns: Out[%0d] = %0d (Re), %0d (Im)", $time, $urandom_range(0, N_SAMPLES-1), $signed(do_re), $signed(do_im));
    end
  end

  // End simulation
  initial begin
    #2000;
    $finish;
  end

initial begin
        $dumpfile("FFT.vcd");
        $dumpvars(0, TB64);
end

endmodule