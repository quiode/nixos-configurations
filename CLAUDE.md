# NixOS Configuration Repo

Personal NixOS configs for computers, laptops, and servers.

> If a README changes or you make structural changes, update this file to reflect them.
> For details not covered here, consult the relevant README.md files.

## Structure

- `flakes/` — dev environment flakes (copy to project root as `flake.nix`, run `nix develop`)
- `packages/` — custom packages not in nixpkgs
- `modules/` — modular NixOS configs under `modules.*`
- `hosts/` — host-specific configs
- `secrets/` — agenix-encrypted secrets (`.age` files)

## Secrets (agenix)

Secrets are encrypted with host SSH keys and stored in `secrets/`. They are decrypted at runtime to `/run/agenix`.

- Add machine: add its public key to `secrets/secrets.nix`, then rekey with `agenix -r`
- Add secret: `agenix -e secret1.age`, then reference via `age.secrets.secret1.file` and use `config.age.secrets.secret1.path`

## Beaststation (main server)

NixOS server with mirrored ZFS (`rpool` on two disks). Services run as Docker containers defined in `hosts/beaststation/compose/`.

### Storage pools

- `ssd` / `hdd` — each has `critical` (snapshotted + backed up) and `non-critical` datasets
- Critical data: `pool/critical/...`, non-critical: `pool/non-critical/...`

### Docker compose secrets

Per-service env files live at `/ssd/critical/<service>/secrets.env`.

Key secret variables by service (see [compose/README.md](hosts/beaststation/compose/README.md) for full list):
- Common DB: `DB_PW`
- Nextcloud: `NEXTCLOUD_ADMIN_PASSWORD`, `SMTP_PASSWORD`
- Authentik: `AUTHENTIK_EMAIL__PASSWORD`, `POSTGRES_PASSWORD`, `AUTHENTIK_POSTGRESQL__PASSWORD`
- Immich: `DB_PASSWORD`
- Atuin: `ATUIN_DB_PASSWORD`
- Factorio: `USERNAME`, `TOKEN`
- Gitlab: `GITLAB_SMTP_PASSWORD`, `OIDC_CLIENT_SECRET`
- OnlyOffice: `JWT_SECRET`

### Exposed ports

80/443 (proxy), 25565 (Minecraft), 22 (Gitlab; host SSH on 2222), 389/636 (LDAP), 34197 (Factorio), 51820 (WireGuard), 25/143/465/587/993/4190 (mail)

### ZFS encryption

Data datasets are encrypted with a passphrase. On boot, decrypt by SSH-ing to the server as root, or place passphrase at `/config/secrets/passphrase.txt` for auto-decrypt.
