#!/usr/bin/env bash
# Executes compose up for all
for dir in */; do [ -f "$dir/compose.yml" ] && (cd "$dir" && docker compose up -d --remove-orphans); done
