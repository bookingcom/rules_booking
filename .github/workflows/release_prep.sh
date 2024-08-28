#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables

# The prefix is chosen to match what GitHub generates for source archives
PREFIX="rules_booking-${GITHUB_REF_NAME}"
ARCHIVE="${PREFIX}.tar.gz"
ARCHIVE_TMP=$(mktemp)

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ --worktree-attributes  ${GITHUB_REF_NAME} > $ARCHIVE_TMP

# we could patch the tar here if we needed binaries

gzip < $ARCHIVE_TMP > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')
INTEGRITY=$(openssl dgst -sha256 -binary $ARCHIVE | openssl base64 -A | sed 's/^/sha256-/')

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
REPO_URL="https://github.com/${GITHUB_REPOSITORY:-bookingcom/rules_booking}"

cat << EOF
## Using [Bzlmod] with Bazel 6:

Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_booking", version = "${GITHUB_REF_NAME:1}")

archive_override(
    module_name = "rules_booking",
    integrity = "${INTEGRITY}",
    urls = [
        "${REPO_URL}/releases/download/${GITHUB_REF_NAME}/${ARCHIVE}",
    ]
)

\`\`\`

[Bzlmod]: https://bazel.build/build/bzlmod

## Using WORKSPACE

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_booking",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "${REPO_URL}/releases/download/${GITHUB_REF_NAME}/${ARCHIVE}",
)

load(
    "@rules_booking//:repositories.bzl",
    rules_booking_repositories = "repositories",
)

rules_booking_repositories()

load(
    "@rules_booking//:dependencies.bzl",
    rules_booking_dependencies = "dependencies",
)

rules_booking_dependencies()

\`\`\`
EOF
