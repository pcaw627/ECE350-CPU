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

    // reg wires
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

    
    wire [31:0] A_2scomp;
    wire [31:0] B_2scomp;
    cla_32 Acomplement(.Sum(A_2scomp), .Cout(), .A(~data_operandA), .B(32'd1), .Cin(1'b0), .signed_ovf());
    cla_32 Bcomplement(.Sum(B_2scomp), .Cout(), .A(~data_operandB), .B(32'd1), .Cin(1'b0), .signed_ovf());

    wire [31:0] abs_dividend, abs_divisor;

    assign abs_dividend = dividend_sign ? A_2scomp : data_operandA;
    assign abs_divisor = divisor_sign ? B_2scomp : data_operandB;
    
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

    // counter mux (either start at 33 or decrement current value)
    wire [5:0] counter_start, counter_running;
    assign counter_start = 6'd33;
    wire [7:0] N_current_padded;
    wire [7:0] counter_full_padded;
    assign N_current_padded = {2'b00, N_current}; 

    cla_8 Ndecrement(.Sum(counter_full_padded), .Cout(), .A(N_current_padded), .B(8'hFF), .Cin(1'b0), .signed_ovf());
    assign counter_running = counter_full_padded[5:0];

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


    // finite state machine (https://people.ee.duke.edu/~jab/ece350/Protected/Lecture%209.pdf p15)
    // M (divisor, denominator) register - load on start, hold otherwise
    assign M_next = start_operation ? abs_divisor : M_current;

    // A (accumulator) register - clear on start, update during operation, hold otherwise
    assign A_next = start_operation ? 32'b0 :
                   operation_in_progress ? shifted_A :
                   A_current;

    // Q (quotient) register - load dividend on start, update during operation, hold otherwise
    assign Q_next = start_operation ? abs_dividend :
                   operation_in_progress ? shifted_Q :
                   Q_current;


    // final result with sign correction    
    wire [31:0] us_result_2scomp;
    cla_32 result_complement(.Sum(us_result_2scomp), .Cout(), .A(~unsigned_result), .B(32'd1), .Cin(1'b0), .signed_ovf());

    wire [31:0] unsigned_result, signed_result;
    assign unsigned_result = Q_current;
    assign signed_result = sign_current ? us_result_2scomp : unsigned_result;
    
    // handle division by zero
    assign data_result = divisor_is_zero ? 32'b0 : signed_result;
    assign data_exception = divisor_is_zero;

endmodule