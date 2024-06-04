## Install Steps

You should install the following items:

1. Rust
2. Verilator
3. GTKWave

Make sure that the following commands succeed: `which cargo`, `which verilator`, `which gtkwave`. If on windows, please use WSL.

Next, install `buck2` following the [official guide](https://buck2.build/docs/getting_started/).

Clone the repository and get started!

## Using Buck

Let's walk through a simple workflow: we wish to debug our `adder`.

1. Run `buck2 test //hardware/adder:all_tests`. You can observe that everything before the `:` is a path to a folder (containing our adder), and after the `:` is the name of a function inside the `BUCK` file at that folder.
2. We'll see that an assertion failed. Uh oh! `buck2` tells us this is from the test suite called `adder_basic_test`.
3. Run `buck2 run //hardware/adder:adder_basic_test_visualize`. This will open GTKWave, where you can explore the waveform and debug the issue.
4. Find the issue, and fix the testbench. Re-run the tests, and they should pass!
