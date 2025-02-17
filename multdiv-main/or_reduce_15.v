module or_reduce_15(
    input [14:0] data,
    output result
); // check if any bit in the 15 bit input is 1. (using branch levels to avoid >8input gates)

    wire r1, r2, r3;

    or(r1, data[0], data[1], data[2], data[3], data[4]);
    or(r2, data[5], data[6], data[7], data[8], data[9]);
    or(r3, data[10], data[11], data[12], data[13], data[14]);
    or(result, r1, r2, r3);

endmodule