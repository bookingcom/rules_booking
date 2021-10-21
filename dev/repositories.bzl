load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def io_bazel_rules_go():
    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "8e968b5fcea1d2d64071872b12737bbb5514524ee5f0a4f54f5920266c261acb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.28.0/rules_go-v0.28.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.28.0/rules_go-v0.28.0.zip",
        ],
    )

def bazel_gazelle():
    maybe(
        http_archive,
        name = "bazel_gazelle",
        sha256 = "62ca106be173579c0a167deb23358fdfe71ffa1e4cfdddf5582af26520f1c66f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.23.0/bazel-gazelle-v0.23.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.23.0/bazel-gazelle-v0.23.0.tar.gz",
        ],
    )

def com_google_protobuf():
    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "9b4ee22c250fe31b16f1a24d61467e40780a3fbb9b91c3b65be2a376ed913a1a",
        strip_prefix = "protobuf-3.13.0",
        urls = [
            "https://github.com/protocolbuffers/protobuf/archive/v3.13.0.tar.gz",
        ],
    )

def com_github_bazelbuild_buildtools():
    maybe(
        http_archive,
        name = "com_github_bazelbuild_buildtools",
        sha256 = "d49976b0b1e81146d79072f10cabe6634afcd318b1bd86b0102d5967121c43c1",
        strip_prefix = "buildtools-4.2.0",
        urls = [
            "https://github.com/bazelbuild/buildtools/archive/refs/tags/4.2.0.tar.gz",
        ],
    )

def repositories():
    io_bazel_rules_go()
    bazel_gazelle()
    com_google_protobuf()
    com_github_bazelbuild_buildtools()
