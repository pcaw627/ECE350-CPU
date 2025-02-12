`timescale 1ns/100ps
module wallace_tb;
    reg [31:0] a;
    reg [31:0] b;
    wire [63:0] product;
    reg [63:0] expected_product;
    
    wallace_32 wallace_mult (
        .a(a),
        .b(b),
        .product(product)
    );
    
    // test helper fn
    task run_test;
        input [31:0] a_in;
        input [31:0] b_in;
        begin
            a = a_in;
            b = b_in;
            expected_product = a_in * b_in;
            
            #10;
            
            // Check result
            if (product !== expected_product) begin
                $display("~~~~~~~~~~~~~~~~~FAIL");
                $display("a = %0d (0x%h)", $signed(a_in), $signed(a_in));
                $display("b = %0d (0x%h)", $signed(b_in), $signed(b_in));
                $display("Expected: %0d (0x%h)", $signed(expected_product), $signed(expected_product));
                $display("Got:      %0d (0x%h)", $signed(product), $signed(product));
                $display("");
            end else begin
                $display("PASS");
                $display("a = %0d (0x%h)", $signed(a_in), $signed(a_in));
                $display("b = %0d (0x%h)", $signed(b_in), $signed(b_in));
                $display("Product = %0d (0x%h)", $signed(product), $signed(product));
                $display("");
            end
        end
    endtask
    
    initial begin
        a = 0;
        b = 0;
        #10;

        run_test(32'h0, 32'h0);
        run_test(32'h1, 32'h1);
        run_test(32'h2, 32'h2);
        run_test(32'hFFFF_FFFF, 32'h2); // -1 * 2
        run_test(32'h1234_5678, 32'h8765_4321);
        run_test(32'h5555_5555, 32'hAAAA_AAAA); // 
        run_test(32'hFFFF_FFFF, 32'hFFFFFFFF); // -1 * -1
        run_test(32'd997, 32'd991);
        run_test(32'hFFFF_FFFF, 32'h0); // -1 * 0
        run_test(32'hFFFF_0000, 32'h0000_FFFF); // -65536 * 65536 // checks on calc but doesn't seem to be 2s comp...
        //FFFFFFFF
        
        $finish;
    end
    
    initial begin
        $dumpfile("wallace_32.vcd");
        $dumpvars(0, wallace_tb);
    end
    
endmodule