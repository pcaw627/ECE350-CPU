module tbb_main;
    // Declare signals
    reg clock;
    reg button;
    wire light;
    wire [2:0] count;  // Assuming 3-bit mod-8 counter output


    // Instantiate the main module (unit under test)
    main uut (
        .clock(clock),
        .button(button),
        .light(light),
        .count(count)   // Expose count value
    );


    // Clock generation (100 MHz)
    always begin
        #5 clock = ~clock;
    end


    // Test sequence
    initial begin
        // VCD setup
        $dumpfile("wave.vcd");
        $dumpvars(0, tbb_main);


        // Initialize signals
        clock = 0;
        button = 0;


        // Display header for table
        $display("-------------------------------------------------");
        $display("Clock | Button | Count | Light |");
        $display("-------------------------------------------------");


        // Test input sequence
        #10 button = 1;
        #10 button = 0;
        #10 button = 1;
        #10 button = 0;
        #10 button = 1;
        #10 button = 0;
        #10 button = 1;


        // Allow simulation to run for a while
        #100;


        // End simulation
        $finish;
    end


    // Table row update on change
    always @(posedge clock) begin
        $display("  %b   |    %b    |   %0d   |   %b    |",
                clock, button, count, light);
    end
endmodule
