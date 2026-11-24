//====================================================
// ENGI 4054: Digital VLSI Design
// Author: Senoga Kaweesa & Edward Norquay
// Date: Nov 17, 2026
//====================================================
// File Name : multiplier_shift_add.v
// Description : Multiplies two 3-bit values using
//               the shift-and-add multiplication
//               algorithm.
//====================================================

module multiplier_shift_add
(
    input wire [2:0] A,           // Multiplicand
    input wire [2:0] B,           // Multiplier
    output reg [5:0] product      // Multiplication result
);

    integer i;                    // Loop counter
    reg [5:0] temp;               // Temporary accumulator

    // Combinational shift-and-add multiplier
    always @(*)
    begin
        // Initialize accumulator to zero
        temp = 6'd0;

        // Examine each bit of the multiplier
        for(i = 0; i < 3; i = i + 1)
        begin
            // If multiplier bit is 1,
            // add shifted multiplicand
            if(B[i])
                temp = temp + (A << i);
        end

        // Store final multiplication result
        product = temp;
    end

endmodule