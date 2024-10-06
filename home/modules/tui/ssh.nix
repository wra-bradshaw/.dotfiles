{ config, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "*" = {
        identityFile = "${config.sops.secrets."sshkey/private".path}";
      };
      "github.com" = {
        forwardAgent = true;
      };
      "stage" = {
        hostname = "q.dev.ionata.com";
        forwardAgent = true;
      };
    };
  };
}
