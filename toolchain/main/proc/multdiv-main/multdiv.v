module multdiv(
    data_operandA, data_operandB, 
    ctrl_MULT, ctrl_DIV, 
    clock, 
    data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // track last operation (0 for mult, 1 for div)- see ed post #201
    wire [31:0] last_op_next, last_op_current;
    wire last_op_en;

    // Enable the last_op register when either operation starts
    or(last_op_en, ctrl_MULT, ctrl_DIV);
    
    // next state is all 1's if div is called, all 0's if mult is called
    assign last_op_next = ctrl_DIV ? 32'hFFFFFFFF : 32'h00000000;

    // register to store last operation
    register_32 last_op_reg(
        .q(last_op_current),
        .d(last_op_next),
        .clk(clock),
        .en(last_op_en),
        .clr(1'b0)
    );

    // Input checking logic
    wire Aisnonzero, Bisnonzero, autozero;
    or_reduce_32 orA (.result(Aisnonzero), .data(data_operandA));
    or_reduce_32 orB (.result(Bisnonzero), .data(data_operandB));
    or (autozero, Aisnonzero, Bisnonzero);

    // mult logic
    wire [31:0] mult_result_lo;
    wire [31:0] mult_result_hi;
    wire mult_ovf;
    wallace_32 wtree(
        .a(data_operandA), 
        .b(data_operandB), 
        .product_hi(mult_result_hi), 
        .product_lo(mult_result_lo), 
        .ovf(mult_ovf)
    );

    // div logic
    wire [31:0] div_result;
    wire div_exception;
    wire div_resultRDY;

    nr_div divider(
        .data_operandA(data_operandA),
        .data_operandB(data_operandB),
        .ctrl_DIV(ctrl_DIV),
        .clock(clock),
        .data_result(div_result),
        .data_exception(div_exception),
        .data_resultRDY(div_resultRDY)
    );


    // use msb of last_op_current to see which operation was last
    wire is_last_op_div;
    assign is_last_op_div = last_op_current[31];

    // exception handling - changed to muxing like the rest
    assign data_exception = is_last_op_div ? div_exception : mult_ovf;

    // result muxing based on last operation
    assign data_result = is_last_op_div ? div_result : mult_result_lo;

    // Ready signal muxing based on last operation
    wire mult_ready;
    assign mult_ready = 1'b1; // mult always ready in one cycle
    
    // Final ready signal is based on last operation
    assign data_resultRDY = is_last_op_div ? div_resultRDY : mult_ready;

endmodule