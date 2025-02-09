module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	// add your code here

	// https://people.duke.edu/~tkb13/courses/ece250-2022su/slides/06-sequential-logic.pdf
	// note p45-p60

	// reg files are made up of 32, 32-bit registers. Each one of these registers is made out of 32 d flip flops (one ff per bit).

	// we'll have a decoder convert the ctrl signals to onehot signals. (we can only write one reg at a time (one write port), but we can read two registers at a time (two read ports)).
	
	// the decoded read signals will go into muxes on the Q side of the registers.
	wire [31:0] ctrl_readRegA_onehotdecoded;
	decode_32_bi decoderReadA(.select(ctrl_readRegA), .out(ctrl_readRegA_onehotdecoded));

	wire [31:0] ctrl_readRegB_onehotdecoded;
	decode_32_bi decoderReadB(.select(ctrl_readRegB), .out(ctrl_readRegB_onehotdecoded));

	// one bit of the decoded write signal will go into an enable pin, one bit for each register.
	wire [31:0] ctrl_writeReg_onehotdecoded;
	decode_32_bi decoderWrite(.select(ctrl_writeReg), .out(ctrl_writeReg_onehotdecoded));


	// now we can create the registers themselves. We want to hardcode r0 to 32'b0. this line will create 32 buses, each 32 bits long, one for each register. 
	wire [31:0] Areg_d_array [0:31];
    wire [31:0] Areg_q_array [0:31];
	wire [31:0] Breg_d_array [0:31];
    wire [31:0] Breg_q_array [0:31];
	wire [31:0] Aregreadout;

	genvar i;
	generate
		for (i=0; i<32; i=i+1) begin
			// we will have to replace ctrl_writeEnable and possible the reset signal as well.
			// question: will ctrl_reset be required to reset all registers, or just the one selected by ctrl_writeReg_onehotdecoded?
			register_32 regA(.q(Areg_q_array[i]), .d(Areg_d_array[i]), .clk(clock), .en(ctrl_writeEnable), .clr(ctrl_reset));
			register_32 regB(.q(Breg_q_array[i]), .d(Breg_d_array[i]), .clk(clock), .en(ctrl_writeEnable), .clr(ctrl_reset));

			mux_2 mux_regAread(.select(ctrl_readRegA_onehotdecoded[i]), .out(Aregreadout), .in0(32'b0), .in1(Areg_q_array[i]));
		end
	endgenerate
   

endmodule


// regfile_FileList.txt

// iverilog -o reg-main/regfile -c reg-main/regfile_FileList.txt -Wimplicit
// vvp .\reg-main\regfile