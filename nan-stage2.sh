#!/bin/sh
set -eu

/opt/hermes/docker/stage2-upstream.sh

# Install the team workflow without replacing operator edits on later boots.
skill_dir="${HERMES_HOME:-/data}/skills/dhyana-meetings"
if [ "$(id -u)" = 0 ]; then
    s6-setuidgid hermes mkdir -p "$skill_dir"
    [ -e "$skill_dir/SKILL.md" ] || s6-setuidgid hermes cp /opt/hermes/nan-dhyana/SKILL.md "$skill_dir/SKILL.md"
else
    mkdir -p "$skill_dir"
    [ -e "$skill_dir/SKILL.md" ] || cp /opt/hermes/nan-dhyana/SKILL.md "$skill_dir/SKILL.md"
fi

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
