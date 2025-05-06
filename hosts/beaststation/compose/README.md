# docker compose configuration

Docker compose files for my server (Beaststation).

## Location

These should be saved to `/ssd/critical/service/secrets.env` for each service and mounted as env files.

## Secrets

- **Watchtower**
  - `REPO_PASSWORD`
    - password for docker repo
  - `WATCHTOWER_NOTIFICATION_URL`
    - telegram url (token) for watchtower bot
- **Common Database Secret**
  - `DB_PW`
    - password for databases
  ```bash
  MYSQL_PASSWORD="${DB_PW}"
  MARIADB_ROOT_PASSWORD="${DB_PW}"
  MARIADB_PASSWORD="${DB_PW}"
  POSTGRES_PASSWORD="${DB_PW}"
  ```
- **Nextcloud**

  - `NEXTCLOUD_ADMIN_PASSWORD`

    - admin password for nextcloud

  - `SMTP_PASSWORD`
    - password for <mail@nextcloud.dominik-schwaiger.ch>
      `NEXTCLOUD_SMTP_PASSWORD="${SMTP_PASSWORD}"`
      `globalSettings__mail__smtp__password="${SMTP_PASSWORD}"`

- **Only Office**
  - `JWT_SECRET`
    - secret for jwt's (onlyoffice)
- **Personal Website**
  - `SCHWAIGER_ADMIN_PASSWORD`
    - password to enter admin panel of <https://dominik-schwaiger.ch>
- **Gitlab**
  - `GITLAB_SMTP_PASSWORD`
    - email password for gitlab
  - `OIDC_CLIENT_SECRET`
    - authentik
  - `OIDC_CLIENT_SECRET`
    - authentik
  - **Gitlab Registry**
    - `POSTGRES_PASSWORD`
- **Immich**
  - `DB_PASSWORD`
    - password for immich db
      `POSTGRES_PASSWORD="${DB_PASSWORD}"`
- **Authentik**
  - `AUTHENTIK_EMAIL__PASSWORD`
  - `POSTGRES_PASSWORD`
  - `AUTHENTIK_POSTGRESQL__PASSWORD`
- **Open WebUI**
  - `OAUTH_CLIENT_ID`
  - `OAUTH_CLIENT_SECRET`
- **Factorio**
  - `USERNAME`
  - `TOKEN`

## Bind Volumes

Critical data (which should be snapshotted more often and also should be backed up) is always saved under `pool/critical` while non-critical stuff is saved under `pool/non-critical`. There are two pools, `hdd` and `ssd`. Their names should make it clear which one is where. Big data or data which doesn't have to be accessed for a long time should be on the hdd while small data or data that has to be accessed often should be saved on the ssd.

### Data

- `/ssd/critical/nextcloud/html`
- `/hdd/critical/nextcloud/data`
- `/ssd/critical/nextcloud/apps`
- `/ssd/critical/nextcloud/config`
- `/ssd/critical/nextcloud/themes`
- `/ssd/critical/nextcloud/database`
- `/ssd/critical/minecraft/server`
- `/hdd/non-critical/minecraft/backups`
- `/ssd/critical/vaultwarden`
- `/hdd/non-critical/dominik-schwaiger.ch/images`
- `/ssd/critical/gitlab/runner/config`
- `/hdd/non-critical/gitlab/logs`
- `/ssd/critical/gitlab/config`
- `/hdd/critical/gitlab/data`
- `/ssd/critical/jellyfin/config`
- `/hdd/non-critical/jellyfin/media`
- `/ssd/critical/qbittorrent/appdata`
- `/hdd/non-critical/qbittorrent/downloads`
- `/ssd/critical/immich/database`
- `/hdd/non-critical/immich/data`
- `/hdd/critical/immich/data/library`
- `/hdd/critical/immich/data/upload`
- `/hdd/critical/immich/data/profile`
- `/hdd/non-critical/ollama`
- `/hdd/critical/open-webui`
- `/ssd/non-critical/open-webui/cache`
- `/ssd/critical/home-assistant/config`
- `/hdd/critical/home-assistant/backups`
- `/ssd/critical/home-assistant/esphome`
- `/hdd/critical/matrix/data/media`
- `/ssd/critical/matrix/data`
- `/ssd/critical/matrix/db`
- `/ssd/critical/authentik/database`
- `/ssd/critical/authentik/media`
- `/ssd/critical/authentik/custom-templates`
- `/ssd/critical/jellyseerr/config`
- `/ssd/critical/sonarr/config`
- `/ssd/critical/radarr/config`
- `/ssd/critical/prowlarr/config`
- `/ssd/critical/gitlab/registry/database`
- `/ssd/critical/factorio`
- `/ssd/critical/wg-easy`
- `/ssd/critical/stalwart`

### Other

- `/var/run/docker.sock`

## Ports

- 80 (proxy)
- 443 (proxy)
- 25565 (Minecraft)
- 22 (Gitlab) (host ssh port has to be changed -> currently set to 2222)
- 389 (LDAP Authentik)
- 636 (LDAP Authentik)
- 34197 (Factorio)
- 51820 (wg-easy (VPN))
- 25 (SMTP - explicit TLS via STARTTLS, authentication disabled; use port 465/587 instead)
- 143 (IMAP4 - explicit TLS via STARTTLS)
- 465 (ESMTP - implicit TLS)
- 587 (ESMTP - explicit TLS via STARTTLS)
- 993 (IMAP4 - implicit TLS)
- 4190 (ManageSieve - Sieve scripts)
