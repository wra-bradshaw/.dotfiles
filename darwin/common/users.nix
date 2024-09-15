{ config, pkgs, ... }:
{
  users.users.${config.username} = {
    name = "${config.username}";
    home = "/Users/${config.username}";
    isHidden = false;
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
}
