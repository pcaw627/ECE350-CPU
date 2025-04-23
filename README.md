# ECE350-CPU
Final project for ECE 350: Digital Systems at Duke. Designing a CPU from scratch in Verilog, and deployed to an Artix 7 A100 FPGA. Building on top of the processor's ISA, we designed, tested, and constructed a Real Time Electric Guitar Equalizer. 
To enable this project, we implemented Fast Fourier Transform (and its Inverse) in Verilog. The work and research for this project spanned roughly two months.

Checkpoints finished for this project included:
+ Building the CPU
  + Building an ALU with various operations and control signals 
  + Building a register file
  + Adding in more complex operations such as multiplication and division (implemented and optimized for hardware using algorithms such as Booth's)
  + Pipelining architecture
  + Hazards handling and Bypassing
+ Building the Equalizer
  + Implementing a Wallace Tree Multiplier
  + Implementing analog-to-digital converters and digital-to-analog converters for the interface
  + Fast Fourier Transform using the Radix-2^2 SDF architecture.
  + Inverse Fast Fourier Transform (reusing hardware from FFT).
  + Customizable Modulation instruction
+ Optimizing for timing (end result sysclock=30MHz, sampling rate 44kHz, Worst negative slack = 2.883ns)
+ Running a live demo in front of our class
+ Writing a technical report detailing our approach
