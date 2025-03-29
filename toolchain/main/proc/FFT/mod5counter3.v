module mod5counter3
    # (parameter N = 5,
        parameter WIDTH = 3)

    ( input   clk,
        input   rstn,
        output  reg[WIDTH-1:0] out,
        output cout);

    always @ (posedge clk) begin
        if (!rstn) begin
        out <= 0;
        end else begin
        if (out == N-1)
            out <= 0;
        else
            out <= out + 1;
        end
    end

    assign cout = (out == 0) && (~clk);
  
endmodule