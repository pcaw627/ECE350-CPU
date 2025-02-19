module nr_div(
    input [31:0] data_operandA,      // dividend (Q)
    input [31:0] data_operandB,      // divisor (M) --> denominator
    input ctrl_DIV,                  // start division signal (remember to add in test case for spamming this guy)
    input clock,                     // clock signal
    output [31:0] data_result,       // final result
    output data_exception,           // division by zero or overflow
    output data_resultRDY           // result ready signal
);

    // first big note that this only works for UNSIGNED integers and we will have to take care of the signs manually

    // internal registers
    wire [31:0] Q_next, Q_current;   // dividend/quotient register
    wire [31:0] M_next, M_current;   // divisor register
    wire [31:0] A_next, A_current;   // accumulator register
    wire [5:0] N_next, N_current;    // counter register (up to 64 because we need up to 33 cycles)
    wire sign_next, sign_current;    // sign register (1 bit)
    
    // detect division by zero
    wire divisor_is_zero;
    assign divisor_is_zero = ~|data_operandB;  // nor reduction
    
    // compute absolute values for inputs
    wire dividend_sign, divisor_sign;
    assign dividend_sign = data_operandA[31];
    assign divisor_sign = data_operandB[31];

    wire [31:0] abs_dividend, abs_divisor;
    assign abs_dividend = dividend_sign ? (~data_operandA + 1) : data_operandA;
    assign abs_divisor = divisor_sign ? (~data_operandB + 1) : data_operandB;
    
    // registers
    register_32 Q_reg(
        .q(Q_current),
        .d(Q_next),
        .clk(clock),
        .en(reg_enable),
        .clr(1'b0)
    );
    
    register_32 M_reg(
        .q(M_current),
        .d(M_next),
        .clk(clock),
        .en(reg_enable),
        .clr(1'b0)
    );
    
    register_32 A_reg(
        .q(A_current),
        .d(A_next),
        .clk(clock),
        .en(reg_enable),
        .clr(1'b0)
    );
    
    register_6 N_reg(
        .q(N_current),
        .d(N_next),
        .clk(clock),
        .en(1'b1),
        .clr(1'b0)
    );

    dffe_ref sign_reg(
        .q(sign_current),
        .d(sign_next),
        .clk(clock),
        .en(start_operation),
        .clr(1'b0)
    );

    // store final sign (different signs <--> negative result)
    assign sign_next = dividend_sign ^ divisor_sign;

    // control signals
    wire start_operation;
    wire operation_in_progress;
    wire operation_complete;
    
    assign start_operation = ctrl_DIV & ~operation_in_progress & ~divisor_is_zero;
    assign operation_in_progress = |N_current;
    assign operation_complete = (N_current == 6'd0);
    assign data_resultRDY = operation_complete | divisor_is_zero;

    // counter mux
    wire [5:0] counter_start, counter_running;
    assign counter_start = 6'd33;
    assign counter_running = N_current - 1;
    assign N_next = start_operation ? counter_start : 
                   operation_in_progress ? counter_running : 
                   6'd0;

    // register enables
    wire reg_enable = start_operation | operation_in_progress;

    // step 1: ALU operation based on current A's sign
    wire [31:0] add_sub_result;
    alu main_alu(
        .data_operandA(A_current),
        .data_operandB(M_current),
        .ctrl_ALUopcode(A_current[31] ? 5'b00000 : 5'b00001),
        .ctrl_shiftamt(5'b00000),
        .data_result(add_sub_result),
        .isNotEqual(),
        .isLessThan(),
        .overflow()
    );

    // step 2: prepare shift values
    wire [31:0] shifted_A, shifted_Q;
    assign shifted_A = {add_sub_result[30:0], Q_current[31]};
    assign shifted_Q = {Q_current[30:0], ~add_sub_result[31]};

    // register next state muxes. 
    wire [31:0] A_start, A_running, A_hold;
    wire [31:0] Q_start, Q_running, Q_hold;
    
    assign A_start = 32'b0;
    assign A_running = shifted_A;
    assign A_hold = A_current;

    assign Q_start = abs_dividend;
    assign Q_running = shifted_Q;
    assign Q_hold = Q_current;

    assign M_next = start_operation ? abs_divisor : M_current;

    wire A_sel_start, A_sel_running;
    assign A_sel_start = start_operation;
    assign A_sel_running = operation_in_progress;

    assign A_next = A_sel_start ? A_start :
                   A_sel_running ? A_running :
                   A_hold;

    wire Q_sel_start, Q_sel_running;
    assign Q_sel_start = start_operation;
    assign Q_sel_running = operation_in_progress;

    assign Q_next = Q_sel_start ? Q_start :
                   Q_sel_running ? Q_running :
                   Q_hold;

    // final result with sign correction
    wire [31:0] unsigned_result, signed_result;
    assign unsigned_result = Q_current;
    assign signed_result = sign_current ? (~unsigned_result + 1) : unsigned_result;
    
    // handle division by zero
    assign data_result = divisor_is_zero ? 32'b0 : signed_result;
    assign data_exception = divisor_is_zero;

endmodule