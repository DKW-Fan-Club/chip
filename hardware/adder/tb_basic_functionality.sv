class testVector;
    rand bit a, b, cin;
endclass

module tb;
testVector vec;
bit a, b, cin;
bit s_actual, cout_actual;

task send_vector();
    a  = vec.a;
    b = vec.b;
    cin = vec.cin;
endtask

adder dut(.s(s_actual), .cout(cout_actual), .*);

initial begin
    $dumpfile("tb_basic_functionality.vcd");
    $dumpvars(0, tb);
    // insert your test vector here
    vec = new();
    repeat(100) begin
        /* verilator lint_off IGNOREDRETURN */
        vec.randomize();
        send_vector();
        #1
        if(~(s_actual === (a & b & cin))) begin
            $error("uh oh!");
        end
    end
end

endmodule