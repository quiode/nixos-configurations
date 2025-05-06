# Secrets

Contains configuration information for [agenix](https://github.com/ryantm/agenix).

## Add a machine

1. add the public key of the machine to: `secrets.nix`
1. rekey all the secrets with: `agenix -r` (note that the private key is needed)

## Add a secret

1. create the secret file: `agenix -e secret1.age`
1. add secret to a NixOS module config: `age.secrets.secret1.file = ../secrets/secret1.age;`
1. use the secret: `config.age.secrets.secret1.path`, note that this only copies the path to the cleartext secret. the secret has still to be read
