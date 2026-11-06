#!/bin/sh
set -eu

/opt/hermes/docker/stage2-upstream.sh

# The persistent home may already have been seeded by an earlier deployment.
# Configure NaN STT once without overwriting later operator edits on restart.
marker="${HERMES_HOME:-/data}/.nan-stt-configured"
if [ ! -e "$marker" ]; then
    if [ "$(id -u)" = 0 ]; then
        s6-setuidgid hermes /opt/hermes/.venv/bin/hermes config set stt.provider openai
        s6-setuidgid hermes touch "$marker"
    else
        /opt/hermes/.venv/bin/hermes config set stt.provider openai
        touch "$marker"
    fi
fi
