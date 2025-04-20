module sdf #(
   parameter N=64,
   parameter M=64,
   parameter WIDTH=16
) (
    input clock,
    input reset,
    input data_in_en,
    input [WIDTH-1:0] data_in_real,
    input [WIDTH-1:0] data_in_imag,
    output data_out_en,
    output [WIDTH-1:0] data_out_real,
    output [WIDTH-1:0] data_out_imag
);

function integer log2;
    input integer x;
    integer value;

    begin
        value = x-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

localparam  LOG_N = log2(N); // Bit Length of N
localparam  LOG_M = log2(M); // Bit Length of M

reg [WIDTH-1:0] bf1_data_out_real, bf1_data_out_imag;

reg [LOG_N-1:0] data_in_count; // Input Data Count


always @(posedge clock or posedge reset) begin
    if (reset) begin
        data_in_count <= {LOG_N{1'b0}};
    end else begin
        data_in_count <= data_in_en ? (data_in_count + 1'b1) : {LOG_N{1'b0}};
    end
end

// BUTTERFLY 1
wire bf1_bf = data_in_count[LOG_M-1];
// wire bf1_bf; // Butterfly 1 Add/Sub Enable

wire[WIDTH-1:0] bf1_x0_real, bf1_x0_imag, bf1_x1_real, bf1_x1_imag; // Data #0 and #1 TO Butterfly (Real and Imag for each)
wire[WIDTH-1:0] bf1_y0_real, bf1_y0_imag, bf1_y1_real, bf1_y1_imag; // Data #0 and #1 FROM Butterfly (Real and Imag for each)

wire[WIDTH-1:0] db1_data_in_real, db1_data_in_imag; // data TO DelayBuffer (real and imag)
wire[WIDTH-1:0] db1_do_real, db1_do_imag; // data FROM DelayBuffer (real and imag)

wire[WIDTH-1:0] bf1_sp_real, bf1_sp_imag; // Single-Path Data Output (Real and imag)

reg bf1_sp_en;  // Single-Path Data Enable
reg [LOG_N-1:0] bf1_count;  // Single-Path Data Count
wire bf1_start;  // Single-Path Output Trigger
wire bf1_end;    // End of Single-Path Data
wire bf1_mj;     // Twiddle (-j) Enable

reg [WIDTH-1:0] bf1_do_real, bf1_do_imag;  //  1st Butterfly Output Data (Real and imag)



// BUTTERFLY 2
reg bf2_bf; // Butterfly Add/Sub Enable

wire[WIDTH-1:0] bf2_x0_real, bf2_x0_imag, bf2_x1_real, bf2_x1_imag; // Data #0 and #1 TO Butterfly (Real and Imag for each)
wire[WIDTH-1:0] bf2_y0_real, bf2_y0_imag, bf2_y1_real, bf2_y1_imag; // Data #0 and #1 FROM Butterfly (Real and Imag for each)

wire[WIDTH-1:0] db2_data_in_real, db2_data_in_imag; // data TO DelayBuffer (real and imag)
wire[WIDTH-1:0] db2_do_real, db2_do_imag; // data FROM DelayBuffer (real and imag)

wire[WIDTH-1:0] bf2_sp_real, bf2_sp_imag; // Single-Path Data Output (Real and imag)

reg bf2_sp_en;  // Single-Path Data Enable
reg [LOG_N-1:0] bf2_count;  // Single-Path Data Count
reg bf2_start;  // Single-Path Output Trigger
wire bf2_end;    // End of Single-Path Data
wire bf2_mj;     // Twiddle (-j) Enable

reg [WIDTH-1:0] bf2_do_real, bf2_do_imag;  //  1st Butterfly Output Data (Real and imag)








wire [WIDTH-1:0] db1_data_out_real, db1_data_out_imag;

// First butterfly instantiation
assign bf1_x0_real = bf1_bf ? db1_data_out_real : {WIDTH{1'bx}};
assign bf1_x0_imag = bf1_bf ? db1_data_out_imag : {WIDTH{1'bx}};
assign bf1_x1_real = bf1_bf ? data_in_real : {WIDTH{1'bx}};
assign bf1_x1_imag = bf1_bf ? data_in_imag : {WIDTH{1'bx}};

Butterfly #(.WIDTH(WIDTH), .RH(0)) BF1 (
    .x0_real(bf1_x0_real), .x0_imag(bf1_x0_imag),
    .x1_real(bf1_x1_real), .x1_imag(bf1_x1_imag),
    .y0_real(bf1_y0_real), .y0_imag(bf1_y0_imag),
    .y1_real(bf1_y1_real), .y1_imag(bf1_y1_imag)
);

// First delay buffer (depth = M/2)
assign db1_data_in_real = bf1_bf ? bf1_y1_real : data_in_real;
assign db1_data_in_imag = bf1_bf ? bf1_y1_imag : data_in_imag;




multi_clock_delay #(.WIDTH(WIDTH), .CYCLES(2**(LOG_M-1))) DB1_real (
    .q(db1_data_out_real),
    .d(db1_data_in_real),
    .clr(),
    .clk(clock)
);

multi_clock_delay #(.WIDTH(WIDTH), .CYCLES(2**(LOG_M-1))) DB1_imag (
    .q(db1_data_out_imag),
    .d(db1_data_in_imag),
    .clr(),
    .clk(clock)
);


// Single-path data formation with special -j handling
assign bf1_sp_real = bf1_bf ? bf1_y0_real : 
                    (bf1_mj ? db1_data_out_imag : db1_data_out_real);
assign bf1_sp_imag = bf1_bf ? bf1_y0_imag : 
                    (bf1_mj ? -db1_data_out_real : db1_data_out_imag);

// Control logic

assign bf1_start = (data_in_count == (2**(LOG_M-1)-1));
assign bf1_end = (bf1_count == (2**LOG_N-1));
assign bf1_mj = (bf1_count[LOG_M-1:LOG_M-2] == 2'd3);

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf1_sp_en <= 1'b0;
        bf1_count <= {LOG_N{1'b0}};
    end else begin
        bf1_sp_en <= bf1_start ? 1'b1 : bf1_end ? 1'b0 : bf1_sp_en;
        bf1_count <= bf1_sp_en ? (bf1_count + 1'b1) : {LOG_N{1'b0}};
    end
end

always @(posedge clock) begin
    bf1_data_out_real <= bf1_sp_real;
    bf1_data_out_imag <= bf1_sp_imag;
end

//----------------------------------------------------------------------
// Stage 2: Second butterfly with M/4 delay and control
//----------------------------------------------------------------------
// reg              bf2_sp_en;                // Output enable
// reg  [LOG_N-1:0] bf2_count;                // Output counter
// reg              bf2_start;                // Start trigger
// wire             bf2_end;                  // End signal
reg  [WIDTH-1:0] bf2_data_out_real, bf2_data_out_imag; // Stage 2 outputs
reg              bf2_data_out_en;          // Output enable

always @(posedge clock) begin
    bf2_bf <= bf1_count[LOG_M-2];
end

// Second butterfly instantiation with alternating rounding
assign bf2_x0_real = bf2_bf ? db2_data_out_real : {WIDTH{1'bx}};
assign bf2_x0_imag = bf2_bf ? db2_data_out_imag : {WIDTH{1'bx}};
assign bf2_x1_real = bf2_bf ? bf1_data_out_real : {WIDTH{1'bx}};
assign bf2_x1_imag = bf2_bf ? bf1_data_out_imag : {WIDTH{1'bx}};

Butterfly #(.WIDTH(WIDTH), .RH(1)) BF2 (
    .x0_real(bf2_x0_real), .x0_imag(bf2_x0_imag),
    .x1_real(bf2_x1_real), .x1_imag(bf2_x1_imag),
    .y0_real(bf2_y0_real), .y0_imag(bf2_y0_imag),
    .y1_real(bf2_y1_real), .y1_imag(bf2_y1_imag)
);

// Second delay buffer (depth = M/4)
assign db2_data_in_real = bf2_bf ? bf2_y1_real : bf1_data_out_real;
assign db2_data_in_imag = bf2_bf ? bf2_y1_imag : bf1_data_out_imag;
wire [WIDTH-1:0] db2_data_out_real, db2_data_out_imag;

multi_clock_delay #(.WIDTH(WIDTH), .CYCLES(2**(LOG_M-2))) DB2_real (
    .q(db2_data_out_real),
    .d(db2_data_in_real),
    .clr(),
    .clk(clock)
);

multi_clock_delay #(.WIDTH(WIDTH), .CYCLES(2**(LOG_M-2))) DB2_imag (
    .q(db2_data_out_imag),
    .d(db2_data_in_imag),
    .clr(),
    .clk(clock)
);


// Single-path data formation
assign bf2_sp_real = bf2_bf ? bf2_y0_real : db2_data_out_real;
assign bf2_sp_imag = bf2_bf ? bf2_y0_imag : db2_data_out_imag;

// Control logic
always @(posedge clock) begin
    bf2_start <= (bf1_count == (2**(LOG_M-2)-1)) & bf1_sp_en;
end
assign bf2_end = (bf2_count == (2**LOG_N-1));

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf2_sp_en <= 0;
        bf2_count <= {LOG_N{1'b0}};
        bf2_data_out_en <= 0;
    end else begin
        bf2_sp_en <= bf2_start ? 1'b1 : bf2_end ? 1'b0 : bf2_sp_en;
        bf2_count <= bf2_sp_en ? (bf2_count + 1'b1) : {LOG_N{1'b0}};
        bf2_data_out_en <= bf2_sp_en;
    end
end


always @(posedge clock) begin
    bf2_data_out_real <= bf2_sp_real;
    bf2_data_out_imag <= bf2_sp_imag;
end




//----------------------------------------------------------------------
// Stage 3: Twiddle factor multiplication
//----------------------------------------------------------------------
wire [1:0]       tw_sel = {bf2_count[LOG_M-2], bf2_count[LOG_M-1]};
wire [LOG_N-3:0] tw_num = bf2_count << (LOG_N-LOG_M);
wire [LOG_N-1:0] tw_addr = tw_num * tw_sel;
wire [WIDTH-1:0] tw_real, tw_imag;
reg              mu_en;
wire [WIDTH-1:0] mu_a_real, mu_a_imag, mu_m_real, mu_m_imag;
reg  [WIDTH-1:0] mu_data_out_real, mu_data_out_imag;
reg              mu_data_out_en;

// Twiddle factor lookup
Twiddle64 TW (
    .clock(clock), .addr(tw_addr),
    .tw_real_out(tw_real), .tw_imag_out(tw_imag)
);

// Bypass multiplication when twiddle is 1+0j
always @(posedge clock) begin
    mu_en <= (tw_addr != {LOG_N{1'b0}});
end

// Complex multiplier
assign mu_a_real = mu_en ? bf2_data_out_real : {WIDTH{1'bx}};
assign mu_a_imag = mu_en ? bf2_data_out_imag : {WIDTH{1'bx}};

mult #(.WIDTH(WIDTH)) MU (
    .a_re(mu_a_real), .a_im(mu_a_imag),
    .b_re(tw_real), .b_im(tw_imag),
    .m_re(mu_m_real), .m_im(mu_m_imag)
);

always @(posedge clock) begin
    mu_data_out_real <= mu_en ? mu_m_real : bf2_data_out_real;
    mu_data_out_imag <= mu_en ? mu_m_imag : bf2_data_out_imag;
end

always @(posedge clock or posedge reset) begin
    if (reset) mu_data_out_en <= 0;
    else mu_data_out_en <= bf2_data_out_en;
end



// final output selection
assign data_out_en = (LOG_M == 2) ? bf2_data_out_en : mu_data_out_en;
assign data_out_real = (LOG_M == 2) ? bf2_data_out_real : mu_data_out_real;
assign data_out_imag = (LOG_M == 2) ? bf2_data_out_imag : mu_data_out_imag;

endmodule