load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def dependencies():
    maybe(
        http_archive,
        name = "dependency_check",
        strip_prefix = "dependency-check",
        sha256 = "937a6bf8ced9d8494767082c1f588f26ea379324cb089dabb045321e8b0ab01a",
        urls = [
            "https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip",
        ],
        build_file = "@rules_booking//booking/dependency_check:BUILD.dependency_check",
    )
