load("@toolchains//:verilator.bzl", "VerilatorToolchainInfo")
load(":sv.bzl", "build_tset_from_deps", "VerilogInfo", "VerilogTopInfo")

def _verilator_binary_impl(ctx):
    folder = ctx.actions.declare_output("obj_dir", dir=True)
    executable = ctx.actions.declare_output(ctx.attrs.out)
    # ctx.actions.dynamic_output(
    #     dynamic = [folder],
    #     inputs = None, # ignored,
    #     outputs = [executable],
    #     f = lambda ctx, artifacts, outputs: 
    # )
    deps_tset = build_tset_from_deps(ctx, ctx.attrs.deps)
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
            "./Vtb"
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

def _verilator_binary_only_impl(ctx):
    folder = ctx.actions.declare_output("obj_dir", dir=True)
    deps_tset = build_tset_from_deps(ctx, ctx.attrs.deps)
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
            deps_tset.project_as_args("verilator"),
            ctx.attrs.module[VerilogInfo].tset.project_as_args("verilator"),
            "--top",
            ctx.attrs.module[VerilogTopInfo].top
        ],
        category = ctx.label.name
    )
    return [
        DefaultInfo(
            default_output = folder
        )
    ]

verilator_binary_only = rule(
    impl = _verilator_binary_only_impl,
    attrs = {
        "deps": attrs.list(attrs.dep(providers = [VerilogInfo])),
        "module": attrs.dep(providers = [VerilogInfo, VerilogTopInfo])
    }
)

verilator_binary = rule(
    impl = _verilator_binary_impl,
    attrs = {
        "out": attrs.string(),
        "deps": attrs.list(attrs.dep(providers = [VerilogInfo])),
        "module": attrs.dep(providers = [VerilogInfo, VerilogTopInfo])
        # "_verilator_toolchain": attrs.dep(providers = [VerilatorToolchainInfo])
    }
)