#!/usr/bin/env bash
# Executes compose down for all
for dir in */; do [ -f "$dir/docker-compose.yml" ] && (cd "$dir" && docker compose down); done
