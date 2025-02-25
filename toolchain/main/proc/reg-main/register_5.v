module register_5 (
    output [4:0] q,
    input [4:0] d,
    input clk, 
    input en, 
    input clr);
   
   // each register is made up of 5 one-bit d flip flops, one dff assigned to each pin of register. 
   genvar i;
   generate
        for (i=0; i<5; i=i+1) begin
            // module dffe_ref (q, d, clk, en, clr);
            dffe_ref dff(.q(q[i]), .d(d[i]), .clk(clk), .en(en), .clr(clr));
        end

   endgenerate
endmodule
