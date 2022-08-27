def _impl(ctx):
    out = ctx.actions.declare_directory("foo.d")
    ctx.actions.run_shell(
        inputs = [ctx.file.hostname],
        outputs = [out],
        arguments = [ctx.file.hostname.path, out.path],
        command = """
hostname=$(<$1); shift
outdir=$1; shift

if [[ $(hostname -s) == $hostname ]]; then
    # Give remote branch a chance.
    sleep 5
fi

mkdir -p $outdir
for i in $(seq 1 5); do
    dd if=/dev/zero of=$outdir/dat.$i count=1 bs=$((2**i))k &>/dev/null
done
""",
    )
    return DefaultInfo(files = depset([out]))

make_tree = rule(
    implementation = _impl,
    attrs = {
        "hostname": attr.label(allow_single_file = True),
    },
)
