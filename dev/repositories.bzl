load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def dependencies():
    maybe(
        http_file,
        name = "rules_java_7_9_0",
        urls = [
            "https://github.com/bazelbuild/rules_java/releases/download/7.9.0/rules_java-7.9.0.tar.gz",
        ],
        sha256 = "41131de4417de70b9597e6ebd515168ed0ba843a325dc54a81b92d7af9a7b3ea",
        downloaded_file_path = "test.tar.gz",
    )
