module sdf_inv_fft #(
   parameter N=64,
   parameter M=64,
   parameter WIDTH=16
) (
    input clock, reset, data_in_en, 
    output data_out_en,
    input [WIDTH-1:0] data_in_real, data_in_imag,
    output [WIDTH-1:0] data_out_real, data_out_imag
);

    function integer log2;
        input integer x;
        integer value;

        begin
            value = x-1;
            for (log2=0; value>0; log2=log2+1)
                value = value>>1;
        end
    endfunction

    // find conjugate of input (keep data_in_real the same, then negate data_in_neg_imag)
    wire [WIDTH-1:0] data_in_neg_imag = -data_in_imag;

    // compute FFT
    module sdf_fft #(
    .N(N), .M(M), .WIDTH(WIDTH)
    ) (
        .clock(clock), .reset(reset), .data_in_en(data_in_en), 
        .data_out_en(data_out_en),
        .data_in_real(data_in_real), .data_in_imag(data_in_neg_imag),
        .data_out_real(N_times_data_out_real), .data_out_neg_imag(N_times_data_out_neg_imag)
    );  

    // find conjugate of output (keep data_out_real the same, then negate data_out_neg_imag)
    wire [WIDTH-1:0] N_times_data_out_imag = -N_times_data_out_neg_imag;

    // divide output conjugate by N (so left shift by logN)

    localparam LOG_N = log2(N);
    assign data_out_real = N_times_data_out_real >> LOG_N;
    assign data_out_imag = N_times_data_out_imag >> LOG_N;

endmodule