let
  beaststation-domina = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAION61ovdLLEFvBSEnM0KHflttJFbOe3KDAwIShZM7uTd domina@beaststation";
  hades-quio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU+TustXXTKC67YrMyTHsrw2w0IGx1DSA/0woBXJbGg quio@hades";
  artemis-quio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt4xvNKr0MsKk7qY9RJux9KGfUk2lCsnAeUO4NtJP8n quio@artemis";
  hermes-domina = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Z8fV3p7JzKDcuhA3EuDWXsfvGwID9mayfTgJAvWiq domina@hermes";

  users = [
    beaststation-domina
    hades-quio
    artemis-quio
  ];

  beaststation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/s6lYNuiiu10xgH91eUfyHMBumXa3wby0dP+PaVsaF root@beaststation";
  hermes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+dYdI1x+k5WbToxXDECgMxrrhra//iW7U086GLQ1ZX root@nixos";

  systems = [beaststation hermes];

  all = users ++ systems;
in {
  "beaststation_mail_password.age".publicKeys = all;
  "hermes_infomaniak_dyndns.age".publicKeys = all;
}
