`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (
    input clk_100mhz, 
    input reset, 
    input BTNU, 
    input BTND,
    input BTNL,
    input BTNR,
    input BTNC,
    input vauxp3,
    input vauxn3,
    output AUD_PWM,
    output AUD_SD,
    output reg [15:0] LED);
    
    wire clock;
    assign clock = clk_40mhz;
    
    wire locked, clk_40mhz; 
    clk_wiz_0 pll (
      // Clock out ports
      .clk_out1(clk_40mhz),
      // Status and control signals
      .reset(1'b0),
      .locked(locked),
     // Clock in ports
      .clk_in1(clk_100mhz)
     );
     
    reg [26:0] paddr;

    reg led_latch;
    initial begin
        led_latch <= 1'b0;
        pval <= 3'b0;
    end

     wire BTNU_out, BTND_out, BTNL_out, BTNR_out, BTNC_out;
     always @(posedge clock) begin
//        LED[0] <= BTNU_out;     
//        LED[1] <= BTND_out;
//        LED[2] <= BTNR_out;     
//        LED[3] <= BTNL_out;   
//        LED[15:4] <= adc_out[15:4]
          LED[9:0] <= duty_cycle_total;
          //LED[0] <= led_latch;
//        LED[4] <= BTNC_out;    
          if (adc_stb) begin
            led_latch <= 1'b1;
          end
        paddr <= BTNL ? 4 : BTND ? 3 : BTNR ? 2 : BTNU ? 1 : BTNC ? 0: pval;
     end
     
     
     
     wire [15:0] adc_out;
     wire adc_stb, adc_ready;
     adc_data_capture data_capture(
        .clk(clock),
        .reset(1'b0),
        .vauxn3(vauxn3), .vauxp3(vauxp3),
        .adc_out(adc_out),
        .adc_stb(adc_stb),
        .data_ready(adc_ready)
    );
    
    assign AUD_SD = 1'b1;
    wire [9:0] duty_cycle_total = 1023 * audio_latch_out / 16383;
	PWMSerializer serializer1(
		.clk(clock),              // System Clock
		.reset(1'b0),            // Reset the counter
		.duty_cycle(duty_cycle_total), // Duty Cycle of the Wave, between 0 and 1023 - scaled to 0 and 100
		.signal(AUD_PWM)   // Output PWM signal
    );
    

    dffe_ref audio_out_reg [15:0] (
        .q(audio_latch_out),
        .d(audio_out),
        .clk(clock),
        .clr(1'b0),
        .en(sample_ready)
    );


     
	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;


	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "fft";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut),
		
		// fpga input/output
        .BTNU(BTNU),
        .BTNR(BTNR),
        .BTNL(BTNL),
        .BTND(BTND),
        .BTNC(BTNC),
        
        .BTNU_out(BTNU_out),
        .BTND_out(BTND_out),
        .BTNL_out(BTNL_out),
        .BTNR_out(BTNR_out),
        .BTNC_out(BTNC_out),

        // paddr
        .paddr(paddr),

        // ADC sample
        .adc_sample(adc_out),
        .adc_ready(adc_ready),

        // Audio Out Signals
        .audio_out(audio_out),
        .sample_ready(sample_ready)


		); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));

endmodule
