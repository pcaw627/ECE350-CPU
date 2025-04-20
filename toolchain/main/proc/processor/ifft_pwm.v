// ---------------------------------------------------------
// 16‑bit  ΔΣ 1‑bit audio DAC  –  100 MHz system clock
// fPWM = 100 MHz  ⇒  >90 dB SNR after on‑board RC filter
// ---------------------------------------------------------
module ds_dac_1bit
(
    input  wire        clk,          // 100 MHz
    input  wire        rstn,
    input  wire [15:0] pcm_in,       // new sample when 'stb' pulses
    input  wire        stb,
    output reg         pwm_out
);
    reg signed [17:0] acc = 0;       // 2 guard bits + 16 data bits

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            acc     <= 0;
            pwm_out <= 0;
        end else begin
            if (stb)                      // load new IFFT sample
                acc <= {pcm_in, 2'b00};   // left‑shift to use guard bits
            else begin
                // 1‑bit ΔΣ: add MSB (‑1/ +1) back
                acc <= acc + { {17{pwm_out}}, 1'b0 } - 18'sd32768;
            end
            pwm_out <= acc[17];           // MSB is the bit‑stream
        end
    end
endmodule
