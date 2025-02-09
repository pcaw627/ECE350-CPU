# Register File
## Name
Phillip (Liam) Williams

## Description of Design
Design Spec:

+ Design and simulate a register file using Verilog. You must support:

+ 2 read ports

+ 1 write port

+ 32 registers (registers are 32-bits wide)

I implemented the above, along with the associated control signals for clear/reset, selecting which registers are read from for each port, and selecting which registers are written. 

I broke up the modules into the dffe (d flip flop with enable), 32bit decoders (one version that was 1-0, and another that was 1-z). I ended up using the 1-0 version, and then running those into muxes with a z-signal on the in0 pin. Then on top of those two, I built a 32-bit register, and then a regfile module that combined 32 of the 32-bit registers. 

I took care not to use the prebuilt digital operators or behavioral verilog (besides within the dffe as specified in the design doc.) In addition, I made use of genvar loops (as allowed in the design doc.)

## Bugs
Reached 100% coverage via the test benches, but I will keep a look out for any unintended behavior as I continue building the multdiv module. 