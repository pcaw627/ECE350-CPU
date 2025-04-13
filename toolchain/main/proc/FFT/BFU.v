module BFU (
    input [15:0] wreal_in, input [15:0] wcomplex_in, 
    input [15:0] Breal_in, input [15:0] Bcomplex_in, 
    input [15:0] Areal_in, input [15:0] Acomplex_in, 
    output [15:0] Aprime_complex_out, output [15:0] Bprime_complex_out, output [15:0] Aprime_real_out, output [15:0] Bprime_real_out
);

    // TODO: Make mux slower (add one cycle delay, see fine print note on page 18)

    wire [15:0] wR_times_BR, wR_times_BC, BR_times_wC, BC_times_wC;
    wire [31:0] wB_RR, wB_CC, wB_RC, wB_CR, wB_R, wB_C;

    wallace_16 wR_times_BR_multiplier(
        .a(wreal_in),
        .b(Breal_in),
        .product(wB_RR),
        .product_hi(),
        .product_lo(),
        .ovf()
    );  

    wallace_16 wC_times_BC_multiplier(
        .a(wcomplex_in),
        .b(Bcomplex_in),
        .product(wB_CC),
        .product_hi(),
        .product_lo(),
        .ovf()
    );  

    wallace_16 wR_times_BC_multiplier(
        .a(wreal_in),
        .b(Bcomplex_in),
        .product(wB_RC),
        .product_hi(),
        .product_lo(),
        .ovf()
    );  

    wallace_16 wC_times_BR_multiplier(
        .a(wcomplex_in),
        .b(Breal_in),
        .product(wB_CR),
        .product_hi(),
        .product_lo(),
        .ovf()
    ); 

    // assign wB_R = wB_RR - wB_CC;
    cla_32 wB_R_cla(
        .A(wB_RR),
        .B(~wB_CC),
        .Cin(1'b1),
        .Sum(wB_R),
        .Cout(),
        .signed_ovf()
    );

    // assign wB_C = wB_CR + wB_RC;
    cla_32 wB_C_cla(
        .A(wB_RC),
        .B(wB_CR),
        .Cin(1'b0),
        .Sum(wB_C),
        .Cout(),
        .signed_ovf()
    );

    // will overflows go into the 5 extra bits? what exactly do those 5 extra bits in paper do?
    // what 11 bits???

    wire [15:0] wB_R_upper, wB_C_upper;
    assign wB_R_upper = wB_R[30:15];
    assign wB_C_upper = wB_C[30:15];

    // Aprimereal = Areal + wbupperR
    cla_16 Aprimereal_cla(
        .A(Areal_in),
        .B(wB_R_upper),
        .Cin(1'b0),
        .Sum(Aprime_real_out),
        .Cout(),
        .signed_ovf()
    );

    // Aprimecomplex = Acomplex + wbuppeC
    cla_16 Aprimecomplex_cla(
        .A(Acomplex_in),
        .B(wB_C_upper),
        .Cin(1'b0),
        .Sum(Aprime_complex_out),
        .Cout(),
        .signed_ovf()
    );

    // Bprimereal = Areal - wbupperR
    cla_16 Bprimereal_cla(
        .A(Areal_in),
        .B(~wB_R_upper),
        .Cin(1'b1),
        .Sum(Bprime_real_out),
        .Cout(),
        .signed_ovf()
    );

    // Bprimecomplex = Acomplex - wbupperC
    cla_16 Bprimecomplex_cla(
        .A(Acomplex_in),
        .B(~wB_C_upper),
        .Cin(1'b1),
        .Sum(Bprime_complex_out),
        .Cout(),
        .signed_ovf()
    );

    // iverilog -o BFU -s BFU_tb -c FileList.txt; vvp .\BFU
    // gtkwave .\BFU.vcd



endmodule