module adder (
    input bit a,
    input bit b,
    input bit cin,
    output bit s,
    output bit cout
);
    wire [1:0] temp;
    assign temp = a + b + cin;
    assign s = temp[0];
    assign cout = temp[1];
endmodule
