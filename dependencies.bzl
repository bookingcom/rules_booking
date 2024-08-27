load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")
load("//dependency_check:deps.bzl", _dependency_check = "dependencies")

def dependencies():
    bazel_skylib_workspace()
    _dependency_check()
    rules_java_dependencies()
    rules_java_toolchains()
