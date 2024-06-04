load("@toolchains//:waveform_visualizer.bzl", "WaveformVisualizerToolchainInfo")

def _waveform_visualizer_impl(ctx):
    executable = ctx.actions.declare_output(ctx.attrs.out)
    ctx.attrs._waveform_visualizer_toolchain[WaveformVisualizerToolchainInfo].generate_viewing_executable(ctx, executable, ctx.attrs.input_files[DefaultInfo].default_outputs)
    return [
        DefaultInfo(default_output = executable),
        RunInfo(args = [executable])
    ]

waveform_visualizer = rule(
    impl = _waveform_visualizer_impl,
    attrs = {
        "out": attrs.string(),
        "input_files": attrs.dep(),
        "_waveform_visualizer_toolchain": attrs.toolchain_dep(
            providers=[WaveformVisualizerToolchainInfo],
            default="toolchains//:waveform_visualizer"
        )
    }
)