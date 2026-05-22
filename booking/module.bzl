"""\
Bazel extension module to pull extra dependencies for rules_booking

This dependency is internal for rules_booking
"""

load("//booking:repositories.bzl", "bazel_version")

def _extra_dependencies_impl(ctx):
    bazel_version(name = "bazel_version")

    return ctx.extension_metadata(
        root_module_direct_deps = [
            "bazel_version",
        ],
        root_module_direct_dev_deps = [],
    )

extra_dependencies = module_extension(
    implementation = _extra_dependencies_impl,
)
