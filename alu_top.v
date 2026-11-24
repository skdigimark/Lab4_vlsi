//====================================================
// ENGI 4054: Digital VLSI Design
// Author: Senoga Kaweesa & Edward Norquay
// Date: Nov 17, 2026
//====================================================
// File Name : alu_top.v
// Description : Top-level ALU integration module.
//               Synchronizes switch inputs,
//               executes the selected ALU operation,
//               and displays the result on LEDs
//               and the seven-segment display.
//
// Operations:
//   00 = Compare A and B
//   01 = Shift operation
//   10 = Addition
//   11 = Multiplication
//====================================================
module alu_top 
(
    input wire CLOCK_50,

    input wire [9:0] SW,
    input wire [1:0] KEY,

    output wire [9:0] LEDR,

    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);


// Synchronized inputs
//
// Switch inputs are passed through synchronizers
// to reduce metastability before being used by
// the ALU logic.

wire [2:0] A_sync;       // Synchronized operand A
wire [2:0] B_sync;       // Synchronized operand B
wire [1:0] ALUOP_sync;   // Synchronized operation select
wire enable_sync;        // Synchronized enable signal

// ALU outputs
//
// Each ALU module computes its result in parallel.
// The selected result is loaded into dout_reg.

wire [5:0] compare_out;  // Comparison result
wire [5:0] shift_out;    // Shift operation result
wire [5:0] add_out;      // Addition result
wire [5:0] mult_out;     // Multiplication result

// Registered output
//
// Holds the selected ALU result.
// Updates on the rising edge of CLOCK_50.

reg [5:0] dout_reg;

// Synchronized reset signal
wire [0:0] reset_sync;

// Decimal display digits
wire [3:0] ones_digit;
wire [3:0] tens_digit;

wire [6:0] ones_seg;
wire [6:0] tens_seg;

wire [6:0] bit0_seg;
wire [6:0] bit1_seg;
wire [6:0] bit2_seg;
wire [6:0] bit3_seg;
wire [6:0] bit4_seg;
wire [6:0] bit5_seg;

// Synchronize reset button

synchronizer sync_reset
(
    .clk(CLOCK_50),
    .async_in(KEY[0]),
    .sync_out(reset_sync)
);
// Synchronize operand A

synchronizer #(.WIDTH(3))
sync_A
(
    .clk(CLOCK_50),
    .async_in(SW[3:1]),
    .sync_out(A_sync)
);


// Synchronize operand B

synchronizer #(.WIDTH(3))
sync_B
(
    .clk(CLOCK_50),
    .async_in(SW[6:4]),
    .sync_out(B_sync)
);

// Synchronize ALU operation select bits

synchronizer #(.WIDTH(2))
sync_opcode
(
    .clk(CLOCK_50),
    .async_in(SW[8:7]),
    .sync_out(ALUOP_sync)
);

// Synchronize enable control input

synchronizer
sync_enable
(
    .clk(CLOCK_50),
    .async_in(SW[9]),
    .sync_out(enable_sync)
);

// Compare Unit
//
// Outputs status based on A and B comparison.

compare_unit compare0
(
    .A(A_sync),
    .B(B_sync),
    .result(compare_out)
);

// Shift Unit
//
// Concatenates the inputs and performs a
// logical right shift.

shift_unit shift0
(
    .A(A_sync),
    .B(B_sync),
    .result(shift_out)
);

// Adder Unit
//
// Computes the sum of operands A and B.

adder_unit add0
(
    .A(A_sync),
    .B(B_sync),
    .sum(add_out)
);

// Multiplier Unit
//
// Computes the product of operands A and B
// using the shift-and-add algorithm.

multiplier_shift_add mult0
(
    .A(A_sync),
    .B(B_sync),
    .product(mult_out)
);


// Register the selected ALU result

always @(posedge CLOCK_50)
begin

    // Active-low reset button
    if (!reset_sync[0])
        dout_reg <= 6'd0;

    // Update output when enable is asserted
    else if (enable_sync)
    begin

        // Select ALU operation
        case(ALUOP_sync)

            // Compare operation
            2'b00:
                dout_reg <= compare_out;

            // Shift operation
            2'b01:
                dout_reg <= shift_out;

            // Addition operation
            2'b10:
                dout_reg <= add_out;

            // Multiplication operation
            2'b11:
                dout_reg <= mult_out;

            // Default safe state
            default:
                dout_reg <= 6'd0;

        endcase

    end

end

// Decimal conversion

assign tens_digit = dout_reg / 10;
assign ones_digit = dout_reg % 10;

seg7_decoder ones_decoder
(
    .bin(ones_digit),
    .seg(ones_seg)
);

seg7_decoder tens_decoder
(
    .bin(tens_digit),
    .seg(tens_seg)
);

seg7_decoder shift_hex0
(
    .bin({3'b000,dout_reg[0]}),
    .seg(bit0_seg)
);

seg7_decoder shift_hex1
(
    .bin({3'b000,dout_reg[1]}),
    .seg(bit1_seg)
);

seg7_decoder shift_hex2
(
    .bin({3'b000,dout_reg[2]}),
    .seg(bit2_seg)
);

seg7_decoder shift_hex3
(
    .bin({3'b000,dout_reg[3]}),
    .seg(bit3_seg)
);

seg7_decoder shift_hex4
(
    .bin({3'b000,dout_reg[4]}),
    .seg(bit4_seg)
);

seg7_decoder shift_hex5
(
    .bin({3'b000,dout_reg[5]}),
    .seg(bit5_seg)
);
// LED assignments
//
// LEDs mirror the switch inputs as
// specified in the project handout.

assign LEDR[9]   = SW[9];
assign LEDR[8:7] = SW[8:7];
assign LEDR[6:4] = SW[6:4];
assign LEDR[3:1] = SW[3:1];
assign LEDR[0]   = 1'b0;

// Seven-segment display logic

assign HEX0 =
        (ALUOP_sync == 2'b01) ? bit0_seg :
                                ones_seg;

assign HEX1 =
        (ALUOP_sync == 2'b01) ? bit1_seg :
        ((ALUOP_sync == 2'b10) ||
         (ALUOP_sync == 2'b11))
                                ? tens_seg :
                                  7'b1111111;

assign HEX2 =
        (ALUOP_sync == 2'b01)
                                ? bit2_seg :
                                  7'b1111111;

assign HEX3 =
        (ALUOP_sync == 2'b01)
                                ? bit3_seg :
                                  7'b1111111;

assign HEX4 =
        (ALUOP_sync == 2'b01)
                                ? bit4_seg :
                                  7'b1111111;

assign HEX5 =
        (ALUOP_sync == 2'b01)
                                ? bit5_seg :
                                  7'b1111111;

endmodule