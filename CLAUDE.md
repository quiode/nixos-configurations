# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal NixOS flake repository ("nichts"-style, inspired by https://codeberg.org/bloxx12/nichts) that defines the configuration for all of the user's machines: `beaststation` (home server), `artemis` (gaming PC), `hades` (ASUS ROG gaming laptop), and `hermes` (Raspberry Pi). Everything is built from a single flake and modularized under `modules.*` options.

## Commands

Run `nix develop` to enter the dev shell, which provides these helper scripts (defined in `shell.nix`):

- `update`: `nix flake update --flake .` (update flake inputs)
- `upgrade-now`: `nh os switch` (build and switch the current host to the new config immediately)
- `upgrade-later`: `nh os boot` (build and set the new config for next boot)
- `push`: `nix flake check && git push` (never push without a successful flake check first)
- `format`: `alejandra .` (the only formatter used in this repo; CI enforces `alejandra -c .`)
- `occ`: runs `php occ` inside the Nextcloud docker container on beaststation

Other useful commands:

- `nix flake check --all-systems`: what CI (`.gitlab-ci.yml`) runs on every push. Validates all `nixosConfigurations` build and that formatting is clean.
- `nixos-rebuild build --flake .#<host>`: build a specific host's config without switching, useful to sanity-check changes to a host you're not on.
- `alejandra <path>`: format a single file instead of the whole repo.

There are no application-level unit tests; "testing" a change means it evaluates/builds (`nix flake check`) and is correctly formatted.

## Architecture

### Flake wiring (`flake.nix` + `hosts/default.nix`)

`hosts/default.nix` exports `mkSystem { system, hostname }`, which builds a `nixosSystem` for each host by importing, in order:
1. `home-manager`, `agenix`, and `nvf` NixOS modules (always present).
2. `hosts/<hostname>/default.nix`, the host-specific entry point (just imports `hardware-configuration.nix` and `configuration.nix` for that host).
3. `hosts/common.nix`, shared base config applied to every host (packages, fonts, locale, nix settings, home-manager shared modules, etc.).
4. **Every file named `module.nix` found recursively under `modules/`**. This is auto-discovered via `listFilesRecursive`, so a new module only needs to be placed anywhere under `modules/` to be picked up; nothing needs to be registered elsewhere.

`packages/default.nix` does the analogous auto-discovery for custom packages: any `*.nix` file (other than `default.nix`) or any `package.nix` under `packages/` becomes an attribute in the flake's `packages` output, named after the file (or its parent directory for `package.nix`).

### Module convention (`modules/**/module.nix`)

Every module follows the same shape:
- Declares options under `config.modules.<category>.<name>` (e.g. `modules.programs.zsh`, `modules.services.docker`, `modules.development.claude`), almost always with an `enable = mkEnableOption ...`.
- Modules that configure home-manager for specific users take a `users = mkOption { type = listOf str; }` option and use `genAttrs cfg.users (username: { ... })` to apply the same home-manager config to each listed user, rather than hardcoding usernames.
- The whole module body is wrapped in `config = mkIf cfg.enable { ... };`.
- Categories under `modules/`: `boot`, `bundles` (higher-level composites like `gaming`, `photography` that turn on several lower-level modules at once; see `modules/desktop/module.nix` for an example of a bundle enabling `programs`, `services`, etc.), `desktop`, `development`, `programs`, `services`, `users`.
- `modules/users/<name>/module.nix` defines a NixOS user plus their home-manager config (dotfiles, git/ssh settings, etc.) gated behind `modules.users.<name>.enable`. `modules.users.<name>.main` flags a user to be added to the global `modules.users.main` list that other modules key off of for "the primary user(s) of this machine".

When adding a new module, follow this exact pattern (options block + `mkIf cfg.enable` plus, if relevant, a `users` list option) rather than writing ad-hoc config directly in a host file.

### Hosts (`hosts/<name>/`)

Each host directory has:
- `default.nix`: trivial, just imports `hardware-configuration.nix` and `configuration.nix`.
- `hardware-configuration.nix`: machine-generated, generally shouldn't be hand-edited beyond what `nixos-generate-config` produces.
- `configuration.nix`: the actual per-host config, which `modules.*` options to turn on and host-specific settings (networking, filesystems, host-specific packages).

`beaststation` additionally has a `compose/` directory of Docker Compose services (Nextcloud, Gitlab, Immich, Jellyfin, Authentik, Matrix, Traefik, monitoring, etc.) that run alongside the NixOS-managed services. These are started/stopped via `compose/up.sh` / `compose/down.sh`, which loop over every subdirectory with a `compose.yml`. See `hosts/beaststation/README.md` for the full install/ZFS setup procedure and `hosts/beaststation/compose/README.md` for the per-service secrets (env vars) and bind-mount layout (`/ssd` vs `/hdd`, `critical` vs `non-critical`).

### Secrets (`secrets/`)

Secrets are managed with [agenix](https://github.com/ryantm/agenix); encrypted `*.age` files live in `secrets/`, keyed by host/user SSH public keys declared in `secrets/agenix-rules.nix`. To add a secret: add it to `agenix-rules.nix`, author it with `agenix -e <name>.age`, reference it from a module with `age.secrets.<name>.file = ../secrets/<name>.age;`, and consume it via `config.age.secrets.<name>.path` (a path to the decrypted file at runtime, not the value itself). Adding a new machine requires adding its public key to `agenix-rules.nix` and re-running `agenix -r` to rekey existing secrets. That needs the private key, so it's not something to do unprompted.

**Never read private key material.** Files like `*_private.key`, raw WireGuard/SSH/age private keys, or any plaintext secret sitting in the working tree before it's encrypted must never be opened with the Read tool (or otherwise passed through the model), not even the user's own keys on their own machine. If a private key needs to go into a config or be consumed by a script, do it via shell commands that read the file and act on it at execution time (e.g. `cat key | someCommand`) without the content ever appearing in a tool result you see. Public keys are not secret and are fine to read and inline.

### Formatting

All `.nix` files are formatted with `alejandra`. Run `format` (or `alejandra .`) before committing; `nix flake check` fails the build if formatting is off.
