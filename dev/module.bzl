"""\
Bazel extension module to pull extra dependencies for dependency_check_test

This dependency is internal for rules_booking
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _extra_dev_dependencies_impl(ctx):
    maybe(
        http_file,
        name = "rules_java_7_9_0",
        urls = [
            "https://github.com/bazelbuild/rules_java/releases/download/7.9.0/rules_java-7.9.0.tar.gz",
        ],
        sha256 = "41131de4417de70b9597e6ebd515168ed0ba843a325dc54a81b92d7af9a7b3ea",
        downloaded_file_path = "test.tar.gz",
    )

    return ctx.extension_metadata(
        root_module_direct_deps = [
        ],
        root_module_direct_dev_deps = [
            "rules_java_7_9_0",
        ],
    )

extra_dev_dependencies = module_extension(
    implementation = _extra_dev_dependencies_impl,
)
