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

    wire sr1_out, sr2_out;
    sr_latch sr1(.Q(sr1_out), .Q_not(), .S(dff1_dff2_out), .R(level_counter_ovf && idx_counter_ovf), .clk(clk));
       
    dff dff3(.q(dff3_out), .d(~sr1_out), .p(dff1_dff2_out), .clk(clock), .clr(1'b0), .en(1'b1));
    dff dff4(.q(dff4_out), .d(dff3_out), .p(dff1_dff2_out), .clk(clock), .clr(1'b0), .en(1'b1));
    dffe_ref dff5(.q(dff5_out), .d(~sr2_out && sr1_out), .clk(clock), .clr(dff4_out), .en(1'b1));
    dffe_ref dff6(.q(dff6_out), .d(dff4_out), .clk(clock), .clr(1'b0), .en(1'b1));
    dffe_ref dff7(.q(dff7_out), .d(dff5_out), .clk(clock), .clr(dff4_out), .en(1'b1));
    dffe_ref dff8(.q(dff8_out), .d(dff7_out), .clk(clock), .clr(1'b0), .en(1'b1));
    
    assign clear_hold = dff8_out;
    assign FFT_done = dff8_out;
    assign mem_write = dff7_out;

    
    wire [3:0] idx_counter_out;
    wire idx_counter_ovf;
    counter4 idx_counter (.count(idx_counter_out), .clk(clock), .clr(clear_hold || sr2_out), .en(1'b1), .cout(idx_counter_ovf));

    wire dff_idx_overflow_out;
    dffe_ref dff_idx_overflow (.q(dff_idx_overflow_out), .d(idx_counter_ovf), .clk(clock), .clr(1'b0), .en(1'b1));

    
    wire [3:0] writehold_counter_out;
    wire writehold_counter_ovf;
    counter4 writehold_counter (.count(idx_counter_out), .clk(clock), .clr(~sr2_out), .en(1'b1), .cout(writehold_counter_ovf));

    sr_latch sr2 (.Q(sr2_out), .Q_not(), .S(idx_counter_ovf), .R(writehold_counter_ovf), .clk(clk));


    wire [2:0] level_counter_out;
    wire level_counter_ovf;
    mod5counter3 level_counter(.clk(dff_idx_overflow_out), .clr(clear_hold), .cout(level_counter_ovf), .out(level_counter_out));



    wire [4:0] scd_top_in = {idx_counter_out, 1'b0};
    wire [4:0] scd_middle_latency_sum_in = {idx_counter_out, 1'b1};
    wire [4:0] scd_top_out, scd_middle_latency_sum_out;
    wire [2:0] scd_bottom_out;
    single_clock_delay  #(parameter WIDTH=5) scd_top (.q(scd_top_out), .d(scd_top_in), .clr(clear_hold), .clk(clock));
    single_clock_delay  #(parameter WIDTH=3) scd_bottom (.q(scd_bottom_out), .d(level_counter_out), .clr(clear_hold), .clk(clock));
    single_clock_delay  #(parameter WIDTH=5) scd_middle_latency_sum (.q(scd_middle_latency_sum_out), .d(scd_middle_latency_sum_in), .clr(clear_hold), .clk(clock));


    rotate_left_by_S_5 r5_top (.clk(clock), .clr(clear_hold), .s(scd_bottom_out), .d(scd_top_out), .q(MemA_address));
    rotate_left_by_S_5 r5_bottom (.clk(clock), .clr(clear_hold), .s(scd_bottom_out), .d(scd_middle_latency_sum_out), .q(MemB_address));

    wire [3:0] twiddle_out;
    twiddle_mask_gen twiddle_gen (.clk(dff_idx_overflow_out), .clr(clear_hold), .en(1'b1), .out(twiddle_out));

    assign twiddle_address = twiddle_out && idx_counter_out;    



endmodule