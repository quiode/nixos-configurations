# Secrets

Contains configuration information for [agenix](https://github.com/ryantm/agenix).

## Add a machine

1. add the public key of the machine to: `agenix-rules.nix`
1. rekey all the secrets with: `agenix -r` (note that the private key is needed)

## Add a secret

1. create the secret file: `agenix -e secret1.age`
1. add secret to a NixOS module config: `age.secrets.secret1.file = ../secrets/secret1.age;`
1. use the secret: `config.age.secrets.secret1.path`, note that this only copies the path to the cleartext secret. the secret has still to be read

## Manual-only secrets (no `age.secrets` wiring)

Not every `.age` file here is consumed by a NixOS module. `hades_wireguard_key.age` backs up a NetworkManager WireGuard connection that lives on hades, not in the Nix config. hades has no SSH host key for agenix to decrypt with automatically at boot, and the fallback (quio's personal SSH key) is passphrase-protected, so headless automatic decryption isn't possible for it. This pattern (encrypted backup, decrypted manually, never wired into `age.secrets`) is the right call for any secret that only needs to survive on a machine without a usable headless decryption identity.

For `hades_wireguard_key.age` specifically, the file holds a **complete, ready-to-import `wg-quick`-style `.conf`** (not just a bare private key), so restoring it is just:
1. `agenix -d hades_wireguard_key.age > hades.conf` (prompts for quio's SSH key passphrase)
2. `nmcli connection import type wireguard file hades.conf`
3. `rm hades.conf` once imported. Don't leave the decrypted conf lying around.
