# Beaststation Configuration

This folder contains all configuration files (and thus all specification) for my server (_beaststation_).

The server itself runs on NixOS. See below for further information.

The actual services are all run inside docker containers. Their setup is specified with the docker compose files inside `compose` (the `README.md`).

All data is stored on raid devices and the most critical data is also being backed up on an external server.

## Server Setup

### Installation

This is a step-by-step guide to install NixOS (with mirrored ZFS) on a (virtual) machine.

#### Setup

- Enable EFI support
- 2 \* 25G of (empty) Disks
- 8G of Memory
- 4 Cores
- set Network to Bridged Adapter

#### Guide

Use the minimal edition of the nixos installer. This is tested for nixos version 24.11.

##### Host Setup

1. Become root: `sudo su`
1. Enable german keys: `loadkeys de`
1. Set password: `passwd`
1. Enable ssh: `systemctl restart sshd`
1. Get the ip of the server: `ip address`

Now connect with the system using the host ssh: `ssh root@ip`.

##### Partitioning

1. Save the disks `DISK1=/dev/disk/by-id/...`, `DISK2=/dev/disk/by-id/...`
1. create the partitions:

```bash
sgdisk -o $DISK1 # optional, clear the disk
sgdisk -n1:1M:+1G -t1:EF00 $DISK1 # efi/boot
sgdisk -n2:0:+4G -t2:8200 $DISK1 # set to a custom size of needed, swap
sgdisk -n3:0:0 -t3:8300 $DISK1 # root/rest

sgdisk -o $DISK2 # clear the second disk
sfdisk --dump $DISK1 | sfdisk $DISK2 # copy the partitions to the second disk
```

3. check the partitions `fdisk -l`

4. create zfs pool

```bash
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=none \
    rpool \
    mirror \
    $DISK1-part3 $DISK2-part3
```

5. create datasets and mount them

```bash
zfs create rpool/root
zfs create rpool/nix
zfs create rpool/var
zfs create rpool/home

mkdir -p /mnt
mount -t zfs rpool/root /mnt -o zfsutil
mkdir /mnt/nix /mnt/var /mnt/home

mount -t zfs rpool/nix /mnt/nix -o zfsutil
mount -t zfs rpool/var /mnt/var -o zfsutil
mount -t zfs rpool/home /mnt/home -o zfsutil
```

6. format boot

```bash
mkfs.fat -F 32 -n boot $DISK1-part1
mkfs.fat -F 32 -n boot $DISK2-part1
```

7. format swap

```bash
mkswap -L swap $DISK1-part2
swapon $DISK1-part2

mkswap -L swap $DISK2-part2
swapon $DISK2-part2
```

##### Install NixOS

1. mount boot

```bash
mkdir -p /mnt/boot
mount $DISK1-part1 /mnt/boot

mkdir -p /mnt/boot-fallback
mount $DISK2-part1 /mnt/boot-fallback

# Generate the nixos config
nixos-generate-config --root /mnt
```

##### Configure NixOs

1. go into the nixos directory: `cd /mnt/etc/nixos`
1. update bootloader config and network host (get is using `head -c4 /dev/urandom | od -A none -t x4`) in `configuration.nix`

```nix
{
  networking.hostId = "6b0b03b3";
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = 5;
      mirroredBoots = [
        {
          devices = [ "/dev/disk/by-id/ata-VBOX_HARDDISK_VBcd418fbb-dbdaf4e2-part1" ];
          path = "/boot-fallback";
        }
      ];
    };
  };
}
```

3. update the hardware configuration `hardware-configuration.nix`

_(Now check the hardware-configuration.nix in /mnt/etc/nixos/hardware-configuration.nix and add whats missing e.g. options = [ "zfsutil" ] for all filesystems except boot and randomEncryption = true; for the swap partition. Also change the generated swap device to the partition we created e.g. /dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part2 in this case and /dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part1 for boot.)_ - <https://wiki.nixos.org/wiki/ZFS>

```nix
{
  # ...

  fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
      options = ["zfsutil"];
    };

  fileSystems."/nix" =
    { device = "rpool/nix";
      fsType = "zfs";
      options = ["zfsutil"];
    };

  fileSystems."/var" =
    { device = "rpool/var";
      fsType = "zfs";
      options = ["zfsutil"];
    };

  fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
      options = ["zfsutil"];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBdb4578c1-95c7dacd-part1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/boot-fallback" =
    { device = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBcd418fbb-dbdaf4e2-part1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ {
         device = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBdb4578c1-95c7dacd-part2";
         randomEncryption = true;
      }
      {
         device = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBcd418fbb-dbdaf4e2-part2";
         randomEncryption = true;
      }
    ];

  # ...
}
```

4. install nixos `nixos-install --root /mnt`

##### Setup after installation

1. set passwort for root and users using `passwd`
1. import/create the various pools and create the datasets `zpool import hdd`, `zpool import ssd` and add them to the `configuration.nix` for automatic import
1. enable git in `configuration.nix`: `programs.git.enable = true;`
1. Clone the Repository to a sutable location (`/config`)
1. remove the existing nixos config and sync it to the git repository: `rm -rf /etc/nixos` and then `ln -s /config/nix /etc/nixos`
1. use the config: `nixos-rebuild switch`

### Passwords

Passwords and other secrets are all being handled using [agenix](https://github.com/ryantm/agenix). They are stored encrypted under `../secrets` and are decrypted (using the ssh key of the host system) and mounted under `/run/agenix`.

For more information read the readme in the secrets folder.

### Encryption

The zfs datasets with actual data (so not the boot partition, rpool, etc.) are encrypted using a passphrase. On boot, the datasets have to be decrypted and mounted by connecting to the server `ssh root@dominik-schwaiger.ch`. The passphrase also could be placed under `/config/secrets/passphrase.txt` (and the configuration changed accordingly). Then the datasets will be automatically decrypted.

This is primarily done so that the backups are stored encrypted (and also being transferred encrypted as raw data). Thus they can't be compromised. The overhead should be minimal (hopefully).
