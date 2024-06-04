load("@toolchains//:simulator.bzl", "SimulatorToolchainInfo")
load("@prelude//:rules.bzl", "sh_test")
load(":waveform_visualizer.bzl", "waveform_visualizer")

VerilogInfo = provider(
    fields = ["tset"]
)

VerilogTopInfo = provider(
    fields = ["top"]
)

VerilogManifest = record(
    srcs = list
)

def project_as_verilator(value: VerilogManifest):
    return value.srcs

VerilogTset = transitive_set(args_projections = {"verilator": project_as_verilator})

def build_tset_from_deps(ctx, deps):
    return ctx.actions.tset(VerilogTset, value = VerilogManifest(srcs = []), children = [d[VerilogInfo].tset for d in ctx.attrs.deps])

def _sv_library_impl(ctx):
    s = ctx.actions.tset(
        VerilogTset,
        value = VerilogManifest(srcs = ctx.attrs.srcs),
        children = [d[VerilogInfo].tset for d in ctx.attrs.deps if VerilogInfo in d]
    )
    return [
        DefaultInfo(),
        VerilogInfo(tset = s)
    ]

def _sv_module_impl(ctx):
    s = ctx.actions.tset(
        VerilogTset,
        value = VerilogManifest(srcs = ctx.attrs.srcs),
        children = [d[VerilogInfo].tset for d in ctx.attrs.deps if VerilogInfo in d]
    )
    return [
        DefaultInfo(),
        VerilogInfo(tset = s),
        VerilogTopInfo(top = ctx.attrs.top)
    ]

def _sv_simulation_impl(ctx):
    waveform_folder = ctx.actions.declare_output("obj_dir", dir=True)
    executable = ctx.actions.declare_output(ctx.attrs.out)
    ctx.attrs._simulator_toolchain[SimulatorToolchainInfo].generate_sim_executable(
        ctx,
        waveform_folder,
        ctx.attrs.module[VerilogInfo].tset,
        ctx.attrs.module[VerilogTopInfo].top,
        executable,
        ctx.attrs.generate_waveforms
    )
    return [
        DefaultInfo(
            default_output = executable,
            other_outputs = [waveform_folder],
            sub_targets = {
                "waveform_folder": [DefaultInfo(default_output = waveform_folder)]
            }
        ),
        RunInfo(
            [executable]
        )
    ]

sv_library = rule(
    impl = _sv_library_impl,
    attrs = {
        "deps": attrs.list(attrs.dep(providers = [VerilogInfo])),
        "srcs": attrs.list(attrs.source())
    }
)

sv_module = rule(
    impl = _sv_module_impl,
    attrs = {
        "deps": attrs.list(attrs.dep(providers = [VerilogInfo])),
        "srcs": attrs.list(attrs.source()),
        "top": attrs.string() 
    }
)

sv_simulation = rule(
    impl = _sv_simulation_impl,
    attrs = {
        "module": attrs.dep(providers = [VerilogInfo, VerilogTopInfo]),
        "out": attrs.string(),
        "generate_waveforms": attrs.bool(default = False),
        "_simulator_toolchain": attrs.toolchain_dep(default = "toolchains//:simulator")
    }
)

def sv_module_test(name=None, module=None, generate_waveforms=True):
    sv_simulation(
        name = name + "_binary",
        module = module,
        out = "atb",
        generate_waveforms = generate_waveforms
    )

    sh_test(
        name = name,
        test = ":" + name + "_binary",
        deps = [":" + name + "_binary"]
    )
    
    if generate_waveforms:
        waveform_visualizer(
            name = "{}_visualize".format(name),
            input_files = ":{}_binary[waveform_folder]".format(name),
            out = "vis"
        )