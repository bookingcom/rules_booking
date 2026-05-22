# rules_booking
Some Bazel rules we have built at Booking.com

# Usage

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

We use [buildifier](https://github.com/bazelbuild/buildtools/blob/master/buildifier/README.md)
to format our Bazel rules, please run:

```
bazel run @//dev:buildifier && bazel run //:gazelle
```

Before pushing
