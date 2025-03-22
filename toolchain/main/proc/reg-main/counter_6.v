module counter_6 (
    output [5:0] count,
    input clk,
    input clr,
    input en
);

    wire d0, d1, d2, d3, d4, d5;
    
    // First stage: Toggle behavior for bit 0
    // d0 = ~count[0] (when enabled)
    assign d0 = ~count[0];
    
    // Increment conditions for each bit:
    // A bit toggles when all previous bits are 1 and will roll to 0
    wire toggle1, toggle2, toggle3, toggle4, toggle5;
    assign toggle1 = count[0];
    assign toggle2 = count[1] & toggle1;
    assign toggle3 = count[2] & toggle2;
    assign toggle4 = count[3] & toggle3;
    assign toggle5 = count[4] & toggle4;
    
    // Next state logic for each bit
    // d_n = ~count[n] if toggle_n is true, otherwise keep current value count[n]
    assign d1 = toggle1 ? ~count[1] : count[1];
    assign d2 = toggle2 ? ~count[2] : count[2];
    assign d3 = toggle3 ? ~count[3] : count[3];
    assign d4 = toggle4 ? ~count[4] : count[4];
    assign d5 = toggle5 ? ~count[5] : count[5];
    
    // Instantiate 6 flip-flops, one for each bit
    dffe_ref bit0(.q(count[0]), .d(d0), .clk(clk), .en(en), .clr(clr));
    dffe_ref bit1(.q(count[1]), .d(d1), .clk(clk), .en(en), .clr(clr));
    dffe_ref bit2(.q(count[2]), .d(d2), .clk(clk), .en(en), .clr(clr));
    dffe_ref bit3(.q(count[3]), .d(d3), .clk(clk), .en(en), .clr(clr));
    dffe_ref bit4(.q(count[4]), .d(d4), .clk(clk), .en(en), .clr(clr));
    dffe_ref bit5(.q(count[5]), .d(d5), .clk(clk), .en(en), .clr(clr));
    
endmodule