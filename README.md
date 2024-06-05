## Install Steps

You should install the following items:

1. Rust
2. Verilator
3. GTKWave

Make sure that the following commands succeed: `which cargo`, `which verilator`, `which gtkwave`. If on windows, please use WSL.

Next, install `buck2` following the [official guide](https://buck2.build/docs/getting_started/).

Clone the repository and get started!

## Using Buck

### Simple Tutorial

Let's walk through a simple workflow: we wish to debug our `adder`.

1. Run `buck2 test //hardware/adder:all_tests`. You can observe that everything before the `:` is a path to a folder (containing our adder), and after the `:` is the name of a function inside the `BUCK` file at that folder.
2. We'll see that an assertion failed. Uh oh! `buck2` tells us this is from the test suite called `adder_basic_test`.
3. Run `buck2 run //hardware/adder:adder_basic_test_visualize`. This will open GTKWave, where you can explore the waveform and debug the issue.
4. Find the issue, and fix the testbench. Re-run the tests, and they should pass!

### Creating a new module

Run `buck2 run //utils:create_module name_of_module` to create a new module. This will:

-   set up the Buck build for your module
-   create hardware/name_of_module/name_of_module.sv for your module's code
-   create hardware/name_of_module/tb.sv for a basic testbench

By default, your module will have a dependency on the shared `types` package. If you wish to add additional dependencies, follow the format of how dependencies are declared for the `cgra` module.

If other modules will depend on your module, you must edit is visibility list to include those modules. You can find an example visibility list on the `functional_unit` module.

Once you have written your module, you can test it like we did in the basic tutorial.

### Adding more tests to your module

Logically separate tests should be placed in separate testbenches. This makes debugging easier. To add a new testbench, create a new `.sv` file for it, and add the following to your `BUCK` file:

```
sv_module(
    name = "name_of_test",
    srcs = ["name_of_test.sv"],
    top = "tb",
    deps = [":your_module"]
)
sv_module_test(
    name = "name_of_test",
    module = ":name_of_test"
)
```

Then, add `":name_of_test"` to the array of tests for the `all_tests` group.
