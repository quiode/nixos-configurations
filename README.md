# NixOS Configurations

This Repository contains all my NixOS configuration files for my Computers, Laptops, Servers, etc.

## Structure

### `flakes`

This directory contains useful flakes for different kind of development environments.

### `packages`

Contains custom packages not in `nixpkgs`.

### `modules`

Contains the modularized configurations of my systems. Everything is under `modules.*`.

### `hosts`

Contains host-specific configurations.

## Networking

`beaststation` (in Zurich) and `hermes` (in Buttikon) are joined by a WireGuard hub-and-spoke VPN. beaststation is the hub (listens on `51820/udp` at `beaststation.dominik-schwaiger.ch`), hermes dials out to it as a site-to-site spoke, bridging the Zurich LAN (`192.168.1.0/24`) and the Buttikon LAN (`192.168.0.0/24`) in both directions. Laptops (e.g. `hades`) can join the same hub as full-tunnel road-warrior clients, routing both LANs and general internet traffic through beaststation.

The site-to-site config (hermes, beaststation) is declarative, in `hosts/beaststation/configuration.nix` and `hosts/hermes/configuration.nix`. A laptop's client connection is **not** Nix-managed. It's a NetworkManager profile instead, since laptops typically have no SSH host key for agenix to auto-decrypt with at boot. See `secrets/README.md` for how that's backed up.

### Reconnecting a wiped laptop to the VPN

If a laptop (e.g. `hades`) gets reinstalled, its WireGuard connection isn't automatically recreated. The SSH key agenix needs to decrypt its backup has to come back first:

1. Restore `~/.ssh/id_ed25519` (and `.pub`) from Bitwarden. This is the identity its `*_wireguard_key.age` secret is encrypted to.
2. `agenix -d <host>_wireguard_key.age > wg.conf`
3. `nmcli connection import type wireguard file wg.conf`
4. `rm wg.conf`. Don't leave the decrypted config lying around.

## Develop

Run `nix develop` to open a shell with some useful commands and the minimal required packages.

## Inspirations

- [bloxx12](https://copeberg.org/bloxx12/nichts)
