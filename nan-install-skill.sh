#!/bin/sh
set -eu

skill_home="${HERMES_HOME:-/data}"
skill_dir="$skill_home/skills/dhyana-meetings"
mkdir -p "$skill_dir"

install_managed() {
    source_file="$1"
    installed="$2"
    baseline="$3"
    default_file="${4:-}"
    if [ ! -e "$installed" ] || { [ -f "$baseline" ] && cmp -s "$installed" "$baseline"; } || \
       { [ -n "$default_file" ] && [ -f "$default_file" ] && cmp -s "$installed" "$default_file"; }; then
        cp "$source_file" "$installed"
        cp "$source_file" "$baseline"
    fi
}

install_managed /opt/hermes/nan-dhyana/SKILL.md "$skill_dir/SKILL.md" "$skill_home/.dhyana-meetings-managed"
install_managed /opt/hermes/nan-dhyana/SOUL.md "$skill_home/SOUL.md" "$skill_home/.dhyana-soul-managed" /opt/hermes/docker/SOUL.md
