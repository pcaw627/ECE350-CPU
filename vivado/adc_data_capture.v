// written by wanghley!! - liam
module adc_data_capture(
    input clk,
    input reset,
    input vauxn3, input vauxp3,        // EMG input (VAUX3)
    output reg [15:0] adc_out         // Output for EMG
);

reg [6:0] daddr_in = 7'h13;            // Start with VAUX3
wire [15:0] adc_data;
wire drdy;

// XADC instantiation
xadc_wiz_0 xadc_inst (
    .dclk_in(clk),
    .daddr_in(daddr_in),
    .den_in(1'b1),
    .di_in(16'h0000),
    .dwe_in(1'b0),
    .do_out(adc_data),
    .drdy_out(drdy),
    .vp_in(1'b0),
    .vn_in(1'b0),
    .vauxp3(vauxp3),
    .vauxn3(vauxn3),
    .reset_in(reset) // âœ… no comma here!
);                   // âœ… good

// Read and route ADC values to EMG or ECG outputs
always @(posedge clk) begin 
    if (drdy) begin
        
        // convert 12-bit to 32-bit
        adc_out <= adc_data; //{21'h0, adc_data[15:4]};  // 32-bit EMG data
        
    end
end

endmodule
