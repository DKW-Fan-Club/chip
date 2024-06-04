// Top level

import types::*;

module cgra
(
    input logic clk_i,
    input logic reset_i,

    /* Programming pins */
    input logic program_en_i,
    input logic [$clog2(NUM_FU_ROWS)-1:0] program_row_sel_i,
    input logic program_data_i,

    /* Data transmission pins */
    input logic data_receive_i, // Receive from CPU
    input logic data_send_i,    // Send to CPU
    input logic [NUM_DATA_INPUT_PINS-1:0] data_i,
    output logic [NUM_DATA_OUTPUT_PINS-1:0] data_o

);

fu_input_t [NUM_FU_COLS-1:0] deserialized_input_data_reg;
logic [NUM_FU_ROWS-1:0] one_hot_program_row;

always_ff @(posedge clk_i) begin : data_receiving
    if (data_receiving) begin   // Left shift data into registers
        for (int i = 0; i < NUM_FU_COLS; i++)
            deserialized_input_data_reg[i] <= {deserialized_input_data_reg[i][FU_DATA_WIDTH-2:0], data_i[i]};
    end
end : data_receiving

always_comb begin : program_row_decode
    one_hot_program_row = '0;
    one_hot_program_row[program_row_sel_i] = 1'b1;
end : program_row_decode


/* Instantiate FU Array */

// These will get assigned via switchboxes 
fu_input_t fu_a_inputs [NUM_FU_ROWS][NUM_FU_COLS], fu_b_inputs [NUM_FU_ROWS][NUM_FU_COLS], fu_outputs [NUM_FU_ROWS][NUM_FU_COLS];
logic [(2*NUM_FU_ROWS)-1:0] [NUM_FU_COLS-1:0] intermediate_program_data;  // I hope this works

genvar fu_row, fu_col;
generate for (fu_col = 0; fu_col < NUM_FU_COLS; fu_col++) begin : create_fu_array

        // This will statically assign input and output pins
        assign fu_a_inputs[0][fu_col]               = deserialized_input_data_reg[fu_col];
        assign fu_b_inputs[0][fu_col]               = deserialized_input_data_reg[fu_col + 1];
        assign data_o[fu_col]                       = fu_outputs[NUM_FU_ROWS-1][fu_col];
        assign intermediate_program_data[0][fu_col] = program_data_i;

        // Generate actual FUs & SBs 
        for (fu_row = 0; fu_row < NUM_FU_ROWS; fu_row++) begin
            if (fu_row != 0) begin
                switchbox sb (
                    .clk_i(clk_i),
                    .program_en_i(one_hot_program_row[fu_row]),
                    // SB always goes odd index -> even index, and 2*row-1 -> 2*row
                    .program_data_i(intermediate_program_data[(2*fu_row)-1][fu_col]),
                    .program_data_o(intermediate_program_data[(2*fu_row)][fu_col]),

                    .prev_row_outputs_i(fu_outputs[fu_row-1][fu_col]),
                    .a_o(fu_a_inputs[fu_row][fu_col]),
                    .b_o(fu_b_inputs[fu_row][fu_col])
                );
            end

            functional_unit fu (
                .clk_i(clk_i), 
                .program_en_i(one_hot_program_row[fu_row]),
                // FU always goes even index -> odd index, and 2*row -> 2*row+1
                .program_data_i(intermediate_program_data_fu[(2*fu_row)][fu_col]),
                .program_data_o(intermediate_program_data_fu[(2*fu_row)+1][fu_col]),

                .a_i(fu_a_inputs[fu_row][fu_col]),
                .b_i(fu_b_inputs[fu_row][fu_col]),
                .result_o(fu_outputs[fu_row][fu_col])
            );
        end
    end
endgenerate


endmodule : cgra


/*
Some notes:

How to handle programming which inputs to use?
Do we make a separate switchbox, then how to program?
Otherwise can be done within the functional unit but added complexity

How to handle deserialization of inputs and serialization of outputs?
Maybe just have registers to shift into before the first row, then wire them up appropriately

For programming, should we use the same clock or have two clocks (one is user/CPU defined)
that we swap between

The programming indexing is as follows:
Row index 0 -> There is no SB 0, FU 0 takes in from 0 and outputs to 1
Row index 1 -> SB 1 takes in from 1 and outputs to 2, FU 1 takes in from 2 and outputs to 3
Row index 2 -> SB 2 takes in from 3 and outputs to 4, FU 2 takes in from 4 and outputs to 5
etc.

*/