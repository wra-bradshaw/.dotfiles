{ pkgs, config, ... }:
{
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile =
    if pkgs.stdenv.isDarwin then
      "/Users/${config.username}/Library/Application Support/sops/age/keys.txt"
    else
      "/home/${config.username}/.config/sops/age/keys.txt";
  sops.secrets.tailscale = { };
  sops.secrets.github = { };
  sops.secrets."bitwarden/client_id" = { };
  sops.secrets."bitwarden/client_secret" = { };
  sops.secrets."sshkey/private" = { };
  sops.secrets."sshkey/public" = { };
  sops.secrets."dufs/pw" = { };
  sops.secrets."dufs/hash" = { };
  sops.secrets."pihole" = { };
}
