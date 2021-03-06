load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

def dependencies():
    go_rules_dependencies()
    go_register_toolchains(version = "1.16.5")
    gazelle_dependencies()
    protobuf_deps()
