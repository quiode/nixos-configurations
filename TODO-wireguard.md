# WireGuard hub: remaining steps

Nix config for the beaststation/hermes/hades WireGuard hub has been added (`hosts/beaststation/configuration.nix`, `hosts/hermes/configuration.nix`, `secrets/agenix-rules.nix`). Full design/rationale: `/home/quio/.claude/plans/i-want-to-enable-synchronous-rivest.md`.

## Keys & secrets

- [x] Generate 3 keypairs (`hermes`, `beaststation`, `hades`)
- [x] `agenix -e hermes_wireguard_key.age` and `agenix -e beaststation_wireguard_key.age`. Both encrypted secrets exist in `secrets/`
- [x] hermes's and beaststation's public keys are filled into `hosts/beaststation/configuration.nix` and `hosts/hermes/configuration.nix`
- [x] hades's public key is filled into `hosts/beaststation/configuration.nix`
- [x] All plaintext private/public key files deleted from the repo working tree. Never passed through Claude, per the rule now in `CLAUDE.md`
- [x] `hades_wireguard_key.age` created too, as a manual-only encrypted backup (see "hades laptop" below) and registered in `secrets/agenix-rules.nix`, scoped to `hades-quio` only

## Interface names

- [x] No longer needed. Both hosts' firewall rules now auto-detect the default-route interface at runtime (`ip -4 route show default`) instead of a hardcoded name.

## Deploy (in order, see "Deployment ordering" in the plan)

- [ ] `nix flake check` once secrets exist, then `nh os switch` (or push + pull) on hermes. Confirm `wg0` comes up (no handshake expected yet)
- [ ] Physically move beaststation to Zurich; confirm it's on `192.168.1.x`
- [ ] Deploy beaststation's config only after that move is confirmed

## Routers

- [x] Buttikon TP-Link: DHCP reservation for hermes + static route `192.168.1.0/24` → hermes
- [ ] Zurich router: DHCP reservation for beaststation + port-forward UDP `51820` → beaststation + static route `192.168.0.0/24` → beaststation
- [ ] Zurich router: port-forward `80`/`443` for beaststation's other public services (separate from this VPN)

## hades laptop

- [x] hades's VPN profile is imported into NetworkManager (`nmcli connection show hades`). Persistent on disk at `/etc/NetworkManager/system-connections/`, but **not** Nix-declarative. hades has no SSH host key for agenix to decrypt with at boot, and quio's personal SSH key (the fallback identity) is passphrase-protected, so there's no headless identity available. Documented in `hosts/beaststation/configuration.nix` next to hades's peer entry, and in `secrets/README.md`.
- [x] `connection.autoconnect` set to `no` on the hades profile. **Important**: `nmcli connection import` defaults to autoconnect, and since this is a full-tunnel (`AllowedIPs = 0.0.0.0/0`) profile, letting it auto-activate hijacks all routing the moment it's added. Keep this off; only toggle the VPN on manually from the GNOME network menu when you actually want it.
- [x] `secrets/hades_wireguard_key.age` now holds the **complete, ready-to-import `wg-quick` `.conf`** (not just the bare private key). If the NetworkManager profile is ever lost (reinstall, etc.), recovery is just:
  1. `agenix -d hades_wireguard_key.age > hades.conf` (prompts for quio's SSH key passphrase)
  2. `nmcli connection import type wireguard file hades.conf`
  3. `rm hades.conf` once imported

## Verify

- [ ] `wg show wg0` on both hosts, handshakes present
- [ ] Ping both tunnel IPs (`10.100.0.1` ⟷ `10.100.0.2`) and a device on the other site's LAN, from each host
- [ ] From an ordinary device on the Zurich LAN and on the Buttikon LAN: ping, plus a large transfer/HTTPS load across the tunnel (catches MTU/MSS issues ping alone misses; set `mtu = 1380;` on `wg0` on both hosts if transfers stall)
- [ ] From hades with the VPN on: ping both LANs, `curl ifconfig.me` shows beaststation's public IP
- [ ] On beaststation: `iptables -t nat -L POSTROUTING -n -v` shows the MASQUERADE rule matching hades's traffic
- [ ] Confirm beaststation's other public services still work after the move
