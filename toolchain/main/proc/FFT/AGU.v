module AGU (
    input start_FFT,
    input clock,
    output [4:0] MemA_address,
    output [4:0] MemB_address,
    output [3:0] twiddle_address,
    output mem_write,
    output FFT_done);

    wire clear_hold, dff1_out, dff2_out, dff3_out, dff4_out, dff5_out, dff6_out, dff7_out, dff8_out, dff9_out;

    // DFF Chain
    // # dffs named from left to right, bottom to top
    dffe_ref dff1(.q(dff1_out), .d(start_FFT), .clk(clock), .clr(1'b0), .en(1'b1));
    dffe_ref dff2(.q(dff2_out), .d(dff1_out), .clk(clock), .clr(1'b0), .en(1'b1));
    
    wire dff1_dff2_out;
    and(dff1_dff2_out, dff1_out, ~dff2_out);

    wire sr_1_out;
    sr_latch sr1(.Q(sr_1_out), .Q_not(), .S(dff1_dff2_out), .R(****));
       
    dff dff3(.q(dff3_out), .d(~sr_1_out), .p(dff1_dff2_out), .clk(clock), .clr(1'b0), .en(1'b1));
    dff dff4(.q(dff4_out), .d(dff3_out), .p(dff1_dff2_out), .clk(clock), .clr(1'b0), .en(1'b1));
    dffe_ref dff5(.q(dff5_out), .d(*****), .clk(clock), .clr(dff4_out), .en(1'b1));
    dffe_ref dff6(.q(dff6_out), .d(dff4_out), .clk(clock), .clr(1'b0), .en(1'b1));
    dffe_ref dff7(.q(dff7_out), .d(dff5_out), .clk(clock), .clr(dff4_out), .en(1'b1));
    dffe_ref dff8(.q(dff8_out), .d(dff7_out), .clk(clock), .clr(1'b0), .en(1'b1));
    
    assign clear_hold = dff8_out;
    assign FFT_done = dff8_out;

    01234567
    01234012
    
    





endmodule