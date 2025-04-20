// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Sat Apr 19 22:46:14 2025
// Host        : P2-07 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -nolib -force -file
//               C:/Users/af314/Documents/ECE350-CPU/xadc_testing/xadc_testing.sim/sim_1/impl/func/xsim/Wrapper_func_impl.v
// Design      : Wrapper
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* ECO_CHECKSUM = "42241733" *) (* INSTR_FILE = "fft" *) 
(* NotValidForBitStream *)
module Wrapper
   (clk_100mhz,
    reset,
    BTNU,
    BTND,
    BTNL,
    BTNR,
    BTNC,
    vauxp3,
    vauxn3,
    LED);
  input clk_100mhz;
  input reset;
  input BTNU;
  input BTND;
  input BTNL;
  input BTNR;
  input BTNC;
  input vauxp3;
  input vauxn3;
  output [15:0]LED;

  wire [15:0]LED;
  wire [15:0]LED_OBUF;
  wire [15:0]adc_out;
  (* IBUF_LOW_PWR *) wire clk_100mhz;
  wire clock;
  wire vauxn3;
  wire vauxn3_IBUF;
  wire vauxp3;
  wire vauxp3_IBUF;
  wire NLW_pll_locked_UNCONNECTED;

  OBUF \LED_OBUF[0]_inst 
       (.I(LED_OBUF[0]),
        .O(LED[0]));
  OBUF \LED_OBUF[10]_inst 
       (.I(LED_OBUF[10]),
        .O(LED[10]));
  OBUF \LED_OBUF[11]_inst 
       (.I(LED_OBUF[11]),
        .O(LED[11]));
  OBUF \LED_OBUF[12]_inst 
       (.I(LED_OBUF[12]),
        .O(LED[12]));
  OBUF \LED_OBUF[13]_inst 
       (.I(LED_OBUF[13]),
        .O(LED[13]));
  OBUF \LED_OBUF[14]_inst 
       (.I(LED_OBUF[14]),
        .O(LED[14]));
  OBUF \LED_OBUF[15]_inst 
       (.I(LED_OBUF[15]),
        .O(LED[15]));
  OBUF \LED_OBUF[1]_inst 
       (.I(LED_OBUF[1]),
        .O(LED[1]));
  OBUF \LED_OBUF[2]_inst 
       (.I(LED_OBUF[2]),
        .O(LED[2]));
  OBUF \LED_OBUF[3]_inst 
       (.I(LED_OBUF[3]),
        .O(LED[3]));
  OBUF \LED_OBUF[4]_inst 
       (.I(LED_OBUF[4]),
        .O(LED[4]));
  OBUF \LED_OBUF[5]_inst 
       (.I(LED_OBUF[5]),
        .O(LED[5]));
  OBUF \LED_OBUF[6]_inst 
       (.I(LED_OBUF[6]),
        .O(LED[6]));
  OBUF \LED_OBUF[7]_inst 
       (.I(LED_OBUF[7]),
        .O(LED[7]));
  OBUF \LED_OBUF[8]_inst 
       (.I(LED_OBUF[8]),
        .O(LED[8]));
  OBUF \LED_OBUF[9]_inst 
       (.I(LED_OBUF[9]),
        .O(LED[9]));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[0] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[0]),
        .Q(LED_OBUF[0]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[10] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[10]),
        .Q(LED_OBUF[10]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[11] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[11]),
        .Q(LED_OBUF[11]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[12] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[12]),
        .Q(LED_OBUF[12]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[13] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[13]),
        .Q(LED_OBUF[13]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[14] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[14]),
        .Q(LED_OBUF[14]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[15] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[15]),
        .Q(LED_OBUF[15]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[1] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[1]),
        .Q(LED_OBUF[1]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[2] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[2]),
        .Q(LED_OBUF[2]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[3] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[3]),
        .Q(LED_OBUF[3]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[4] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[4]),
        .Q(LED_OBUF[4]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[5] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[5]),
        .Q(LED_OBUF[5]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[6] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[6]),
        .Q(LED_OBUF[6]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[7] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[7]),
        .Q(LED_OBUF[7]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[8] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[8]),
        .Q(LED_OBUF[8]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \LED_reg[9] 
       (.C(clock),
        .CE(1'b1),
        .D(adc_out[9]),
        .Q(LED_OBUF[9]),
        .R(1'b0));
  adc_data_capture data_capture
       (.CLK(clock),
        .Q(adc_out),
        .vauxn3(vauxn3_IBUF),
        .vauxp3(vauxp3_IBUF));
  (* IMPORTED_FROM = "c:/Users/af314/Documents/ECE350-CPU/xadc_testing/xadc_testing.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.dcp" *) 
  (* IMPORTED_TYPE = "CHECKPOINT" *) 
  (* IS_IMPORTED *) 
  clk_wiz_0 pll
       (.clk_in1(clk_100mhz),
        .clk_out1(clock),
        .locked(NLW_pll_locked_UNCONNECTED),
        .reset(1'b0));
  IBUF vauxn3_IBUF_inst
       (.I(vauxn3),
        .O(vauxn3_IBUF));
  IBUF vauxp3_IBUF_inst
       (.I(vauxp3),
        .O(vauxp3_IBUF));
endmodule

module adc_data_capture
   (Q,
    CLK,
    vauxp3,
    vauxn3);
  output [15:0]Q;
  input CLK;
  input vauxp3;
  input vauxn3;

  wire CLK;
  wire [15:0]Q;
  wire [15:0]adc_data;
  wire drdy;
  wire vauxn3;
  wire vauxp3;
  wire NLW_xadc_inst_alarm_out_UNCONNECTED;
  wire NLW_xadc_inst_busy_out_UNCONNECTED;
  wire NLW_xadc_inst_eoc_out_UNCONNECTED;
  wire NLW_xadc_inst_eos_out_UNCONNECTED;
  wire [4:0]NLW_xadc_inst_channel_out_UNCONNECTED;

  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[0] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[0]),
        .Q(Q[0]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[10] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[10]),
        .Q(Q[10]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[11] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[11]),
        .Q(Q[11]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[12] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[12]),
        .Q(Q[12]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[13] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[13]),
        .Q(Q[13]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[14] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[14]),
        .Q(Q[14]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[15] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[15]),
        .Q(Q[15]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[1] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[1]),
        .Q(Q[1]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[2] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[2]),
        .Q(Q[2]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[3] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[3]),
        .Q(Q[3]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[4] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[4]),
        .Q(Q[4]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[5] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[5]),
        .Q(Q[5]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[6] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[6]),
        .Q(Q[6]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[7] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[7]),
        .Q(Q[7]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[8] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[8]),
        .Q(Q[8]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \adc_out_reg[9] 
       (.C(CLK),
        .CE(drdy),
        .D(adc_data[9]),
        .Q(Q[9]),
        .R(1'b0));
  (* IMPORTED_FROM = "c:/Users/af314/Documents/ECE350-CPU/xadc_testing/xadc_testing.gen/sources_1/ip/xadc_wiz_0/xadc_wiz_0.dcp" *) 
  (* IMPORTED_TYPE = "CHECKPOINT" *) 
  (* IS_IMPORTED *) 
  xadc_wiz_0 xadc_inst
       (.alarm_out(NLW_xadc_inst_alarm_out_UNCONNECTED),
        .busy_out(NLW_xadc_inst_busy_out_UNCONNECTED),
        .channel_out(NLW_xadc_inst_channel_out_UNCONNECTED[4:0]),
        .daddr_in({1'b0,1'b0,1'b1,1'b0,1'b0,1'b1,1'b1}),
        .dclk_in(CLK),
        .den_in(1'b1),
        .di_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .do_out(adc_data),
        .drdy_out(drdy),
        .dwe_in(1'b0),
        .eoc_out(NLW_xadc_inst_eoc_out_UNCONNECTED),
        .eos_out(NLW_xadc_inst_eos_out_UNCONNECTED),
        .reset_in(1'b0),
        .vauxn3(vauxn3),
        .vauxp3(vauxp3),
        .vn_in(1'b0),
        .vp_in(1'b0));
endmodule

module clk_wiz_0
   (clk_out1,
    reset,
    locked,
    clk_in1);
  output clk_out1;
  input reset;
  output locked;
  input clk_in1;

  wire clk_in1;
  wire clk_out1;
  wire reset;
  wire NLW_inst_locked_UNCONNECTED;

  clk_wiz_0_clk_wiz inst
       (.clk_in1(clk_in1),
        .clk_out1(clk_out1),
        .locked(NLW_inst_locked_UNCONNECTED),
        .reset(reset));
endmodule

module clk_wiz_0_clk_wiz
   (clk_out1,
    reset,
    locked,
    clk_in1);
  output clk_out1;
  input reset;
  output locked;
  input clk_in1;

  wire clk_in1;
  wire clk_in1_clk_wiz_0;
  wire clk_out1;
  wire clk_out1_clk_wiz_0;
  wire clkfbout_buf_clk_wiz_0;
  wire clkfbout_clk_wiz_0;
  wire reset;
  wire NLW_plle2_adv_inst_CLKOUT1_UNCONNECTED;
  wire NLW_plle2_adv_inst_CLKOUT2_UNCONNECTED;
  wire NLW_plle2_adv_inst_CLKOUT3_UNCONNECTED;
  wire NLW_plle2_adv_inst_CLKOUT4_UNCONNECTED;
  wire NLW_plle2_adv_inst_CLKOUT5_UNCONNECTED;
  wire NLW_plle2_adv_inst_DRDY_UNCONNECTED;
  wire NLW_plle2_adv_inst_LOCKED_UNCONNECTED;
  wire [15:0]NLW_plle2_adv_inst_DO_UNCONNECTED;

  (* BOX_TYPE = "PRIMITIVE" *) 
  BUFG clkf_buf
       (.I(clkfbout_clk_wiz_0),
        .O(clkfbout_buf_clk_wiz_0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* IFD_DELAY_VALUE = "AUTO" *) 
  IBUF #(
    .IOSTANDARD("DEFAULT")) 
    clkin1_ibufg
       (.I(clk_in1),
        .O(clk_in1_clk_wiz_0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  BUFG clkout1_buf
       (.I(clk_out1_clk_wiz_0),
        .O(clk_out1));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* OPT_MODIFIED = "SWEEP" *) 
  PLLE2_ADV #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT(42),
    .CLKFBOUT_PHASE(0.000000),
    .CLKIN1_PERIOD(10.000000),
    .CLKIN2_PERIOD(0.000000),
    .CLKOUT0_DIVIDE(21),
    .CLKOUT0_DUTY_CYCLE(0.500000),
    .CLKOUT0_PHASE(0.000000),
    .CLKOUT1_DIVIDE(1),
    .CLKOUT1_DUTY_CYCLE(0.500000),
    .CLKOUT1_PHASE(0.000000),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.500000),
    .CLKOUT2_PHASE(0.000000),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.500000),
    .CLKOUT3_PHASE(0.000000),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.500000),
    .CLKOUT4_PHASE(0.000000),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.500000),
    .CLKOUT5_PHASE(0.000000),
    .COMPENSATION("ZHOLD"),
    .DIVCLK_DIVIDE(5),
    .IS_CLKINSEL_INVERTED(1'b0),
    .IS_PWRDWN_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .REF_JITTER1(0.010000),
    .REF_JITTER2(0.010000),
    .STARTUP_WAIT("FALSE")) 
    plle2_adv_inst
       (.CLKFBIN(clkfbout_buf_clk_wiz_0),
        .CLKFBOUT(clkfbout_clk_wiz_0),
        .CLKIN1(clk_in1_clk_wiz_0),
        .CLKIN2(1'b0),
        .CLKINSEL(1'b1),
        .CLKOUT0(clk_out1_clk_wiz_0),
        .CLKOUT1(NLW_plle2_adv_inst_CLKOUT1_UNCONNECTED),
        .CLKOUT2(NLW_plle2_adv_inst_CLKOUT2_UNCONNECTED),
        .CLKOUT3(NLW_plle2_adv_inst_CLKOUT3_UNCONNECTED),
        .CLKOUT4(NLW_plle2_adv_inst_CLKOUT4_UNCONNECTED),
        .CLKOUT5(NLW_plle2_adv_inst_CLKOUT5_UNCONNECTED),
        .DADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .DCLK(1'b0),
        .DEN(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .DO(NLW_plle2_adv_inst_DO_UNCONNECTED[15:0]),
        .DRDY(NLW_plle2_adv_inst_DRDY_UNCONNECTED),
        .DWE(1'b0),
        .LOCKED(NLW_plle2_adv_inst_LOCKED_UNCONNECTED),
        .PWRDWN(1'b0),
        .RST(reset));
endmodule

module xadc_wiz_0
   (daddr_in,
    dclk_in,
    den_in,
    di_in,
    dwe_in,
    reset_in,
    vauxp3,
    vauxn3,
    busy_out,
    channel_out,
    do_out,
    drdy_out,
    eoc_out,
    eos_out,
    alarm_out,
    vp_in,
    vn_in);
  input [6:0]daddr_in;
  input dclk_in;
  input den_in;
  input [15:0]di_in;
  input dwe_in;
  input reset_in;
  input vauxp3;
  input vauxn3;
  output busy_out;
  output [4:0]channel_out;
  output [15:0]do_out;
  output drdy_out;
  output eoc_out;
  output eos_out;
  output alarm_out;
  input vp_in;
  input vn_in;

  wire [6:0]daddr_in;
  wire dclk_in;
  wire den_in;
  wire [15:0]di_in;
  wire [15:0]do_out;
  wire drdy_out;
  wire dwe_in;
  wire reset_in;
  wire vauxn3;
  wire vauxp3;
  wire vn_in;
  wire vp_in;
  wire NLW_inst_BUSY_UNCONNECTED;
  wire NLW_inst_EOC_UNCONNECTED;
  wire NLW_inst_EOS_UNCONNECTED;
  wire NLW_inst_JTAGBUSY_UNCONNECTED;
  wire NLW_inst_JTAGLOCKED_UNCONNECTED;
  wire NLW_inst_JTAGMODIFIED_UNCONNECTED;
  wire NLW_inst_OT_UNCONNECTED;
  wire [7:0]NLW_inst_ALM_UNCONNECTED;
  wire [4:0]NLW_inst_CHANNEL_UNCONNECTED;
  wire [4:0]NLW_inst_MUXADDR_UNCONNECTED;

  (* BOX_TYPE = "PRIMITIVE" *) 
  XADC #(
    .INIT_40(16'h0013),
    .INIT_41(16'h310F),
    .INIT_42(16'h2300),
    .INIT_43(16'h0000),
    .INIT_44(16'h0000),
    .INIT_45(16'h0000),
    .INIT_46(16'h0000),
    .INIT_47(16'h0000),
    .INIT_48(16'h0100),
    .INIT_49(16'h0000),
    .INIT_4A(16'h0000),
    .INIT_4B(16'h0000),
    .INIT_4C(16'h0000),
    .INIT_4D(16'h0000),
    .INIT_4E(16'h0000),
    .INIT_4F(16'h0000),
    .INIT_50(16'hB5ED),
    .INIT_51(16'h57E4),
    .INIT_52(16'hA147),
    .INIT_53(16'hCA33),
    .INIT_54(16'hA93A),
    .INIT_55(16'h52C6),
    .INIT_56(16'h9555),
    .INIT_57(16'hAE4E),
    .INIT_58(16'h5999),
    .INIT_59(16'h0000),
    .INIT_5A(16'h0000),
    .INIT_5B(16'h0000),
    .INIT_5C(16'h5111),
    .INIT_5D(16'h0000),
    .INIT_5E(16'h0000),
    .INIT_5F(16'h0000),
    .IS_CONVSTCLK_INVERTED(1'b0),
    .IS_DCLK_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SIM_MONITOR_FILE("design.txt")) 
    inst
       (.ALM(NLW_inst_ALM_UNCONNECTED[7:0]),
        .BUSY(NLW_inst_BUSY_UNCONNECTED),
        .CHANNEL(NLW_inst_CHANNEL_UNCONNECTED[4:0]),
        .CONVST(1'b0),
        .CONVSTCLK(1'b0),
        .DADDR(daddr_in),
        .DCLK(dclk_in),
        .DEN(den_in),
        .DI(di_in),
        .DO(do_out),
        .DRDY(drdy_out),
        .DWE(dwe_in),
        .EOC(NLW_inst_EOC_UNCONNECTED),
        .EOS(NLW_inst_EOS_UNCONNECTED),
        .JTAGBUSY(NLW_inst_JTAGBUSY_UNCONNECTED),
        .JTAGLOCKED(NLW_inst_JTAGLOCKED_UNCONNECTED),
        .JTAGMODIFIED(NLW_inst_JTAGMODIFIED_UNCONNECTED),
        .MUXADDR(NLW_inst_MUXADDR_UNCONNECTED[4:0]),
        .OT(NLW_inst_OT_UNCONNECTED),
        .RESET(reset_in),
        .VAUXN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,vauxn3,1'b0,1'b0,1'b0}),
        .VAUXP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,vauxp3,1'b0,1'b0,1'b0}),
        .VN(vn_in),
        .VP(vp_in));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
