#!/bin/sh

echo Container started

# ================================================================================================
# HOW THIS CONTAINER WORKS
# ================================================================================================
#
# - When container stops (compose down, etc.), it passes SIGTERM signal to PID 1 in container.
# - PID 1 is init process, which runs long running sleep process (see below) as a background process.
# - When init receives SIGTERM, it forwards SIGTERM to all processes in container,
#   which are all its children processes.
# - If some processes with own child processes (these are descendants of init) terminate without
#   parent passing SIGTERM and waiting for them to terminate, children become orphan processes.
# - Init will adopt these orphan children (i.e. become their parent) and pass SIGTERM to them.
#
# ================================================================================================

# Trap SIGTERM (e.g. from init when container stops) and exit with status 0 (i.e. success).
# Init will also stop other processes in container graciously,
# like bash which itself is running pnpm dev.
trap "exit 0" TERM

# If another command was run on CLI (i.e. passed in as arg to bin/sh -c),
# then the below ensures we replace this script process with process created by running command from CLI.
# I.e. it runs as one PID higher than it otherwise would (i.e. that process replaces this sh process).
# If so, nothing below this line is executed.
# Otherwise, we skip past below line and continue execution of this script.
exec "$@"

# sleep 1 second as background process, and wait here in this process until that sleep is done.
# Then, run loop again. Thus, this is a forever loop.
# When init gets SIGTERM from
# If we did not get replacement command, run long running process in background
while sleep 1 & wait $!; do :; done

echo "exited $0"
