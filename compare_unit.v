//====================================================
// ENGI 4054: Digital VLSI Design
// Author: Senoga Kaweesa & Edward Norquay
// Date: Nov 17, 2026
//====================================================
// File Name : compare_unit.v
// Description : Compares two 3-bit inputs and
//               generates a 6-bit result code.
//
// Result = 1 if A > B
// Result = 2 if A < B
// Result = 0 if A = B
//====================================================

module compare_unit
(
    input wire [2:0] A,       // First 3-bit input
    input wire [2:0] B,       // Second 3-bit input
    output reg [5:0] result   // Comparison result
);

    // Combinational comparison logic
    always @(*)
    begin
        // Check if A is greater than B
        if (A > B)
            result = 6'd1;

        // Check if A is less than B
        else if (A < B)
            result = 6'd2;

        // A and B are equal
        else
            result = 6'd0;
    end

endmodule