module twiddle_mask_gen (
    input clock, 
    input clr, 
    output [3:0] out
);

    reg [3:0] out_intermediate;

    initial begin 
        out_intermediate <= 4'b0000;
    end

    always @(negedge clock) begin
        if (clr) begin
            out_intermediate <= 4'b0000;
        end else begin
            out_intermediate <= {out[3:1], 1'b1};
        end
    end

    dffe_ref dffs [3:0] (.q(out), .d(out_intermediate), .clr(clr), .clk(clock), .en(1'b1));

endmodule