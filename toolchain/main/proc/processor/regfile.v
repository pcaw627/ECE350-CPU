// allowed to use: assign out = enable << select;


module regfile (
	clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset, not_writeReg0;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;


	// add your code here
	wire [31:0] write_enable, en_signal;
    wire [31:0] reg_out [31:0];
    wire [31:0] read_enableA, read_enableB;
    wire [31:0] tristate_outA [31:0], tristate_outB [31:0];
    
    // Decoder for write register selection
	assign write_enable = ctrl_writeEnable << ctrl_writeReg;

    // Generate or gate for checking if writeReg is 0
    or or_gate(not_writeReg0, ctrl_writeReg[0], ctrl_writeReg[1], ctrl_writeReg[2], ctrl_writeReg[3], ctrl_writeReg[4]); // Check for not 0

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: reg_loop
		    and and_gate(en_signal[i], write_enable[i], not_writeReg0); // Prevent writes to register 0
            dffe_ref one_reg [31:0] (
                .q(reg_out[i]), 
                .d(data_writeReg), 
                .clk(clock), 
                .en(en_signal[i]),
                .clr(ctrl_reset)
            );
        end
    endgenerate
    
    mux_32 muxA (
        .out(data_readRegA), 
        .select(ctrl_readRegA), 
        .in0(reg_out[0]), .in1(reg_out[1]), .in2(reg_out[2]), .in3(reg_out[3]),
        .in4(reg_out[4]), .in5(reg_out[5]), .in6(reg_out[6]), .in7(reg_out[7]),
        .in8(reg_out[8]), .in9(reg_out[9]), .in10(reg_out[10]), .in11(reg_out[11]),
        .in12(reg_out[12]), .in13(reg_out[13]), .in14(reg_out[14]), .in15(reg_out[15]),
        .in16(reg_out[16]), .in17(reg_out[17]), .in18(reg_out[18]), .in19(reg_out[19]),
        .in20(reg_out[20]), .in21(reg_out[21]), .in22(reg_out[22]), .in23(reg_out[23]),
        .in24(reg_out[24]), .in25(reg_out[25]), .in26(reg_out[26]), .in27(reg_out[27]),
        .in28(reg_out[28]), .in29(reg_out[29]), .in30(reg_out[30]), .in31(reg_out[31])
    );

    // Use the mux_32 module for data_readRegB
    mux_32 muxB (
        .out(data_readRegB), 
        .select(ctrl_readRegB), 
        .in0(reg_out[0]), .in1(reg_out[1]), .in2(reg_out[2]), .in3(reg_out[3]),
        .in4(reg_out[4]), .in5(reg_out[5]), .in6(reg_out[6]), .in7(reg_out[7]),
        .in8(reg_out[8]), .in9(reg_out[9]), .in10(reg_out[10]), .in11(reg_out[11]),
        .in12(reg_out[12]), .in13(reg_out[13]), .in14(reg_out[14]), .in15(reg_out[15]),
        .in16(reg_out[16]), .in17(reg_out[17]), .in18(reg_out[18]), .in19(reg_out[19]),
        .in20(reg_out[20]), .in21(reg_out[21]), .in22(reg_out[22]), .in23(reg_out[23]),
        .in24(reg_out[24]), .in25(reg_out[25]), .in26(reg_out[26]), .in27(reg_out[27]),
        .in28(reg_out[28]), .in29(reg_out[29]), .in30(reg_out[30]), .in31(reg_out[31])
    );
    
endmodule