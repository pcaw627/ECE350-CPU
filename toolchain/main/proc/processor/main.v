module main(button, clock, light, count);
    input clock;
    input button;
    output light;
    output [2:0] count;


    wire clear;

    counter3 counter(count, clock, clear, (button == 1'b1));


    assign clear = (count == 3'b101) ? 1'b1 : 1'b0;
    assign light = (count == 3'b100) ? 1'b1: 1'b0;



endmodule