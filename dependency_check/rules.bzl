"""Rules for doing dependency check from Bazel

The rules are split in a cache for the database and a the execution it self,
we recommend that you have a line like this in your workspace status:

```
STABLE_DATE_TODAY $(date -u +%d-%m-%Y)
```
"""

def _cache_impl(ctx):
    """Runs dependency-check-cli to create an OWASP vulnerabilities database"""
    output = ctx.actions.declare_directory("database")

    args = [
        "--data",
        output.path,
        "--updateonly",
    ] + ctx.attr.arguments

    ctx.actions.run(
        outputs = [output],
        inputs = [ctx.info_file],
        tools = [ctx.executable._client],
        executable = ctx.executable._client,
        arguments = args,
        mnemonic = "DependencyCheckDB",
        progress_message = "Updating dependency check database: %s" % ctx.label,
    )

    return DefaultInfo(
        files = depset([output, ctx.info_file]),
    )

cache = rule(
    implementation = _cache_impl,
    doc = """\
Runs dependency-check-cli to create an OWASP vulnerabilities database

This rule helps with creating an OWASP vulnerabilities database that can then
be passed as an argument to <other rule> to avoid redownloading the database
more often than needed.
""",
    attrs = {
        "arguments": attr.string_list(
            mandatory = False,
            allow_empty = True,
            doc = "list of extra argumnets to pass when generating the database",
        ),
        "_client": attr.label(
            default = "@dependency_check//:cli",
            executable = True,
            cfg = "exec",
        ),
    },
)

def _dependecy_check_impl(ctx):
    """Runs dependency-check-cli"""

    transitive_deps = []

    for t in ctx.attr.targets:
        transitive_deps.extend(
            [t[JavaInfo].transitive_deps] +
            [t[JavaInfo].transitive_runtime_deps] +
            [t[DefaultInfo].default_runfiles.files],
        )

    transitive_deps = depset(transitive = transitive_deps).to_list()

    current_workspace = ctx.label.workspace_name
    external_deps = [
        x.path
        for x in transitive_deps
        if x.owner.workspace_name != current_workspace
    ]

    if len(external_deps) == 0:
        return DefaultInfo()

    outputs = [
        ctx.actions.declare_file("%s-dependency-check-report.xml" % ctx.label.name),
        ctx.actions.declare_file("%s-dependency-check-report.html" % ctx.label.name),
        ctx.actions.declare_file("%s-dependency-check-report.json" % ctx.label.name),
    ]

    clean_cache = "%s/../clean-cache" % outputs[0].dirname

    args = [
        "--noupdate",
        "--data",
        clean_cache,
        "--out",
        outputs[0].dirname,
        "--format",
        "HTML",
        "--format",
        "XML",
        "--format",
        "JSON",
        "--symLink",
        "1000",
        "--project",
        ctx.attr.project_key,
    ]

    for dep in transitive_deps:
        args.extend(["--scan", dep.path])

    if ctx.file.suppression:
        args.extend(["--suppression", ctx.file.suppression.short_path])
        transitive_deps = transitive_deps + [ctx.file.suppression]

    if ctx.attr.verbose_log:
        log = ctx.actions.declare_file("log.txt")
        outputs.append(log)
        args.extend(["--log", log.path])

    args.extend(ctx.attr.arguments)

    commands = [
        "#!/bin/bash",
        "set -e -o pipefail",
        "cp -Lr %s %s" % (ctx.files.cache[0].path, clean_cache),
        "chmod -R +w %s" % clean_cache,
        "%s %s" % (ctx.executable._client.path, " ".join(args)),
        "pushd %s" % outputs[0].dirname,
        "mv dependency-check-report.xml %s-dependency-check-report.xml" % ctx.label.name,
        "mv dependency-check-report.html %s-dependency-check-report.html" % ctx.label.name,
        "mv dependency-check-report.json %s-dependency-check-report.json" % ctx.label.name,
    ]

    script = ctx.actions.declare_file("%s-script.sh" % ctx.label.name)

    ctx.actions.write(
        output = script,
        content = "\n".join(commands),
        is_executable = True,
    )

    ctx.actions.run_shell(
        outputs = outputs,
        inputs = transitive_deps + ctx.files.cache,
        tools = [ctx.executable._client, script],
        command = script.path,
        mnemonic = "DependencyCheck",
        progress_message = "Doing Dependency Check: %s" % ctx.label,
    )

    return DefaultInfo(
        files = depset(outputs),
    )

dependency_check = rule(
    implementation = _dependecy_check_impl,
    doc = """\
Runs dependency-check-cli against your target

This rules is a wrapper for [Dependency Check](https://github.com/jeremylong/DependencyCheck),
it uses a cached database and a few other features
""",
    attrs = {
        "targets": attr.label_list(
            mandatory = True,
            doc = "Bazel Java targets to check",
            providers = [JavaInfo],
        ),
        "project_key": attr.string(
            mandatory = True,
            doc = "The name of the project being scanned.",
        ),
        "suppression": attr.label(
            allow_single_file = True,
            default = None,
            mandatory = False,
            doc = """A file to suppress false-positives.""",
        ),
        "verbose_log": attr.bool(
            default = False,
            doc = "If enabled, dependency-check cli writes DEBUG logs to log.txt file",
        ),
        "arguments": attr.string_list(
            mandatory = False,
            allow_empty = True,
            doc = "list of extra argumnets to pass when generating the database",
        ),
        "cache": attr.label(
            default = ":cache",
            allow_files = True,
            cfg = "exec",
        ),
        "_client": attr.label(
            default = "@dependency_check//:cli",
            executable = True,
            cfg = "exec",
        ),
    },
)
