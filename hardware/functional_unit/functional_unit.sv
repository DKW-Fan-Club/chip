/*
Module: functional_unit
Description: Basic computational unit, as of now just an adder. To be expanded

Inputs: TODO
Outputs: TODO
*/

import types::*;

module functional_unit
(
    /* Global inputs */
    input logic         clk_i,

    /* Programming inputs */
    input logic         program_en_i,   // Enable programming
    input logic         program_data_i, // bit-shifted data

    /* Programming output */
    output logic        program_data_o, // bit-shifted data for next slice

    /* Element inputs, to be hooked up externally */
    input fu_input_t    a_i,
    input fu_input_t    b_i,

    /* Computed output, to be routed externally */
    output fu_output_t  result_o

);

fu_program_data_t program_data_reg;
logic program_data_o_reg;
fu_output_t result_reg, result_next;

assign result_o = result_reg;
assign program_data_o = program_data_o_reg;

always_ff @(posedge clk_i) begin : fu_execution
    if (program_en_i) begin
        program_data_reg <= {program_data_reg[$bits(fu_program_data_t)-2:0], program_data_i};   // left shift in program data bit
        program_data_o_reg <= program_data_reg[$bits(fu_program_data_t)-1]; // output the MSB of the program data to next slice
    end
    else begin
        result_reg <= result_next;  // Only want result to change when we're not programming (i.e. when we're computing)
    end

end : fu_execution

always_comb begin : result_next_calc
    case (program_data.mode) 
        a_add:      result_next = a_i + b_i;
        a_sub:      result_next = a_i - b_i;
        pass_a:     result_next = a_i;
        pass_b:     result_next = b_i;
        l_and:      result_next = a_i & b_i;
        l_or:       result_next = a_i | b_i;
        l_xor:      result_next = a_i ^ b_i;
        l_not:      result_next = ~a_i; // can only negate a 
        default:    result_next = a_i; // default pass-through a
    endcase

end : result_next_calc


endmodule : functional_unit