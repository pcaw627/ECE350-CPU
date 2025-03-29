module rotate_left_by_S_5 (
    input [4:0] d,
    input clk, 
    input clr,
    input [2:0] s,
    output [4:0] q
);

    assign q = (s == 3'd0) ? d :
                {d[(4-s):0], d[4:(4-s+1)]};

endmodule