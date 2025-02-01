
module comp_mux_4(out, select, in0, in1, in2, in3);
    input [1:0] select;
    input in0, in1, in2, in3;
    output out;
    wire w1, w2;

    comp_mux_2 first_top(w1, select[0], in0, in1);
    comp_mux_2 first_bottom(w2, select[0], in2, in3);
    comp_mux_2 second(out, select[1], w1, w2);

endmodule