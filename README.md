# NixOS Configurations

This Repository contains all my NixOS configuration files for my Computers, Laptops, Servers, etc.

## Structure

### `packages`

Contains custom packages not in `nixpkgs`.

### `modules`

Contains the modularized configurations of my systems. Everything is under `modules.*`.

### `hosts`

Contains host-specific configurations.

## Develop

Run `nix develop` to open a shell with some usefull commands and the minimal required packages.

## Inspirations

- [bloxx12](https://copeberg.org/bloxx12/nichts)
