load(":simulator.bzl", "SimulatorToolchainInfo")
VerilatorToolchainInfo = provider(
    fields = [
        "verilator_binary"
    ]
)

def _system_verilator_toolchain_impl(ctx):
    return [
        DefaultInfo(),
        VerilatorToolchainInfo(verilator_binary = RunInfo(args = ctx.attrs.verilator_binary))
    ]

system_verilator_toolchain = rule(
    impl = _system_verilator_toolchain_impl,
    attrs = {
        "verilator_binary": attrs.string(default = "verilator", doc = "Verilator executable name or path"),
    },
    is_toolchain_rule = True
)

def _verilator_generate_sim_executable(toolchain):
    def _generate(ctx, folder, module_deps, module_top, executable):
        ctx.actions.run(
            [
                "verilator",
                "-cc",
                "-Wno-fatal",
                "--trace",
                "--trace-structs",
                "--timing",
                "--binary",
                "--main",
                "--Mdir",
                folder.as_output(),
                module_deps.project_as_args("verilator"),
                "--top",
                module_top
            ],
            category = ctx.label.name
        )
        ctx.actions.write(
            executable,
            [
                "#!/bin/bash",
                "cd \\",
                folder,
                "./Vtb"
            ],
            is_executable = True
        )
    return _generate

def _verilator_simulator_toolchain_impl(ctx):
    return [
        DefaultInfo(),
        SimulatorToolchainInfo(
            generate_sim_executable = _verilator_generate_sim_executable(ctx.attrs._verilator_toolchain)
        )
    ]

verilator_simulator_toolchain = rule(
    impl = _verilator_simulator_toolchain_impl,
    attrs = {
        "_verilator_toolchain": attrs.toolchain_dep(providers = [VerilatorToolchainInfo], default = "toolchains//:verilator"),
        "verilator_args": attrs.option(attrs.list(attrs.arg()), default = None)
    },
    is_toolchain_rule = True
)