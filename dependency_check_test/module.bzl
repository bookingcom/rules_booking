"""\
Bazel extension module to pull extra dependencies for dependency_check_test

This dependency is internal for rules_booking
"""

load("@rules_booking//dependency_check_test:repositories.bzl", _dependencies = "dependencies")

def _extra_dev_dependencies_impl(ctx):
    _dependencies()

    return ctx.extension_metadata(
        root_module_direct_deps = [
        ],
        root_module_direct_dev_deps = [
            "org_apache_logging_log4j_log4j_api",
            "org_apache_logging_log4j_log4j_core",
        ],
    )

extra_dev_dependencies = module_extension(
    implementation = _extra_dev_dependencies_impl,
)
