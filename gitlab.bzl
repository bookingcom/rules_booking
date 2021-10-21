load(
    "@bazel_tools//tools/build_defs/repo:utils.bzl",
    "patch",
    "read_netrc",
    "update_attrs",
    "use_netrc",
    "workspace_and_buildfile",
)
load("@bazel_skylib//lib:versions.bzl", "versions")

NETRC_FORMAT = """
machine {hostname}
    password {token}
"""

NETRC_ERROR = """
{path} file not found, please open https://{hostname}/-/profile/personal_access_tokens
and create a token with at least read_api access.

Then create the file {path} with the following content:
```
machine {hostname}
    password YOUR-TOKEN
```

For CI we expect CI_JOB_TOKEN to be defined, and we couldn't find it either
"""

def _get_netrc_path(ctx):
    """
    Returns the path to the netrc file for the given user

    Args:
        ctx: bazel repo rule context

    Returns:
        path to netrc file
    """

    if "CI_JOB_TOKEN" in ctx.os.environ:
        netrc_path = ".netrc"
        ctx.file(netrc_path, NETRC_FORMAT.format(hostname = ctx.attr.hostname, token = ctx.os.environ["CI_JOB_TOKEN"]))
        return netrc_path
    if not ctx.os.name.startswith("windows"):
        return "%s/.netrc" % (ctx.os.environ["HOME"])

    return "%s/.netrc" % (ctx.os.environ["USERPROFILE"])

def _file_exists(ctx, path):
    """
    Checks if a file exists in the file system

    Args:
        ctx: bazel repo rule context
        path: path to the target

    Returns:
        True if file exists in the given path
    """
    if not ctx.os.name.startswith("windows"):
        return ctx.execute(["test", "-f", path]).return_code == 0
    else:
        return ctx.path(path).exists

def _has_netrc(ctx):
    """
    Checks if the netrc file is provided through the environment

    If it doesn't exist then we fail in a lazy mode, only when the relevant repository
    is used user will see the issue

    Args:
        ctx: bazel repo rule context
    """

    hostname = ctx.attr.hostname
    netrcfile = _get_netrc_path(ctx)
    if not _file_exists(ctx, netrcfile):
        fail(NETRC_ERROR.format(path = netrcfile, hostname = hostname))

_gitlab_attrs = {
    "project_name": attr.string(
        doc = "Gitlab project name from which to download the archive",
        mandatory = True,
    ),
    "git_sha": attr.string(
        doc = "Git sha from which to create the archive",
        mandatory = True,
    ),
    "hostname": attr.string(
        doc = "Hostname to Gitlab",
        default = "gitlab.com",
    ),
    "protocol": attr.string(
        doc = "Protocol to use https/http",
        default = "https",
    ),
    "path": attr.string(
        doc = "Path inside the project to download, note this feature requires Gitlab 14.04+",
        mandatory = False,
    ),
}

def _encode_path(x):
    return x.replace("/", "%2F")

ARCHIVE_URL = "{protocol}://{hostname}/api/v4/projects/{project_name}/repository/archive.tar.gz?sha={sha}"

def _get_url(ctx):
    url = ARCHIVE_URL.format(
        hostname = ctx.attr.hostname,
        project_name = _encode_path(ctx.attr.project_name),
        sha = ctx.attr.git_sha,
        protocol = ctx.attr.protocol,
    )
    if ctx.attr.path:
        url = "{}&path={}".format(url, _encode_path(ctx.attr.path))

    return [url]

def _gitlab_http_archive_impl(ctx):
    """Implementation of the gitlab_http_archive rule."""
    hostname = ctx.attr.hostname
    netrc_path = _get_netrc_path(ctx)

    if not _has_netrc(ctx):
        # fail already called by now so this pass will never get executed
        pass

    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))

    if ctx.attr.build_file and ctx.attr.build_file_content:
        fail("Only one of build_file and build_file_content can be provided.")

    all_urls = _get_url(ctx)
    netrc = read_netrc(ctx, netrc_path)
    auth = use_netrc(netrc, all_urls, {hostname: "Bearer <password>"})

    download_info = ctx.download_and_extract(
        all_urls,
        "",
        ctx.attr.sha256,
        "tar.gz",
        ctx.attr.strip_prefix,
        canonical_id = ctx.attr.canonical_id,
        auth = auth,
        integrity = ctx.attr.integrity,
    )
    workspace_and_buildfile(ctx)
    if versions.is_at_most("4.9.9", native.bazel_version):
        patch(ctx)
    else:
        patch(ctx, auth = auth)

    # We don't need to override the sha256 attribute if integrity is already specified.
    sha256_override = {} if ctx.attr.integrity else {"sha256": download_info.sha256}
    return update_attrs(ctx.attr, _http_archive_attrs.keys(), sha256_override)

