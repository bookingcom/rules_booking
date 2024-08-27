"""\
Bazel extension module to pull extra dependencies for dependency_check_test

This dependency is internal for rules_booking
"""

load(":repositories.bzl", _dependencies = "dependencies")

def _extra_dev_dependencies_impl(ctx):
    _dependencies()

    return ctx.extension_metadata(
        root_module_direct_deps = [
        ],
        root_module_direct_dev_deps = [
            "org_apache_logging_log4j_log4j_api",
            "org_apache_logging_log4j_log4j_core",
            "rules_java_7_9_0",
        ],
    )

extra_dev_dependencies = module_extension(
    implementation = _extra_dev_dependencies_impl,
)
