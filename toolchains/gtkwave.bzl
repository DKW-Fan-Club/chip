load(":waveform_visualizer.bzl", "WaveformVisualizerToolchainInfo")

def _gtkwave_generate_viewing_executable(gtkwave_executable):
    def _generate(ctx, executable, search_folder):
        ctx.actions.write(
            executable,
            [
                "#!/bin/bash",
                "cd \\",
                search_folder,
                "for f in *.vcd; do",
                "{} $f &".format(gtkwave_executable),
                "done"
            ],
            is_executable = True
        )
    return _generate

def _system_gtkwave_toolchain_impl(ctx):
    return [
        DefaultInfo(),
        WaveformVisualizerToolchainInfo(
            generate_viewing_executable = _gtkwave_generate_viewing_executable("gtkwave")
        )
    ]

system_gtkwave_toolchain = rule(
    impl = _system_gtkwave_toolchain_impl,
    is_toolchain_rule = True,
    attrs = {}
)