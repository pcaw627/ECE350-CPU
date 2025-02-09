`timescale 1 ns / 100 ps

module register_32_tb;
//////
// inputs to the module (reg)
    wire [31:0] q;
    reg [31:0] d;
    reg clk; 
    reg en;
    reg clr;
    // Instantiate the module to test
    register_32 reg32(.q(q), .d(d), .clk(clk), .en(en), .clr(clr));

    /////// Input Initialization
    // Initialize the inputs and specify the runtime

    initial begin
        assign clk = 1'b0;
        assign en = 1'b0;
        assign clr = 1'b0;
        assign d = 32'd7401;
        #20;            
        $display("clk:%b, en:%b, clr:%b, data:%d => q:%d", clk, en, clr, d, q);

        
        assign clk = 1'b1;
        assign en = 1'b0;
        assign clr = 1'b0;
        assign d = 32'd7401;
        #20;            
        $display("clk:%b, en:%b, clr:%b, data:%d => q:%d", clk, en, clr, d, q);

        
        assign clk = 1'b0;
        assign en = 1'b0;
        assign clr = 1'b1;
        assign d = 32'd7401;
        #20;            
        $display("clk:%b, en:%b, clr:%b, data:%d => q:%d", clk, en, clr, d, q);

        
        assign clk = 1'b1;
        assign en = 1'b0;
        assign clr = 1'b1;
        assign d = 32'd7401;
        #20;            
        $display("clk:%b, en:%b, clr:%b, data:%d => q:%d", clk, en, clr, d, q);

        
        assign clk = 1'b0;
        assign en = 1'b1;
        assign clr = 1'b0;
        assign d = 32'd7401;
        #20;            
        $display("clk:%b, en:%b, clr:%b, data:%d => q:%d", clk, en, clr, d, q);

        
        assign clk = 1'b1;
        assign en = 1'b1;
        assign clr = 1'b0;
        assign d = 32'd7401;
        #20;            
        $display("clk:%b, en:%b, clr:%b, data:%d => q:%d", clk, en, clr, d, q);

        
        assign clk = 1'b0;
        assign en = 1'b1;
        assign clr = 1'b1;
        assign d = 32'd7401;
        #20;            
        $display("clk:%b, en:%b, clr:%b, data:%d => q:%d", clk, en, clr, d, q);

        
        assign clk = 1'b1;
        assign en = 1'b1;
        assign clr = 1'b1;
        assign d = 32'd7401;
        #20;            
        $display("clk:%b, en:%b, clr:%b, data:%d => q:%d", clk, en, clr, d, q);

        
    end
    

    // output waveform
    initial begin
        // output file name
        $dumpfile("register_32.vcd");
        $dumpvars(0, register_32_tb);
    end

endmodule

// iverilog -o reg-main/register_32 -c reg-main/register_32_FileList.txt -Wimplicit
// vvp .\reg-main\register_32