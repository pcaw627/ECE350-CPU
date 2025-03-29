module sr_latch(
    input wire S, R,
    output wire Q, Q_not);

    assign Q = ~(R | Q_not);
    assign Q0 = ~(S | Q);

endmodule