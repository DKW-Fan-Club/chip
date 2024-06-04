/*
Module: switchbox (SB)
Description: Decides which 2 of NUM_FU_COLS outputs to route
to the next row's FU

Inputs: TODO
Outputs: TODO
*/

import types::*;

module switchbox
(
    /* Global inputs */
    input logic clk_i,

    /* Programming inputs */
    input logic program_en_i,
    input logic program_data_i,

    /* Routing inputs */
    input fu_output_t prev_row_outputs_i [NUM_FU_COLS],

    /* Routing outputs */
    output fu_input_t a_o,
    output fu_input_t b_o,

    /* Programming output */
    output logic program_data_o
);

sb_program_data_t program_data_reg;
logic program_data_o_reg;

assign program_data_o = program_data_o_reg;

always_ff @(posedge clk_i) begin : programming
    if (program_en_i) begin
        program_data_reg <= {program_data_reg[$bits(sb_program_data_t)-2:0], program_data_i};   // left shift in program data bit
        program_data_o_reg <= program_data_reg[$bits(sb_program_data_t)-1]; // output the MSB of the program data to next slice
    end
    
end : programming

/* Combinational decode. Can be changed later to improve timing/power if needed */
// Use a decoder for now, could switch to one-hot if needed?
always_comb begin
    a_o = prev_row_outputs_i[program_data_reg.a_sel];
    b_o = prev_row_outputs_i[program_data_reg.b_sel];
end

endmodule : switchbox