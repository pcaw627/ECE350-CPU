

module wallace_32(
    input [31:0] a,
    input [31:0] b,
    output [63:0] product,
    output [31:0] product_hi,
    output [31:0] product_lo
);  

    // braindump
    // extension://bocbaocobfecmglnmeaeppambideimao/pdf/viewer.html?file=https%3A%2F%2Fwww.cse.psu.edu%2F~kxc104%2Fclass%2Fcmpen411%2F11s%2Flec%2FC411L20Multiplier.pdf
        // see pg 25-28
    // https://velog.io/@hyal/%EB%B2%94%EC%9A%A9%EC%A0%81%EC%9D%B8-NPU-%EB%A7%8C%EB%93%A4%EA%B8%B011-%EA%B3%B1%EC%85%88%EA%B8%B03-%EC%9D%B4%EB%A1%A03-Wallace-Tree
        // good graph
    // https://www.researchgate.net/figure/The-three-phases-of-a-4-4-Wallace-Tree-multiplier-Fig-1-expressed-as-12-levels-of_fig6_356679017
    // https://web.archive.org/web/20100617044555/http://www.eecs.tufts.edu/~ryun01/vlsi/design.htm
        // ("3:2 compressor" is a pretty roundabout name for a full adder)    
    // https://www.ijcaonline.org/research/volume124/number13/keshaveni-2015-ijca-905742.pdf  
        // ("carry save adder" is also a fancy way of saying full adder.. though csa is usually used only when full adders are used in parallel)
        // "The computation of sum s and carry c is as follows: It is actually identical to the full adder, but with some of the signals 
        // renamed. Figure 3 shows a full adder and a carry save adder. A carry save adder simply is a full adder with the cin input 
        // renamed as z, the z output (the original “answer” output) renamed to s, and the cout output renamed to c"   
    // https://kalaharijournals.com/resources/26_JUNE21.pdf
    // https://scholarworks.bridgeport.edu/server/api/core/bitstreams/5eeaa145-f704-4183-8e2f-3b8e6c94ef2e/content
    // https://gitlab.oit.duke.edu/tkb13/multdiv-simulator
    // https://en.wikipedia.org/wiki/Wallace_tree
    // https://www.ijert.org/research/design-and-implementation-of-32-bit-wallace-multiplier-using-compressors-and-various-adders-IJERTV11IS050369.pdf
    // [6] Jagadeshwar Rao M, Sanjay Dubey, Asia Pacific conference 2012, A high speed and area efficient booth encoded Wallace tree multiplier  for fast arithmetic circuits.  

    // 1: gen partial products
    wire [31:0] pp[31:0];  
    
    genvar i, j;
    generate
        for(i = 0; i < 32; i = i + 1) begin : gen_pp_i
            for(j = 0; j < 32; j = j + 1) begin : gen_pp_j
                and g1(pp[i][j], a[j], b[i]);
            end
        end
    endgenerate

    // 2: Sum partial products, row by row
    wire [63:0] row_sums[31:0];
    wire [63:0] row_carries[31:0];
    
    // init first row (one block for sums (0-31 assigned from pp, the rest zero) then another for carries (all zero))
    generate
        for(i = 0; i < 32; i = i + 1) begin : init_first_row_sums
            assign row_sums[0][i] = pp[0][i];
            assign row_sums[0][i+32] = 1'b0;
        end
    endgenerate

    generate
        for(i = 0; i < 64; i = i + 1) begin : init_first_row_carries
            assign row_carries[0][i] = 1'b0;
        end
    endgenerate

    // 3: add each subsequent row
    generate
        for(i = 1; i < 32; i = i + 1) begin : add_rows
            wire [63:0] extended_pp;
            // extend and shift partial product
            assign extended_pp = {{(32-i){1'b0}}, pp[i], {i{1'b0}}};
            
            // add to previous sum
            // wire [63:0] temp_sum, temp_carry;
            
            or sum_or_0 (row_sums[i][0], row_sums[i-1][0], extended_pp[0]);
            and carry_and_0 (row_carries[i][0], row_sums[i-1][0], extended_pp[0]);
            
            for(j = 1; j < 64; j = j + 1) begin : add_bits

                full_adder fa(
                    .a(row_sums[i-1][j]),
                    .b(extended_pp[j]),
                    .cin(row_carries[i-1][j-1]),
                    .sum(row_sums[i][j]),
                    .cout(row_carries[i][j])
                );
            end
        end
    endgenerate

    // final stage- Add last sum and carries
    wire [63:0] final_carry;

    assign product[0] = row_sums[31][0];
    assign final_carry[0] = row_carries[31][0];
    
    // thisll maybe be slow? maybe add with cla?
    generate
        for(i = 1; i < 64; i = i + 1) begin : final_addition
            full_adder fa_final(
                .a(row_sums[31][i]),
                .b(row_carries[31][i-1]),
                .cin(final_carry[i-1]),
                .sum(product[i]),
                .cout(final_carry[i])
            );
        end
    endgenerate
    
    wire [31:0] product_hi;
    wire [31:0] product_lo;

    assign product_hi = product[63:32];
    assign product_lo = product[31:0];

endmodule

// iverilog -o wallace -s wallace_tb -c .\wallace_FileList.txt -Wimplicit; vvp ./wallace