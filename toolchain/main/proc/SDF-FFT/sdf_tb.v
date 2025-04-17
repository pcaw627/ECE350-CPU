`timescale 1ns/1ps

module sdf_tb;
  // Parameters
  localparam WIDTH = 16;
  localparam N_SAMPLES = 64;
  real       TWO_PI    = 6.283185307179586;
  real       amplitude;

  // DUT Signals
  reg                     clock;
  reg                     reset;
  reg                     data_in_en;
  reg   [WIDTH-1:0]       data_in_real, data_in_imag;
  wire                    data_out_en;
  wire  [WIDTH-1:0]       data_out_real, data_out_imag;

  // Instantiate the 64-point FFT
  sdf_fft #(.WIDTH(16)) uut (
    .clock  (clock),
    .reset  (reset),
    .data_in_en  (data_in_en),
    .data_in_real  (data_in_real),
    .data_in_imag  (data_in_imag),
    .data_out_en  (data_out_en),
    .data_out_real  (data_out_real),
    .data_out_imag  (data_out_imag)
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
    data_in_en = 0;
    data_in_real = 0;
    data_in_imag = 0;
    repeat (2) @(posedge clock);
    reset = 0;

    // Stream N_SAMPLES of sine-wave
    for (i = 0; i < N_SAMPLES; i = i + 1) begin
      angle   = TWO_PI * i / N_SAMPLES;
      sin_val = amplitude * $sin(angle);
      @(posedge clock);
      data_in_en = 1;
      data_in_real = $rtoi(sin_val);
      data_in_imag = 0;
    end

    // Turn off input
    @(posedge clock);
    data_in_en = 0;
  end

// Monitor FFT output
  always @(posedge clock) begin
    if (data_out_en) begin
      $display("%0t ns: Out[%0d] = %0d (Re), %0d (Im)", $time, $urandom_range(0, N_SAMPLES-1), $signed(data_out_real), $signed(data_out_imag));
    end
  end

  // End simulation
  initial begin
    #2000;
    $finish;
  end

initial begin
        $dumpfile("sdf_fft.vcd");
        $dumpvars(0, sdf_tb);
end

endmodule

// clear; iverilog -o sdf_fft -c FileList.txt -s sdf_tb; vvp sdf_fft; gtkwave sdf_fft.vcd