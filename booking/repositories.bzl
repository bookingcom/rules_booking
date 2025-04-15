load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_skylib():
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
    )

def rules_java():
    if native.bazel_version.startswith("7."):
        maybe(
            http_archive,
            name = "rules_java",
            urls = [
                "https://github.com/bazelbuild/rules_java/releases/download/7.9.0/rules_java-7.9.0.tar.gz",
            ],
            sha256 = "41131de4417de70b9597e6ebd515168ed0ba843a325dc54a81b92d7af9a7b3ea",
        )
    elif native.bazel_version.startswith("6."):
        maybe(
            http_archive,
            name = "rules_java",
            urls = [
                "https://github.com/bazelbuild/rules_java/releases/download/6.5.2/rules_java-6.5.2.tar.gz",
            ],
            sha256 = "16bc94b1a3c64f2c36ceecddc9e09a643e80937076b97e934b96a8f715ed1eaa",
        )
    else:
        fail("Unsupported Bazel version: {}, at lest need 6.x".format(native.bazel_version))

def rules_pkg():
    maybe(
        http_archive,
        name = "rules_pkg",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/1.0.1/rules_pkg-1.0.1.tar.gz",
            "https://github.com/bazelbuild/rules_pkg/releases/download/1.0.1/rules_pkg-1.0.1.tar.gz",
        ],
        sha256 = "d20c951960ed77cb7b341c2a59488534e494d5ad1d30c4818c736d57772a9fef",
    )

_BAZEL_VERSION_BZL = """\
def get_bazel_version():
    return "{}"

"""

_BAZEL_VERSION_BUILD = """\
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(":bazel_version.bzl", "get_bazel_version")

exports_files(["bazel_version.bzl"])
print("bazel_version.bzl is {}".format(get_bazel_version()))

bzl_library(
    name = "bazel_version",
    srcs = ["bazel_version.bzl"],
    visibility = ["//visibility:public"],
)
"""

def _bazel_version_impl(repo_ctx):
    repo_ctx.file("BUILD.bazel", _BAZEL_VERSION_BUILD)
    repo_ctx.file("bazel_version.bzl", _BAZEL_VERSION_BZL.format(native.bazel_version))
    repo_ctx.file("WORKSPACE", "")

bazel_version = repository_rule(
    implementation = _bazel_version_impl,
)

def repositories():
    bazel_skylib()
    rules_java()
    rules_pkg()
