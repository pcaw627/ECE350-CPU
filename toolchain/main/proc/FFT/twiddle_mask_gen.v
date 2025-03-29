module twiddle_mask_gen (
    input clock, 
    input clr, 
    output [3:0] out
);

    wire [3:0] out_intermediate;

    initial begin 
        out = 4'b0;
    end

    always @(posedge clock) begin
        if (clr) begin
            out = 4'b0;
        end else begin
            out_intermediate = {1'b1, out[3:1]};
        end
    end

    dffe_ref [3:0] (.q(out), .d(out_intermediate), .clr(clr), .clk(clock), .en(1'b1));

endmodule