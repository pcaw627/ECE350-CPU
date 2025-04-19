//----------------------------------------------------------------------
//  Twiddle: 64-Point Twiddle Table for Radix-2^2 Butterfly
//----------------------------------------------------------------------
module Twiddle64 #(
    parameter   TW_FF = 1 //  Use Output Register
)(
    input clock,
    input [5:0] addr,  // Twiddle Factor Number
    output [15:0] tw_real_out,  // Twiddle Factor Real
    output [15:0] tw_imag_out  // Twiddle Factor Imag
);

wire[15:0] tw_real[0:63]; // Twiddle Table (Real)
wire[15:0] tw_imag[0:63]; //  Twiddle Table (Imag)
wire[15:0] mux_real;  //  Mux output (Real)
wire[15:0] mux_imag;  //  Mux output (Imag)
reg [15:0] ff_real;  //  Register output (Real)
reg [15:0] ff_imag;  //  Register output (Imag)

assign  mux_real = tw_real[addr];
assign  mux_imag = tw_imag[addr];

always @(posedge clock) begin
    ff_real <= mux_real;
    ff_imag <= mux_imag;
end

assign  tw_real_out = TW_FF ? ff_real : mux_real;
assign  tw_imag_out = TW_FF ? ff_imag : mux_imag;

//----------------------------------------------------------------------
//  Twiddle Factor Value
//----------------------------------------------------------------------
//  Multiplication is bypassed when twiddle address is 0.
//  Setting tw_real[0] = 0 and tw_imag[0] = 0 makes it easier to check the waveform.
//  It may also reduce power consumption slightly.
//
//      tw_real = cos(-2pi*n/64)          tw_imag = sin(-2pi*n/64)
assign  tw_real[ 0] = 16'h0000;   assign  tw_imag[ 0] = 16'h0000;   //  0  1.000 -0.000
assign  tw_real[ 1] = 16'h7F62;   assign  tw_imag[ 1] = 16'hF374;   //  1  0.995 -0.098
assign  tw_real[ 2] = 16'h7D8A;   assign  tw_imag[ 2] = 16'hE707;   //  2  0.981 -0.195
assign  tw_real[ 3] = 16'h7A7D;   assign  tw_imag[ 3] = 16'hDAD8;   //  3  0.957 -0.290
assign  tw_real[ 4] = 16'h7642;   assign  tw_imag[ 4] = 16'hCF04;   //  4  0.924 -0.383
assign  tw_real[ 5] = 16'h70E3;   assign  tw_imag[ 5] = 16'hC3A9;   //  5  0.882 -0.471
assign  tw_real[ 6] = 16'h6A6E;   assign  tw_imag[ 6] = 16'hB8E3;   //  6  0.831 -0.556
assign  tw_real[ 7] = 16'h62F2;   assign  tw_imag[ 7] = 16'hAECC;   //  7  0.773 -0.634
assign  tw_real[ 8] = 16'h5A82;   assign  tw_imag[ 8] = 16'hA57E;   //  8  0.707 -0.707
assign  tw_real[ 9] = 16'h5134;   assign  tw_imag[ 9] = 16'h9D0E;   //  9  0.634 -0.773
assign  tw_real[10] = 16'h471D;   assign  tw_imag[10] = 16'h9592;   // 10  0.556 -0.831
assign  tw_real[11] = 16'h3C57;   assign  tw_imag[11] = 16'h8F1D;   // 11  0.471 -0.882
assign  tw_real[12] = 16'h30FC;   assign  tw_imag[12] = 16'h89BE;   // 12  0.383 -0.924
assign  tw_real[13] = 16'h2528;   assign  tw_imag[13] = 16'h8583;   // 13  0.290 -0.957
assign  tw_real[14] = 16'h18F9;   assign  tw_imag[14] = 16'h8276;   // 14  0.195 -0.981
assign  tw_real[15] = 16'h0C8C;   assign  tw_imag[15] = 16'h809E;   // 15  0.098 -0.995
assign  tw_real[16] = 16'h0000;   assign  tw_imag[16] = 16'h8000;   // 16  0.000 -1.000
assign  tw_real[17] = 16'hxxxx;   assign  tw_imag[17] = 16'hxxxx;   // 17 -0.098 -0.995
assign  tw_real[18] = 16'hE707;   assign  tw_imag[18] = 16'h8276;   // 18 -0.195 -0.981
assign  tw_real[19] = 16'hxxxx;   assign  tw_imag[19] = 16'hxxxx;   // 19 -0.290 -0.957
assign  tw_real[20] = 16'hCF04;   assign  tw_imag[20] = 16'h89BE;   // 20 -0.383 -0.924
assign  tw_real[21] = 16'hC3A9;   assign  tw_imag[21] = 16'h8F1D;   // 21 -0.471 -0.882
assign  tw_real[22] = 16'hB8E3;   assign  tw_imag[22] = 16'h9592;   // 22 -0.556 -0.831
assign  tw_real[23] = 16'hxxxx;   assign  tw_imag[23] = 16'hxxxx;   // 23 -0.634 -0.773
assign  tw_real[24] = 16'hA57E;   assign  tw_imag[24] = 16'hA57E;   // 24 -0.707 -0.707
assign  tw_real[25] = 16'hxxxx;   assign  tw_imag[25] = 16'hxxxx;   // 25 -0.773 -0.634
assign  tw_real[26] = 16'h9592;   assign  tw_imag[26] = 16'hB8E3;   // 26 -0.831 -0.556
assign  tw_real[27] = 16'h8F1D;   assign  tw_imag[27] = 16'hC3A9;   // 27 -0.882 -0.471
assign  tw_real[28] = 16'h89BE;   assign  tw_imag[28] = 16'hCF04;   // 28 -0.924 -0.383
assign  tw_real[29] = 16'hxxxx;   assign  tw_imag[29] = 16'hxxxx;   // 29 -0.957 -0.290
assign  tw_real[30] = 16'h8276;   assign  tw_imag[30] = 16'hE707;   // 30 -0.981 -0.195
assign  tw_real[31] = 16'hxxxx;   assign  tw_imag[31] = 16'hxxxx;   // 31 -0.995 -0.098
assign  tw_real[32] = 16'hxxxx;   assign  tw_imag[32] = 16'hxxxx;   // 32 -1.000 -0.000
assign  tw_real[33] = 16'h809E;   assign  tw_imag[33] = 16'h0C8C;   // 33 -0.995  0.098
assign  tw_real[34] = 16'hxxxx;   assign  tw_imag[34] = 16'hxxxx;   // 34 -0.981  0.195
assign  tw_real[35] = 16'hxxxx;   assign  tw_imag[35] = 16'hxxxx;   // 35 -0.957  0.290
assign  tw_real[36] = 16'h89BE;   assign  tw_imag[36] = 16'h30FC;   // 36 -0.924  0.383
assign  tw_real[37] = 16'hxxxx;   assign  tw_imag[37] = 16'hxxxx;   // 37 -0.882  0.471
assign  tw_real[38] = 16'hxxxx;   assign  tw_imag[38] = 16'hxxxx;   // 38 -0.831  0.556
assign  tw_real[39] = 16'h9D0E;   assign  tw_imag[39] = 16'h5134;   // 39 -0.773  0.634
assign  tw_real[40] = 16'hxxxx;   assign  tw_imag[40] = 16'hxxxx;   // 40 -0.707  0.707
assign  tw_real[41] = 16'hxxxx;   assign  tw_imag[41] = 16'hxxxx;   // 41 -0.634  0.773
assign  tw_real[42] = 16'hB8E3;   assign  tw_imag[42] = 16'h6A6E;   // 42 -0.556  0.831
assign  tw_real[43] = 16'hxxxx;   assign  tw_imag[43] = 16'hxxxx;   // 43 -0.471  0.882
assign  tw_real[44] = 16'hxxxx;   assign  tw_imag[44] = 16'hxxxx;   // 44 -0.383  0.924
assign  tw_real[45] = 16'hDAD8;   assign  tw_imag[45] = 16'h7A7D;   // 45 -0.290  0.957
assign  tw_real[46] = 16'hxxxx;   assign  tw_imag[46] = 16'hxxxx;   // 46 -0.195  0.981
assign  tw_real[47] = 16'hxxxx;   assign  tw_imag[47] = 16'hxxxx;   // 47 -0.098  0.995
assign  tw_real[48] = 16'hxxxx;   assign  tw_imag[48] = 16'hxxxx;   // 48 -0.000  1.000
assign  tw_real[49] = 16'hxxxx;   assign  tw_imag[49] = 16'hxxxx;   // 49  0.098  0.995
assign  tw_real[50] = 16'hxxxx;   assign  tw_imag[50] = 16'hxxxx;   // 50  0.195  0.981
assign  tw_real[51] = 16'hxxxx;   assign  tw_imag[51] = 16'hxxxx;   // 51  0.290  0.957
assign  tw_real[52] = 16'hxxxx;   assign  tw_imag[52] = 16'hxxxx;   // 52  0.383  0.924
assign  tw_real[53] = 16'hxxxx;   assign  tw_imag[53] = 16'hxxxx;   // 53  0.471  0.882
assign  tw_real[54] = 16'hxxxx;   assign  tw_imag[54] = 16'hxxxx;   // 54  0.556  0.831
assign  tw_real[55] = 16'hxxxx;   assign  tw_imag[55] = 16'hxxxx;   // 55  0.634  0.773
assign  tw_real[56] = 16'hxxxx;   assign  tw_imag[56] = 16'hxxxx;   // 56  0.707  0.707
assign  tw_real[57] = 16'hxxxx;   assign  tw_imag[57] = 16'hxxxx;   // 57  0.773  0.634
assign  tw_real[58] = 16'hxxxx;   assign  tw_imag[58] = 16'hxxxx;   // 58  0.831  0.556
assign  tw_real[59] = 16'hxxxx;   assign  tw_imag[59] = 16'hxxxx;   // 59  0.882  0.471
assign  tw_real[60] = 16'hxxxx;   assign  tw_imag[60] = 16'hxxxx;   // 60  0.924  0.383
assign  tw_real[61] = 16'hxxxx;   assign  tw_imag[61] = 16'hxxxx;   // 61  0.957  0.290
assign  tw_real[62] = 16'hxxxx;   assign  tw_imag[62] = 16'hxxxx;   // 62  0.981  0.195
assign  tw_real[63] = 16'hxxxx;   assign  tw_imag[63] = 16'hxxxx;   // 63  0.995  0.098

endmodule
