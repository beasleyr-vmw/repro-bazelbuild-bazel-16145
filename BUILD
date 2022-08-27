load(":defs.bzl", "make_tree")

genrule(
    name = "hostname",
    outs = ["hostname.txt"],
    cmd = "hostname -s > $@",
    tags = ["no-remote"],
)

make_tree(
    name = "foo",
    hostname = ":hostname",
)

platform(
    name = "rbe_platform",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    exec_properties = {
        "OSFamily": "Linux",
    },
)
