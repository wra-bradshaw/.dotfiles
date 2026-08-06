{ config, ... }:
{
  system.primaryUser = config.username;
  users.users.${config.username} = {
    name = "${config.username}";
    home = config.userHome;
    isHidden = false;
    shell = "/bin/zsh";
  };
  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
}
