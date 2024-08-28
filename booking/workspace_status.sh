#!/usr/bin/env bash

function remove_url_credentials() {
  which perl >/dev/null && perl -pe 's#//.*?:.*?@#//#' || cat
}

repo_url=$(git config --get remote.origin.url | remove_url_credentials)
commit_sha=$(git rev-parse HEAD)
git_branch=$(git rev-parse --abbrev-ref HEAD)
git_tree_status=$(git diff-index --quiet HEAD -- && echo 'Clean' || echo 'Modified')

cat << EOF
BUILD_USER fake_user
BUILD_HOST fake_host
STABLE_DATE_TODAY $(date -u +%d-%m-%Y)
REPO_URL ${repo_url}
STABLE_REPO_URL ${repo_url}
COMMIT_SHA ${commit_sha}
GIT_BRANCH ${git_branch}
GIT_TREE_STATUS ${git_tree_status}
EOF
