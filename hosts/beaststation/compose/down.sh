#!/usr/bin/env bash
# Executes compose down for all
for dir in */; do [ -f "$dir/compose.yml" ] && (cd "$dir" && docker compose down); done
