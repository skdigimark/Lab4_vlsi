//====================================================
// EELE 4054: Digital VLSI Design
// Author: Senoga Kaweesa
// Date: November 14, 2026
// Description: Testbench for Lab 4 Counter Simulation
//====================================================

`timescale 1ns / 1ps

module LAB4_Counter_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg ena;
    reg [5:0] pre_ld;

    // Outputs
    wire [7:0] disp0;
    wire [7:0] disp1;

    // Instantiate Unit Under Test (UUT)
    LAB4_Counter uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .ena(ena), 
        .pre_ld(pre_ld), 
        .disp0(disp0), 
        .disp1(disp1)
    );

    // Generate 50 MHz Clock (Period = 20 ns)
    always #10 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        ena = 0;
        pre_ld = 6'b101111; // Pre-loaded value = 47

        // Apply Reset
        #100;
        rst_n = 1; // Release reset
        
        // Wait and Enable Counter
        #200;
        ena = 1;   // Enable counting

        // Let it run for simulation observation
        #50000000;
        
        // Test disable hold state
        ena = 0;
        #10000000;
        ena = 1;

        #20000000;
        $stop;
    end

endmodule
