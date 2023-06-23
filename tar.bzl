load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@rules_pkg//pkg:mappings.bzl", "pkg_files", "strip_prefix")

def remap_tar(name, tar, old_prefix, new_prefix):
    """
    Generate a new tar.gz from an existing one but change it's internal structure

    Sometimes you need to put a layer of assets onto a docker image, and that layer gets downloaded
    from github, gitlab or whatever and contains a prefix that you want to not include into the
    resulting layer, this rule will repackage the package replacing old with new_prefix

    Args:
        name: resulting label
        tar: source .tar.gz label
        old_prefix: prefix in the source tar file
        new_prefix: prefix in the resulting tar file
    """
    if old_prefix.startswith("/"):
        old_prefix = old_prefix[1:]
    if new_prefix.startswith("/"):
        new_prefix = new_prefix[1:]
    native.genrule(
        name = name,
        srcs = [tar],
        outs = ["{}.tar.gz".format(name)],
        cmd = " && ".join([
            "set -e",
            "CWD=$$(pwd)",
            "mkdir temp",
            "cd temp",
            "tar -xf $$CWD/$(location {})".format(tar),
            "mkdir -p {}".format(new_prefix.rsplit("/", 2)[0]),
            "mv {} {}".format(old_prefix, new_prefix),  # map
            "tar -czf $$CWD/$@ `find . -type f`",  # ignore empty directories
        ]),
    )

def pkg_tar_with_structure(name, srcs = [], **kwargs):
    """
    Generate a pkg_tar target from a list of files out of a glob keeping the file structure

    Args:
        name: resulting label
        srcs: list of files, output of glob for instance
    """
    dirs = {}

    for x in srcs:
        dirname = paths.dirname(x)
        if dirname not in dirs:
            dirs[dirname] = []
        dirs[dirname].append(x)

    labels = []

    for dir, files in dirs.items():
        if len(files) == 0:
            continue

        label = "%s-%s" % (name, dir.replace("/", "_"))
        pkg_files(
            name = label,
            srcs = files,
            prefix = dir,
            strip_prefix = dir,
        )
        labels.append(label)

    pkg_tar(
        name = name,
        srcs = labels,
        **kwargs
    )
