{ config, ... }:
{
  system.primaryUser = config.username;
  users.users.${config.username} = {
    name = "${config.username}";
    home = "/Users/${config.username}";
    isHidden = false;
    shell = "/bin/zsh";
  };
  programs.zsh.enable = true;
}
