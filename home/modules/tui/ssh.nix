{ config, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        IdentityFile = "${config.sops.secrets."sshkey/private".path}";
      };
      "ssh.github.com" = {
        ForwardAgent = true;
        Port = 443;
        AddKeysToAgent = "yes";
      };
      "github.com" = {
        HostName = "ssh.github.com";
        ForwardAgent = true;
        Port = 443;
        AddKeysToAgent = "yes";
      };
      "stage" = {
        HostName = "q.dev.ionata.com";
        ForwardAgent = true;
        AddKeysToAgent = "yes";
      };
    };
  };
}
