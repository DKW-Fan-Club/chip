package types;

/* Chip-wide parameters */
parameter int NUM_DATA_INPUT_PINS = 8;
parameter int NUM_DATA_OUTPUT_PINS = 4;

parameter int NUM_FU_ROWS = 4;
parameter int NUM_FU_COLS = 4;

parameter int FU_COLS_BITS = $clog2(NUM_FU_COLS);
parameter int FU_ROWS_BITS = $clog2(NUM_FU_ROWS);


/* Width of inputs a, b to a functional unit */
parameter int FU_DATA_WIDTH = 16;

typedef logic [FU_DATA_WIDTH-1:0] fu_input_t;
typedef fu_input_t fu_output_t;

/* Functional Unit Programming */

// a_ means arithmetic op, l_ means logical op
// Need these prefixes because 'and' and 'or' are reserved keywords
typedef enum logic [2:0] {
    a_add   = 3'b000,
    a_sub   = 3'b001,
    pass_a  = 3'b010,
    pass_b  = 3'b011,
    l_and   = 3'b100,
    l_or    = 3'b101,
    l_xor   = 3'b110,
    l_not   = 3'b111
    // TODO add mult/div/rem + unsigned versions, more ALU ops, etc.
} fu_mode_t;

typedef struct packed {
    fu_mode_t mode;
    // ...
} fu_program_data_t;

/* Switchbox Programming */
typedef struct packed {
    logic [FU_COLS_BITS-1:0] a_sel;
    logic [FU_COLS_BITS-1:0] b_sel;
} sb_program_data_t;

endpackage