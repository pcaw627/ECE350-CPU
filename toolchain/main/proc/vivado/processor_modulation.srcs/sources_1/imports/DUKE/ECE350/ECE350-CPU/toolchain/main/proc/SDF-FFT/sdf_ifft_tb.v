`timescale 1ns/1ps
//===========================================================
// 64‑point FFT  +  64‑point IFFT self‑check test bench
//===========================================================
module sdf_ifft_tb;

   // ----------------- parameters -----------------
   parameter WIDTH      = 16;
   parameter N_SAMPLES  = 64;

   real TWO_PI;

   // ----------------- clocks & reset -------------
   reg clock;
   reg reset;

   // ------------- DUT interface signals ----------
   // forward FFT
   reg                   fft_in_en;
   reg  [WIDTH-1:0]      fft_in_re,  fft_in_im;
   wire                  fft_out_en;
   wire [WIDTH-1:0]      fft_out_re, fft_out_im;
   // inverse FFT
   reg                   ifft_in_en;
   reg  [WIDTH-1:0]      ifft_in_re, ifft_in_im;
   wire                  ifft_out_en;
   wire [WIDTH-1:0]      ifft_out_re, ifft_out_im;

   // ----------------- storage --------------------
   reg  signed [WIDTH-1:0] tx_re      [0:N_SAMPLES-1];
   reg  signed [WIDTH-1:0] fft_buf_re [0:N_SAMPLES-1];
   reg  signed [WIDTH-1:0] fft_buf_im [0:N_SAMPLES-1];
   reg  signed [WIDTH-1:0] ifft_buf_re[0:N_SAMPLES-1];
   reg  signed [WIDTH-1:0] ifft_buf_im[0:N_SAMPLES-1];

   // ----------------- integers & reals ----------
   integer i, fft_cnt, ifft_cnt;
   real    amplitude, angle, sin_val;

   //========================================================
   //  initialisation (Verilog‑2001 – no inline “= …”)
   //========================================================
   initial begin
      // fixed constants
      TWO_PI    = 6.283185307179586;
      amplitude = (2.0 ** (WIDTH-1)) - 1;       // 32767 for 16‑bit
      // registers / counters
      clock       = 0;
      reset       = 1;
      fft_in_en   = 0;      fft_in_re  = 0;     fft_in_im  = 0;
      ifft_in_en  = 0;      ifft_in_re = 0;     ifft_in_im = 0;
      fft_cnt     = 0;      ifft_cnt   = 0;
   end

   //========================================================
   //  clock generation & reset release
   //========================================================
   always #5 clock = ~clock;                    // 100 MHz
   initial begin
      repeat (2) @(posedge clock);              // keep reset 2 cycles
      reset = 0;
   end

   //========================================================
   //  DUT instantiation
   //========================================================
   sdf_fft  #(.WIDTH(WIDTH)) U_FFT  (
      .clock        (clock),
      .reset        (reset),
      .data_in_en   (fft_in_en),
      .data_in_real (fft_in_re),
      .data_in_imag (fft_in_im),
      .data_out_en  (fft_out_en),
      .data_out_real(fft_out_re),
      .data_out_imag(fft_out_im)
   );

   sdf_ifft #(.WIDTH(WIDTH)) U_IFFT (
      .clock        (clock),
      .reset        (reset),
      .data_in_en   (ifft_in_en),
      .data_in_real (ifft_in_re),
      .data_in_imag (ifft_in_im),
      .data_out_en  (ifft_out_en),
      .data_out_real(ifft_out_re),
      .data_out_imag(ifft_out_im)
   );

   //========================================================
   //  utility functions  (legal in Verilog‑2001)
   //========================================================
   function integer bitrev6;       // 6‑bit bit‑reverse
      input integer idx;
      integer j;
      begin
         bitrev6 = 0;
         for (j = 0; j < 6; j = j + 1)
            bitrev6 = bitrev6 | (((idx >> j) & 1) << (5 - j));
      end
   endfunction

   function integer sabs;          // absolute value
      input integer x;
      begin
         if (x < 0) sabs = -x; else sabs = x;
      end
   endfunction

   //========================================================
   // 1)  drive a 64‑sample full‑scale sine into the FFT
   //========================================================
   initial begin
      @(negedge reset);                                // wait for reset de‑assert
      for (i = 0; i < N_SAMPLES; i = i + 1) begin
         angle   = TWO_PI * i / N_SAMPLES;
         sin_val = amplitude * $sin(angle);
         tx_re[i] = $rtoi(sin_val);
         @(posedge clock);
         fft_in_en <= 1'b1;
         fft_in_re <= $rtoi(sin_val);
         fft_in_im <= {WIDTH{1'b0}};
      end
      @(posedge clock);
      fft_in_en <= 1'b0;
   end

   //========================================================
   // 2)  store FFT outputs as they appear (bit‑reversed order)
   //========================================================
   always @(posedge clock)
      if (fft_out_en) begin
         fft_buf_re[fft_cnt] <= fft_out_re;
         fft_buf_im[fft_cnt] <= fft_out_im;
         fft_cnt             <= fft_cnt + 1;
      end

   //========================================================
   // 3)  when all 64 bins captured, feed them to the IFFT
   //========================================================
   event start_ifft;
   always @(posedge clock)
      if (fft_cnt == N_SAMPLES) -> start_ifft;

   initial begin : feed_ifft_block
      integer idx_nat;
      @(start_ifft);
      repeat (2) @(posedge clock);               // small gap

      for (i = 0; i < N_SAMPLES; i = i + 1) begin
         idx_nat = bitrev6(i);                   // convert to natural order
         @(posedge clock);
         ifft_in_en <= 1'b1;
         ifft_in_re <= fft_buf_re[idx_nat];
         ifft_in_im <= fft_buf_im[idx_nat];
      end
      @(posedge clock);
      ifft_in_en <= 1'b0;
   end

   //========================================================
   // 4)  store IFFT outputs
   //========================================================
   always @(posedge clock)
      if (ifft_out_en) begin
         ifft_buf_re[ifft_cnt] <= ifft_out_re;
         ifft_buf_im[ifft_cnt] <= ifft_out_im;
         ifft_cnt              <= ifft_cnt + 1;
      end

   //========================================================
   // 5)  compare reconstructed samples with originals
   //========================================================
   initial begin : analyse_results_block
      integer idx_nat, diff, max_err;
      max_err = 0;

      @(negedge reset);
      wait (ifft_cnt == N_SAMPLES);             // wait for full frame

      // ---------- error metric ----------
      for (i = 0; i < N_SAMPLES; i = i + 1) begin
         idx_nat = bitrev6(i);
         diff    = ifft_buf_re[i] - (tx_re[idx_nat] >>> 6); // total 1/64 scale
         diff    = sabs(diff);
         if (diff > max_err)  max_err = diff;
      end

      $display("\n==============================================");
      $display(" Max |error| after FFT->IFFT = %0d LSB", max_err);
      if (max_err <= 2)
         $display("  SUCCESS  – within 2 LSBs");
      else
         $display("  WARNING  – error larger than expected");
      $display("==============================================\n");

      // ---------- NEW: print reconstructed samples (natural order) ----------
      $display("IFFT output samples, natural order (real part, 1/64‑scaled):");
      for (i = 0; i < N_SAMPLES; i = i + 1) begin
         idx_nat = bitrev6(i);                    // undo bit‑reversed order
         $display("x[%0d] = %0d", i, ifft_buf_re[idx_nat]);
      end
      $display("==============================================\n");

      $finish;
   end

   
   initial begin
         $dumpfile("sdf_ifft.vcd");
         $dumpvars(0, sdf_ifft_tb);
   end


endmodule
