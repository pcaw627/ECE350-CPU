module and_reduce_32(
    input [31:0] data,
    output result
); // check if any bit in the 32 bit input is 1. (using branch levels to avoid >8input gates)

    wire r1, r2, r3, r4;

    and(r1, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]);
    and(r2, data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
    and(r3, data[16], data[17], data[18], data[19], data[20], data[21], data[22], data[23]);
    and(r4, data[24], data[25], data[26], data[27], data[28], data[29], data[30], data[31]);
    
    and(result, r1, r2, r3, r4);

endmodule