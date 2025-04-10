module mod5counter3
    #(
        parameter N = 5,
        parameter WIDTH = 3
    )
    (
        input  wire clk,
        input  wire clr,
        output wire [WIDTH-1:0] out,
        output wire cout
    );

    reg [WIDTH-1:0] out_reg;
    reg cout_reg;

    assign out = out_reg;
    assign cout = cout_reg;

    always @ (posedge clk) begin
        if (!clr) begin
            out_reg  <= 0;
            cout_reg <= 0;
        end else begin
            if (out_reg == N-1) begin
                out_reg  <= 0;
                cout_reg <= 1;
            end else begin
                out_reg  <= out_reg + 1;
                cout_reg <= 0;
            end
        end
    end

endmodule

// iverilog -o mod5counter3 -c FileList.txt -s modcounter3_tb; vvp .\mod5counter3