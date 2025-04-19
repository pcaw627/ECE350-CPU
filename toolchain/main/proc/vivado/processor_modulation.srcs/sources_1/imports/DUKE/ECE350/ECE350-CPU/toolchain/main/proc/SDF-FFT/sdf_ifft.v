module sdf_ifft #(
parameter N = 64,
parameter M = 64,
parameter WIDTH = 16
)(
input clock,
input reset,
input data_in_en,
input [WIDTH-1:0] data_in_real,
input [WIDTH-1:0] data_in_imag,
output data_out_en,
output [WIDTH-1:0] data_out_real,
output [WIDTH-1:0] data_out_imag
);

// Feed the forward FFT with the *swapped* streams
wire fft_valid;
wire [WIDTH-1:0] fft_re, fft_im;

sdf_fft #(.N(N), .M(M), .WIDTH(WIDTH)) fwd_fft (
.clock (clock),
.reset (reset),
.data_in_en (data_in_en),
.data_in_real(data_in_imag), // <-- data_in_imag
.data_in_imag(data_in_real), // <-- data_in_real
.data_out_en (fft_valid),
.data_out_real(fft_re),
.data_out_imag(fft_im)
);

// 2. Swap again and scale by 1/N
function integer log2;
input integer x;
integer value;

begin
value = x-1;
for (log2=0; value>0; log2=log2+1)
value = value>>1;
end
endfunction

localparam integer SHIFT = log2(N); // 6 for N=64

// Sign‑extend before the arithmetic shift and reroute outputs
wire signed [WIDTH:0] real_ext = {fft_im[WIDTH-1], fft_im}; // imag -> real
wire signed [WIDTH:0] imag_ext = {fft_re[WIDTH-1], fft_re}; // real -> imag

wire signed [WIDTH:0] tmp_real = real_ext <<< SHIFT;
wire signed [WIDTH:0] tmp_imag = imag_ext <<< SHIFT;

// saturate to ±32767
function [WIDTH-1:0] sat16;
input signed [WIDTH:0] x;
begin
if (x > 17'sh07FFF) sat16 = 16'h7FFF; // +32767
else if (x < -17'sh08000) sat16 = 16'h8000; // -32768
else sat16 = x[WIDTH-1:0];
end
endfunction

assign data_out_en = fft_valid;
assign data_out_real = sat16(tmp_real);
assign data_out_imag = sat16(tmp_imag);



endmodule