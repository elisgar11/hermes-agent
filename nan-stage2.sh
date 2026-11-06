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

# A named provider gives the Telegram picker an explicit chat-model catalog.
# Never overwrite a later change to this catalog on subsequent restarts.
catalog_marker="${HERMES_HOME:-/data}/.nan-model-catalog-v1"
if [ ! -e "$catalog_marker" ]; then
    if [ "$(id -u)" = 0 ]; then
        config() { s6-setuidgid hermes /opt/hermes/.venv/bin/hermes config set "$@"; }
    else
        config() { /opt/hermes/.venv/bin/hermes config set "$@"; }
    fi
    config providers.nan.api https://api.nan.builders/v1
    config providers.nan.key_env NAN_API_KEY
    config providers.nan.discover_models false
    config providers.nan.models '["deepseek-v4-flash","glm5.3-flash","qwen3.8-flash","mimo-v2.6-flash","qwen3.6","gemma4","glm5.3"]'
    if [ "$(id -u)" = 0 ]; then
        s6-setuidgid hermes touch "$catalog_marker"
    else
        touch "$catalog_marker"
    fi
fi
