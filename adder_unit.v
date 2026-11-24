//====================================================
// ENGI 4054: Digital VLSI Design
// Author: Senoga Kaweesa & Edward Norquay
// Date: Nov 17, 2026
//====================================================
// File Name : adder_unit.v
// Description : Adds two 3-bit binary inputs
//               and produces a 6-bit sum.
//====================================================

module adder_unit
(
    input wire [2:0] A,       // First 3-bit operand
    input wire [2:0] B,       // Second 3-bit operand
    output wire [5:0] sum     // Addition result
);

    // Continuous assignment performs binary addition
    assign sum = A + B;

endmodule