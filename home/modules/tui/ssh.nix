{ config, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identityFile = "${config.sops.secrets."sshkey/private".path}";
      };
      "ssh.github.com" = {
        forwardAgent = true;
        port = 443;
        addKeysToAgent = "yes";
      };
      "github.com" = {
        hostname = "ssh.github.com";
        forwardAgent = true;
        port = 443;
        addKeysToAgent = "yes";
      };
      "stage" = {
        hostname = "q.dev.ionata.com";
        forwardAgent = true;
        addKeysToAgent = "yes";
      };
    };
  };
}
