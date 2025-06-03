{ config, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "*" = {
        identityFile = "${config.sops.secrets."sshkey/private".path}";
      };
      "ssh.github.com" = {
        forwardAgent = true;
        port = 443;
      };
      "github.com" = {
        hostname = "ssh.github.com";
        forwardAgent = true;
        port = 443;
      };
      "stage" = {
        hostname = "q.dev.ionata.com";
        forwardAgent = true;
      };
    };
  };
}
