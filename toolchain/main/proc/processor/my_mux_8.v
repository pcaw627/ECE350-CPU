//assign ternary_output = cond ? High : Low;
//      Thw ternary operator is a simple construction that passes on the “High” wire 
//      if the cond wire is asserted and “Low” wire if the cond wire is not asserted

module my_mux_8(data_result, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input [4:0] select;                       // only need to use 0-2 for 8 bit mux because only go up to 00101 for SRA
    input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    output [31:0] data_result;
    wire [31:0] left0, left1, left2, left3;   // left muxes
    wire [31:0] middle0, middle1;             // middle muxes
    wire [31:0] right;                        // final (right) mux

    // left 2bit muxes using first select bit
    assign left0 = select[0] ? in1 : in0;
    assign left1 = select[0] ? in3 : in2;
    assign left2 = select[0] ? in5 : in4;
    assign left3 = select[0] ? in7 : in6;

    // middle 2bit muxes using second select bit
    assign middle0 = select[1] ? left1 : left0;
    assign middle1 = select[1] ? left3 : left2;

    // final 2bit mux using third select bit
    assign right = select[2] ? middle1 : middle0;


    assign data_result = right;

endmodule
