# Reproduction case for bazelbuild/bazel issue #16145

This reproduction involves two actions:
- Action 1 records the client's hostname to a file named `hostname.txt`.
  This is used by Action 2 to further delay local execution such that
  the remote branch has a chance to win and cancel the local branch.
- Action 2 generates a tree artifact containing five files.
  This action compares the executing host's hostname against the
  content of `hostname.txt`, sleeping if the two match (i.e. this
  execution represents the local branch).

## Instructions
### Setup
- In Java IDE/debugger, set breakpoint at the following:
    - `RemoteExecutionService.java:1137` (`action.getSpawnExecutionContext().lockOutputFiles`)
- In a console, `watch -n .5 ls -l bazel-bin/foo.d`.
- Edit `.bazelrc` to fill in appropriate value for `--remote_executor`
  (or specify this on the command line).

### Launch and observe
- Launch Bazel : `bazel --host_jvm_debug build :foo.d`
- In your IDE/debugger, attach to Bazel daemon.
- Single-step through remote branch.
- Observations:
    - `.tmp` files have been downloaded to `bazel-bin/foo.d`.
    - While single-stepping, the local branch will complete and issue
      a cancellation for the remote branch.
    - When the remote branch reaches `DynamicSpawnStrategy.stopBranch`
      and evaluates `cancellingBranch.isCancelled`, it will discover it
      had been cancelled and throw a `DynamicInterruptedExecption`.
    - As the remote branch unwinds, the `.tmp` files remain in the output
      directory adjacent to the outputs from the local branch.
