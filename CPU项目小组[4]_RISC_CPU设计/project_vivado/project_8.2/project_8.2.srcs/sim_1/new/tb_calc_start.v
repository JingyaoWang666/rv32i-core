`timescale 1ns/1ps

// Testbench for the top-level module 'riscv_cpu_top'
module tb_top;

    // -- Testbench Signals --

    // Regs to drive the inputs of the DUT (Device Under Test)
    reg         clk;
    reg         rst_n;
    reg         btn_center_in;
    reg         btn_up_in;
    reg         btn_down_in;
    reg         btn_left_in;
    reg         btn_right_in;

    // Wires to capture the outputs of the DUT
    wire [3:0]  seg_an;
    wire [7:0]  seg_seg;

    // -- Verification Logic Signals --
    reg [3:0]   pulse_width_counter; // Counter to measure the pulse width of calc_start
    reg         test_finished;       // Flag to indicate test completion

    // -- 1. Instantiate the Device Under Test (DUT) --
    // Connect the testbench signals to the DUT's ports.
    riscv_cpu_top uut (
        .clk            (clk),
        .rst_n          (rst_n),
        .btn_center_in  (btn_center_in),
        .btn_up_in      (btn_up_in),
        .btn_down_in    (btn_down_in),
        .btn_left_in    (btn_left_in),
        .btn_right_in   (btn_right_in),
        .seg_an         (seg_an),
        .seg_seg        (seg_seg)
    );

    // -- 2. Clock Generation --
    // Generate a 100MHz clock (10ns period).
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // -- 3. Test Stimulus --
    // This block defines the sequence of events for the test.
    initial begin
        $display("Starting test for calc_start pulse width...");
        // Initialize all inputs to a known state
        test_finished = 0;
        btn_center_in = 0;
        btn_up_in     = 0;
        btn_down_in   = 0;
        btn_left_in   = 0;
        btn_right_in  = 0;

        // Apply reset
        rst_n = 0;
        #20; // Wait for 20ns
        rst_n = 1;
        #50; // Wait for the system to stabilize after reset

        // Simulate a button press
        // The press must be long enough for the debouncer inside the DUT to register it.
        $display("Simulating center button press...");
        btn_center_in = 1;
        #10 btn_center_in = 0;
        #80 btn_center_in = 1;
        #10 btn_center_in = 0;
        #500; // Hold the button for 500ns
        btn_center_in = 0;

        // Wait for the test to complete or timeout
        #1000;
        if (!test_finished) begin
            $display("TEST FAILED: Timeout. calc_start pulse was not detected.");
        end
        $finish; // End the simulation
    end

    // -- 4. Verification Logic --

    // This block continuously counts how many cycles 'calc_start' is high.
    // It uses the internal 'calc_start' signal from the DUT via the hierarchical path 'uut.calc_start'.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_width_counter <= 0;
        end else if (uut.calc_start) begin
            // If calc_start is high, increment the counter.
            pulse_width_counter <= pulse_width_counter + 1;
        end else begin
            // If calc_start is low, keep the counter reset.
            pulse_width_counter <= 0;
        end
    end

    // This block triggers on the falling edge of 'calc_start' to check the final count.
    always @(negedge uut.calc_start) begin
        // Check the pulse width only after the reset sequence is done.
        if (rst_n) begin
            if (pulse_width_counter == 4) begin
                $display("TEST PASSED: calc_start pulse width was %0d cycles, as expected.", pulse_width_counter);
            end else begin
                $display("TEST FAILED: calc_start pulse width was %0d cycles, but expected 4.", pulse_width_counter);
            end
            test_finished = 1; // Mark the test as complete
        end
    end

endmodule