load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# OWASP Dependencies Check tool
# https://jeremylong.github.io/DependencyCheck/dependency-check-cli/index.html
def dependencies():
    maybe(
        http_archive,
        name = "dependency_check",
        strip_prefix = "dependency-check",
        sha256 = "9f2e272d270f2b23d3c29870f372acedcce9befb1c884407edab9576d1423eb1",
        urls = [
            "https://github.com/jeremylong/DependencyCheck/releases/download/v8.3.1/dependency-check-8.3.1-release.zip",
        ],
        build_file = "@//dependency_check:BUILD.dependency_check",
    )
