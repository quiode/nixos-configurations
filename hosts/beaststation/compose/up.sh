#!/usr/bin/env bash
# First start traefik
cd traefik && docker compose up -d --remove-orphans && cd -
# Executes compose up for all
for dir in */; do [ -f "$dir/compose.yml" ] && (cd "$dir" && docker compose up -d --remove-orphans && cd -); done
