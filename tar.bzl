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
        cmd = "&&".join([
            "CWD=$$(pwd)",
            "mkdir temp",
            "cd temp",
            "tar -xzf $$CWD/$(location {})".format(tar),
            "mkdir -p {}".format(new_prefix.rsplit("/", 2)[0]),
            "mv {} {}".format(old_prefix, new_prefix),  # map
            "tar -czf $$CWD/$@ `find . -type f`",  # ignore empty directories
        ]),
    )