# literally copied from https://github.com/bazelbuild/bazel/blob/master/tools/build_defs/repo/http.bzl#L96
_http_archive_attrs = {
    "sha256": attr.string(),
    "strip_prefix": attr.string(),
    "patches": attr.label_list(
        default = [],
    ),
    "remote_patches": attr.string_dict(
        default = {},
    ),
    "remote_patch_strip": attr.int(
        default = 0,
    ),
    "patch_tool": attr.string(
        default = "",
    ),
    "patch_args": attr.string_list(
        default = ["-p0"],
    ),
    "patch_cmds": attr.string_list(
        default = [],
    ),
    "patch_cmds_win": attr.string_list(
        default = [],
    ),
    "build_file": attr.label(
        allow_single_file = True,
    ),
    "build_file_content": attr.string(),
    "workspace_file": attr.label(),
    "workspace_file_content": attr.string(),
    "canonical_id": attr.string(),
    "integrity": attr.string(),
}

_http_archive_attrs.update(_gitlab_attrs)
gitlab_http_archive = repository_rule(
    implementation = _gitlab_http_archive_impl,
    attrs = _http_archive_attrs,
    doc = """Downloads a Bazel repository stored in a gitlab repository as a compressed 
archive file, decompresses it, and makes its targets available for binding.

It's heavily based on http_archive, so check it's documentation. It will check for netrc
to be available or for CI_JOB_TOKEN to be passed through the environment.
""",
)

_HTTP_FILE_BUILD = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "file",
    srcs = ["{}"],
)
"""

def _gitlab_http_file_impl(ctx):
    """Implementation of the http_file rule."""
    hostname = ctx.attr.hostname
    netrc_path = _get_netrc_path(ctx)

    if not _has_netrc(ctx):
        # fail already called by now so this pass will never get executed
        pass

    repo_root = ctx.path(".")
    forbidden_files = [
        repo_root,
        ctx.path("WORKSPACE"),
        ctx.path("BUILD"),
        ctx.path("BUILD.bazel"),
        ctx.path("file/BUILD"),
        ctx.path("file/BUILD.bazel"),
    ]
    downloaded_file_path = ctx.attr.downloaded_file_path
    download_path = ctx.path("file/" + downloaded_file_path)
    if download_path in forbidden_files or not str(download_path).startswith(str(repo_root)):
        fail("'%s' cannot be used as downloaded_file_path in http_file" % ctx.attr.downloaded_file_path)

    urls = _get_url(ctx)
    netrc = read_netrc(ctx, netrc_path)
    auth = use_netrc(netrc, urls, {hostname: "Bearer <password>"})

    download_info = ctx.download(
        urls,
        "file/" + downloaded_file_path,
        ctx.attr.sha256,
        ctx.attr.executable,
        canonical_id = ctx.attr.canonical_id,
        auth = auth,
    )
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))
    ctx.file("file/BUILD", _HTTP_FILE_BUILD.format(downloaded_file_path))

    return update_attrs(ctx.attr, _http_file_attrs.keys(), {"sha256": download_info.sha256})

_http_file_attrs = {
    "executable": attr.bool(),
    "downloaded_file_path": attr.string(
        default = "downloaded.tar.gz",
    ),
    "sha256": attr.string(),
    "canonical_id": attr.string(),
}

_http_file_attrs.update(_gitlab_attrs)
gitlab_http_file = repository_rule(
    implementation = _gitlab_http_file_impl,
    attrs = _http_file_attrs,
    doc =
        """Downloads a file from a Gitlab URL and makes it available to be used as a file
group.

Check http_file for more detauls
""",
)
