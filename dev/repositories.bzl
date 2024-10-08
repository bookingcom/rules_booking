load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file", "http_jar")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def dependencies():
    maybe(
        http_jar,
        name = "org_apache_logging_log4j_log4j_api",
        urls = [
            "https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.23.1/log4j-api-2.23.1.jar",
        ],
        sha256 = "92ec1fd36ab3bc09de6198d2d7c0914685c0f7127ea931acc32fd2ecdd82ea89",
    )
    maybe(
        http_jar,
        name = "org_apache_logging_log4j_log4j_core",
        urls = [
            "https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.23.1/log4j-core-2.23.1.jar",
        ],
        sha256 = "7079368005fc34f56248f57f8a8a53361c3a53e9007d556dbc66fc669df081b5",
    )
    maybe(
        http_file,
        name = "rules_java_7_9_0",
        urls = [
            "https://github.com/bazelbuild/rules_java/releases/download/7.9.0/rules_java-7.9.0.tar.gz",
        ],
        sha256 = "41131de4417de70b9597e6ebd515168ed0ba843a325dc54a81b92d7af9a7b3ea",
        downloaded_file_path = "test.tar.gz",
    )
