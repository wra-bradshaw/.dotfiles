{ pkgs, ... }:
{
  programs._1password-gui = {
    enable = true;
    # Direct-download zip build, updated more frequently than nixpkgs.
    package = pkgs.brewCasks."1password";
  };

  programs._1password.enable = true;
}
