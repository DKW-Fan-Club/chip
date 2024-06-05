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
        "deps": attrs.list(attrs.dep(providers = [VerilogInfo]), default = []),
        "srcs": attrs.list(attrs.source(), default = [])
    }
)

sv_module = rule(
    impl = _sv_module_impl,
    attrs = {
        "deps": attrs.list(attrs.dep(providers = [VerilogInfo]), default = []),
        "srcs": attrs.list(attrs.source(), default = []),
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

def sv_module_test(name=None, srcs=[], deps=[], top=None, generate_waveforms = True):
    module_name = "{}_module".format(name)
    sv_module(
        name=module_name,
        srcs=srcs,
        top=top,
        deps=deps
    )

    simulation_name = "{}_binary".format(name)
    sv_simulation(
        name = simulation_name,
        module = ":{}".format(module_name),
        out = "tb",
        generate_waveforms = generate_waveforms
    )

    sh_test(
        name = name,
        test = ":" + simulation_name,
        deps = [":" + simulation_name]
    )
    
    if generate_waveforms:
        waveform_name = "{}_visualize".format(name)
        waveform_visualizer(
            name = waveform_name,
            input_files = ":{}[waveform_folder]".format(simulation_name),
            out = "vis"
        )