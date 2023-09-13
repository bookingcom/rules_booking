"""Rules used for debugging cache state

When dealing with cache state, it's useful to be able to see
the workspace status as generated artifacts.
"""

def _impl(ctx):
    return DefaultInfo(
        files = depset([ctx.info_file, ctx.version_file]),
    )

workspace_status = rule(
    implementation = _impl,
)
