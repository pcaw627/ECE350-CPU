module decode_32_tri (
    input [4:0] select,      // 5-bit input to select one of 32 outputs
    output [31:0] out    // 32-bit output (one-hot 1 and the rest Z)
);

    // do one tri-state buffer per output bit.
    generate
        genvar i;
        for (i = 0; i < 32; i = i + 1) begin : tri_buffers
            // each output is 1 when its select is on (when in(decimal) == i)
            // otherwise Z (lets us link up reg qs directly to same output pin without short)
            assign out[i] = (select == i) ? 1'b1 : 1'b0; //1'bz;
        end
    endgenerate

endmodule


// iverilog -o reg-main/decode_32_tri -c reg-main/decode_32_tri_FileList.txt -Wimplicit
// vvp .\reg-main\decode_32_tri