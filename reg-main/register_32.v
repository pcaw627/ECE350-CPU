module register_32 (
    output [31:0] q,
    input [31:0] d,
    input clk, 
    input en, 
    input clr);
   
   // each register is made up of 32 one-bit d flip flops, one dff assigned to each pin of register. 
   genvar i;
   generate
        for (i=0 i<32; i=i+1) begin loop1;
            // module dffe_ref (q, d, clk, en, clr);
            dffe_ref dff(.q(q[i]), .d(d[i]), .clk(clk), .en(en), .clr(clr));
        end

   endgenerate
endmodule