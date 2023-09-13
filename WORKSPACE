workspace(name = "rules_booking")

load("@//:repositories.bzl", "repositories")

repositories()

load("@//:dependencies.bzl", "dependencies")

dependencies()

load("@//dev:repositories.bzl", dev_repositories = "repositories")

dev_repositories()

load("@//dev:dependencies.bzl", dev_dependencies = "dependencies")

dev_dependencies()

load("@rules_jvm_external//:setup.bzl", "rules_jvm_external_setup")

rules_jvm_external_setup()

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "org.apache.logging.log4j:log4j-api:2.20.0",
        "org.apache.logging.log4j:log4j-core:2.20.0",
    ],
    repositories = [
        "https://maven.google.com",
        "https://repo1.maven.org/maven2",
    ],
)
