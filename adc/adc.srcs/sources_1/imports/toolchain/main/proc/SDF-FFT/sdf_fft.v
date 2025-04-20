module sdf_fft #(
   parameter N=64,
   parameter M=64,
   parameter WIDTH=16
) (
    input clock, reset, data_in_en, 
    output data_out_en,
    input [WIDTH-1:0] data_in_real, data_in_imag,
    output [WIDTH-1:0] data_out_real, data_out_imag
);

// https://ocw.mit.edu/courses/6-973-communication-system-design-spring-2006/1460f43d3993b7c956d4bb8ee03d1fb0_lecture_10.pdf



//----------------------------------------------------------------------
//  Data must be input consecutively in natural order.
//  The result is scaled to 1/N and output in bit-reversed order.
//  The output latency is 71 clock cycles.
//----------------------------------------------------------------------

wire su1_data_out_en, su2_data_out_en;
wire [WIDTH-1:0] su1_data_out_real, su1_data_out_imag, su2_data_out_real, su2_data_out_imag;

sdf #(.N(N),.M(M),.WIDTH(WIDTH)) SU1 (
    .clock(clock),
    .reset(reset),
    .data_in_en(data_in_en),
    .data_in_real(data_in_real),
    .data_in_imag(data_in_imag),
    .data_out_en(su1_data_out_en),
    .data_out_real(su1_data_out_real),
    .data_out_imag(su1_data_out_imag) 
);

sdf #(.N(N),.M(M>>2),.WIDTH(WIDTH)) SU2 (
    .clock(clock),
    .reset(reset),
    .data_in_en(su1_data_out_en),
    .data_in_real(su1_data_out_real),
    .data_in_imag(su1_data_out_imag),
    .data_out_en(su2_data_out_en),
    .data_out_real(su2_data_out_real),
    .data_out_imag(su2_data_out_imag) 
);

sdf #(.N(N),.M(M>>4),.WIDTH(WIDTH)) SU3 (
    .clock(clock),
    .reset(reset),
    .data_in_en(su2_data_out_en),
    .data_in_real(su2_data_out_real),
    .data_in_imag(su2_data_out_imag),
    .data_out_en(data_out_en),
    .data_out_real(data_out_real),
    .data_out_imag(data_out_imag) 
);




endmodule