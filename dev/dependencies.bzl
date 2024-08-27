load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
load("@googleapis//:repository_rules.bzl", "switched_rules_by_language")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

def dependencies():
    switched_rules_by_language(
        name = "com_google_googleapis_imports",
    )
    go_rules_dependencies()
    go_register_toolchains(version = "1.20.5")
    gazelle_dependencies()
    protobuf_deps()
