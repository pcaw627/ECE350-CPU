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
	// wire [31:0] Areg_d_array [0:31];
	// wire [31:0] Breg_d_array [0:31];
    wire [31:0] reg_q_array [0:31];
	wire [31:0] Aregreadout;
	wire [31:0] Bregreadout;

	genvar i;
	generate
		for (i=0; i<32; i=i+1) begin : registers
			// question: will ctrl_reset be required to reset all registers, or just the one selected by reg_enable?
			// remember to make r0 always 0

			wire reg_enable;
			and(reg_enable, ctrl_writeEnable, ctrl_writeReg_onehotdecoded[i]);
			register_32 reg_i(.q(reg_q_array[i]), .d(data_writeReg), .clk(clock), .en(reg_enable), .clr(ctrl_reset));
			
			mux_2 mux_regAread(.select(ctrl_readRegA_onehotdecoded[i]), .out(data_readRegA), .in0(32'bz), .in1(reg_q_array[i]));
			mux_2 mux_regBread(.select(ctrl_readRegB_onehotdecoded[i]), .out(data_readRegB), .in0(32'bz), .in1(reg_q_array[i]));
		end
	endgenerate
   

endmodule


// regfile_FileList.txt

// iverilog -o reg-main/regfile -c reg-main/regfile_FileList.txt -Wimplicit
// vvp .\reg-main\regfile +test=basic

// iverilog -o .\regfile -c .\regfile_FileList.txt -Wimplicit
// vvp .\regfile +test=basic