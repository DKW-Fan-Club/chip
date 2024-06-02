load("@toolchains//:verilator.bzl", "VerilatorToolchainInfo")
load(":sv.bzl", "build_tset_from_deps", "VerilogInfo", "VerilogTopInfo")

def _verilator_binary_impl(ctx):
    folder = ctx.actions.declare_output("obj_dir", dir=True)
    executable = ctx.actions.declare_output(ctx.attrs.out)
    deps_tset = build_tset_from_deps(ctx, ctx.attrs.deps)
    ctx.actions.run(
        [
            ctx.attrs._verilator_toolchain[VerilatorToolchainInfo].verilator_binary,
            "-cc",
            ctx.attrs._verilator_toolchain[VerilatorToolchainInfo].default_options,
            "--trace",
            "--trace-structs",
            "--timing",
            "--binary",
            "--main",
            "--Mdir",
            folder.as_output(),
            deps_tset.project_as_args("verilator"),
            ctx.attrs.module[VerilogInfo].tset.project_as_args("verilator"),
            "--top",
            ctx.attrs.module[VerilogTopInfo].top
        ],
        category = ctx.label.name
    )
    ctx.actions.write(
        executable,
        [
            "#!/bin/bash",
            "cd \\",
            folder,
            "./V" + ctx.attrs.module[VerilogTopInfo].top
        ],
        is_executable = True,
    )
    return [
        DefaultInfo(
            default_output = executable,
            other_outputs = [folder]
        ),
        RunInfo(
            [executable]
        )
    ]

verilator_binary = rule(
    impl = _verilator_binary_impl,
    attrs = {
        "out": attrs.string(),
        "deps": attrs.list(attrs.dep(providers = [VerilogInfo])),
        "module": attrs.dep(providers = [VerilogInfo, VerilogTopInfo]),
        "_verilator_toolchain": attrs.toolchain_dep(providers = [VerilatorToolchainInfo], default="toolchains//:verilator")
    }
)