# rules_booking
Some Bazel rules we have built at Booking.com

# Usage

Add the following lines to your `WORKSPACE`

```language:python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

GIT_SHA="<GIT_SHA>"

http_archive(
    name = "rules_booking",
    urls = [
        "https://github.com/bookingcom/rules_booking/archive/{}.tar.gz".format(GIT_SHA)
    ],
    strip_prefix = "rules_booking_{}".format(GIT_SHA)
)
```

# Rules

## remap_tar

Sometimes you need to deploy a layer of assets into a container image where
all the content is static assets, in those cases is more convenient to use
`http_file` than `http_archive` to download the remote assets in bulk, but
`http_file` doesn't provide the convenient strip_prefix argument, so we
create `remap_tar` that allows to replace the original package prefix with
a prefix that's more suitable for your container image.

## gitlab_http_archive and gitlab_http_file

Similar to http_archive and http_file but aimed for downloading assets from
private gitlab repositories by using your own private tokens or CI job
tokens

# Developing

