"""Functions for bundle related paths operations."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load(":files.bzl", "file_path")

def _farthest_parent_file_path(file, extension):
    """Returns part of a file path with the given extension closest to the root.

    For example, if `file` is `"foo/bar.bundle/baz.bundle"`, passing `".bundle"`
    as the extension will return `"foo/bar.bundle"`.

    Args:
        file: A `File`.
        extension: The extension of the directory to find.

    Returns:
        A `FilePath` with the portion of the path that ends in the given
        extension that is closest to the root of the path.
    """
    prefix, ext, _ = file.path.partition("." + extension)
    if ext:
        return file_path(file, prefix + ext)

    fail("Expected file.path %r to contain %r, but it did not" % (
        file,
        "." + extension,
    ))

def _owner_relative_file_path(file):
    """Returns the portion of a file path relative to its owner.

    Args:
        file: A `File`.

    Returns:
        The owner-relative `FilePath`.
    """
    if file.is_source:
        # Even though the docs says a File's `short_path` doesn't include the
        # root, Bazel special cases anything that is external and includes a
        # relative path (../) to the file. On the File's `owner` we can get the
        # `workspace_root` to try and line things up, but it is in the form of
        # "external/[name]". However the File's `path` does include the root and
        # leaves it in the "externa/" form.
        path = paths.relativize(
            file.path,
            paths.join(file.owner.workspace_root, file.owner.package),
        )
    elif file.owner.workspace_root:
        # Just like the above comment but for generated files, the same mangling
        # happen in `short_path`, but since it is generated, the `path` includes
        # the extra output directories bazel makes. So pick off what bazel will
        # do to the `short_path` ("../"), and turn it into an "external/" so a
        # relative path from the owner can be calculated.
        workspace_root = file.owner.workspace_root
        short_path = file.short_path
        if (not workspace_root.startswith("external/") or
            not short_path.startswith("../")):
            fail(("Generated file in a different workspace with unexpected " +
                  "short_path (%s) and owner.workspace_root (%r).") % (
                short_path,
                workspace_root,
            ))
        path = paths.relativize(
            "external" + short_path[2:],
            paths.join(file.owner.workspace_root, file.owner.package),
        )
    else:
        path = paths.relativize(file.short_path, file.owner.package)

    if not file.is_directory:
        path = paths.dirname(path).rstrip("/")

# Define the loadable module that lists the exported symbols in this file
bundle_paths = struct(
    farthest_parent_file_path = _farthest_parent_file_path,
    owner_relative_file_path = _owner_relative_file_path,
)
