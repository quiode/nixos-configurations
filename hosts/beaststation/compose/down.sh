#!/usr/bin/env bash
# Executes compose down for all
for dir in */; do [ -f "$dir/compose.yml" ] && (cd "$dir" && docker compose down && cd -); done
# last shut down traefik
cd traefik && docker compose down && cd -
