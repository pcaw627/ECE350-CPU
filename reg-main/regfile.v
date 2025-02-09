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

	// reg files are made up of 32, 32-bit registers. Each one of these registers is made out of 32 d flip flops (one ff per bit).
   genvar i;
   generate
        for (i=0 i<32; i=i+1) begin loop1;
            // module dffe_ref (q, d, clk, en, clr);
            register_32 r(.q(q[i]), .d(d[i]), .clk(clk), .en(en), .clr(clr));
        end
   endgenerate
   



endmodule
