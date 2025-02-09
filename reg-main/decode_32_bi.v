module decoder_32bit (
    input [4:0] in,     // 5-bit input to select one of 32 outputs
    output [31:0] out   // 32-bit one-hot output
);

    // first level, select will be first two bits of in
    wire [3:0] sel_group;
    
    decoder_2to4 first_level (
        .in(in[4:3]),
        .out(sel_group)
    );

    // second level - last 3 bits of in
    wire [7:0] sel_subgroup;
    
    decoder_3to8 second_level (
        .in(in[2:0]),
        .out(sel_subgroup)
    );

    // AND together outputs based on both selects (second level branches off first in a tree way)
    generate
        genvar i, j;
        for (i = 0; i < 4; i = i + 1) begin : group
            for (j = 0; j < 8; j = j + 1) begin : subgroup
                assign out[i * 8 + j] = sel_group[i] & sel_subgroup[j];
            end
        end
    endgenerate

endmodule

// 2-to-4 decoder (for first two of in) (actually maybe move these guys to their own files so they can be reused)
module decoder_2to4 (
    input [1:0] in,
    output [3:0] out
);
    assign out[0] = ~in[1] & ~in[0];
    assign out[1] = ~in[1] &  in[0];
    assign out[2] =  in[1] & ~in[0];
    assign out[3] =  in[1] &  in[0];
endmodule

// 3-to-8 decoder (last three of in)
module decoder_3to8 (
    input [2:0] in,
    output [7:0] out
);
    assign out[0] = ~in[2] & ~in[1] & ~in[0];
    assign out[1] = ~in[2] & ~in[1] &  in[0];
    assign out[2] = ~in[2] &  in[1] & ~in[0];
    assign out[3] = ~in[2] &  in[1] &  in[0];
    assign out[4] =  in[2] & ~in[1] & ~in[0];
    assign out[5] =  in[2] & ~in[1] &  in[0];
    assign out[6] =  in[2] &  in[1] & ~in[0];
    assign out[7] =  in[2] &  in[1] &  in[0];
endmodule