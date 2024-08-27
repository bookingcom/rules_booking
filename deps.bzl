"""\
Bazel extension module to pull extra dependencies for rules_booking

This dependency is internal for rules_booking
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _extra_dependencies_impl(ctx):
    # OWASP Dependencies Check tool
    # https://jeremylong.github.io/DependencyCheck/dependency-check-cli/index.html

    http_archive(
        name = "dependency_check",
        strip_prefix = "dependency-check",
        sha256 = "fac257d4e52be689685d1538cab8f02321adf1ff263f814228a12157b76bea3b",
        urls = [
            "https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.3/dependency-check-8.4.3-release.zip",
        ],
        build_file = "//dependency_check:BUILD.dependency_check",
    )

    return ctx.extension_metadata(
        root_module_direct_deps = [
            "dependency_check",
        ],
        root_module_direct_dev_deps = [],
    )

extra_dependencies = module_extension(
    implementation = _extra_dependencies_impl,
)
