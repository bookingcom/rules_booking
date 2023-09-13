load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("//dependency_check:deps.bzl", _dependency_check = "dependencies")

def dependencies():
    bazel_skylib_workspace()
    _dependency_check()
