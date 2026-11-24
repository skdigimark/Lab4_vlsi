//====================================================
// ENGI 4054: Digital VLSI Design
// Author: Senoga Kaweesa & Edward Norquay
// Date: Nov 17, 2026
//====================================================
// File Name : shift_unit.v
// Description : Concatenates two 3-bit inputs
//               into a 6-bit value and performs
//               a logical right shift by one bit.
//====================================================

module shift_unit
(
    input wire [2:0] A,          // First 3-bit input
    input wire [2:0] B,          // Second 3-bit input
    output wire [5:0] result     // Shifted result
);

    // Concatenate B and A, then shift right by 1 bit
    assign result = {B,A} >> 1;

endmodule